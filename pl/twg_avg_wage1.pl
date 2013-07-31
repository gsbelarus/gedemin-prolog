%
:- include(date).
:- include(lib).

:- multifile
    twg_AvgWage/4,
    usr_wg_MovementLine/7,
    usr_wg_TblCalDay/5,
    usr_wg_TblCalMonth/5,
    usr_wg_TblCalLine/6,
    usr_wg_TotalLine/4.

:- include(facts).
:- include(facts1).
:- include(facts2).

:- dynamic
    wg_avg_wage/3,
    wg_month_incl/4.

% среднемесячное количество календарных дней
wg_avg_days(29.7).

% варианты правил расчета
wg_valid_rules([by_calc_month, by_avg_houre, by_day_houres, by_month_houres, by_month_wage_all, by_month_wage_one]).

% варианты правил полных месяцев
wg_full_month_rules([by_day_houres, by_month_houres]).

% правило действительно
is_valid_rule(Rule) :-
    wg_valid_rules(ValidRules),
    member(Rule, ValidRules),
    !.

% среднедневной заработок
avg_wage :-
    % параметры расчета
    twg_AvgWage(_, EmplKey, _, _),
    % удаление фактов по среднедневному заработку по сотруднику
    retractall( wg_avg_wage(EmplKey, _, _) ),
    % среднедневной заработок по сотруднику
    avg_wage(EmplKey, AvgWage, Variant),
    % добавление факта по среднедневному заработку по сотруднику
    assertz( wg_avg_wage(EmplKey, AvgWage, Variant) ),
    % вывод факта по среднедневному заработку по сотруднику
    write( wg_avg_wage(EmplKey, AvgWage, Variant) ), nl,
    % найти альтернативу
    fail.

avg_wage.

% среднедневной заработок по сотруднику (по расчетным месяцам)
avg_wage(EmplKey, AvgWage, Rule) :-
    Rule = by_calc_month,
    % правило действительно
    is_valid_rule(Rule),
    % удаление фактов по расчетным месяцам
    retractall( wg_month_incl(EmplKey, _, _, _) ),
    % периоды для проверки
    findall( Year-Month,
        % взять год-месяц из графика
        usr_wg_TblCalMonth(EmplKey, Year, Month, _, _),
        % в список периодов
             Periods ),
    % проверка по табелю
    check_month_tab(EmplKey, Periods),
    % есть хотя бы один расчетный месяц
    wg_month_incl(EmplKey, _, _, _),
    % проверка по заработку
    check_month_wage(EmplKey, Periods),
    % заработок по расчетным месяцам
    findall( Wage,
        (
        % за расчетный месяц
        wg_month_incl(EmplKey, Y, M, _),
        % взять заработок
        usr_wg_TotalLine(EmplKey, Y, M, Wage)
        ),
        % в список заработков
             Wages ),
    % общий заработок за расчетные месяцы
    sum_list(Wages, Amount),
    % количество расчетных месяцев
    length(Wages, Num),
    % среднемесячное количество календарных дней
    wg_avg_days(AvgDays),
    % среднедневной заработок
    catch( AvgWage is Amount / Num / AvgDays, _, fail),
    !.

% среднедневной заработок по сотруднику (по среднечасовому)
avg_wage(EmplKey, AvgWage, Rule) :-
    Rule = by_avg_houre,
    % правило действительно
    is_valid_rule(Rule),
    % заработок по месяцам
    findall( Wage,
        % взять заработок за месяц
        usr_wg_TotalLine(EmplKey, _, _, Wage),
        % в список заработков
             Wages ),
    % общий заработок по табелю
    sum_list(Wages, Amount),
    % часы по дням по табелю
    findall( Duration,
        % взять часы из табеля
        usr_wg_TblCalLine(EmplKey, _, Duration, _, _, _),
        % в список часов
             Durations ),
    % всего часов по табелю
    sum_list(Durations, TotalWork),
    % среднечасовой заработок
    catch( AvgHoureWage is Amount / TotalWork, _, fail ),
    % расчетная норма из графика
    findall( MonthNorm,
        % взять часы за месяц
        usr_wg_TblCalMonth(EmplKey, _, _, MonthNorm, _),
        % в список часов
             MonthNorms ),
    % всего часов по графику
    sum_list(MonthNorms, TotalNorm),
    % количество нормативных месяцев
    length(MonthNorms, NumNorm),
    % среднемесячное количество расчетных рабочих часов
    catch( AvgMonthNorm is TotalNorm / NumNorm, _, fail ),
    % среднемесячное количество календарных дней
    wg_avg_days(AvgDays),
    % среднедневной заработок
    catch( AvgWage is  AvgHoureWage * AvgMonthNorm / AvgDays, _, fail),
    !.
    
% проверка месяца по табелю
check_month_tab(_, []):-
    % больше месяцев для проверки нет
    true.

check_month_tab(EmplKey, [ Y-M | Periods ]) :-
    % если выполняется одно из правил
    rule_month_tab(EmplKey, Y-M, Variant),
    % то добавить факт включения месяца в расчет
    assertz( wg_month_incl(EmplKey, Y, M, Variant) ),
    !,
    % проверить следующий месяц
    check_month_tab(EmplKey, Periods).

check_month_tab(EmplKey, [ _ | Periods ]) :-
    !,
    % проверить следующий месяц
    check_month_tab(EmplKey, Periods).

% правила включения месяца в расчет
rule_month_tab(EmplKey, YM, Rule) :-
    Rule = by_day_houres,
    % правило действительно
    is_valid_rule(Rule),
    % часы по дням по табелю покрывают график
    month_by_day_houres(EmplKey, YM).

rule_month_tab(EmplKey, YM, Rule) :-
    Rule = by_month_houres,
    % правило действительно
    is_valid_rule(Rule),
    % всего часов за месяц по табелю покрывает график
    month_by_month_houres(EmplKey, YM).

% часы по дням по табелю покрывают график
month_by_day_houres(EmplKey, Y-M) :-
    % если для какого-либо рабочего дня из графика
    usr_wg_TblCalDay(EmplKey, Date, Duration, 1, _),
    % дата для которого совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % есть хотя бы одно несоответствие по дате и часам
    \+ usr_wg_TblCalLine(EmplKey, Date, Duration, _, _, _),
    % то месяц исключается из расчета
    !,
    fail.

month_by_day_houres(_, _) :-
    % иначе, месяц включается в расчет
    true.

% всего часов за месяц по табелю покрывает график
month_by_month_houres(EmplKey, Y-M) :-
    % часы из месяца по графику
    usr_wg_TblCalMonth(EmplKey, Y, M, MonthNorm, _),
    % часы из месяца по табелю
    month_houres(EmplKey, Y, M, MonthTab),
    % табель покрывает график
    MonthTab >= MonthNorm.

% сумма часов за месяц по табелю
month_houres(EmplKey, Y, M, MonthTab) :-
    % часы по дням в месяце
    findall( Duration,
        (
        % взять часы из табеля
        usr_wg_TblCalLine(EmplKey, Date, Duration, _, _, _),
        % где дата соответствует проверяемому месяцу
        atom_date(Date, date(Y, M, _))
        ),
        % в список часов
             Durations),
    % всего часов за месяц по табелю
    sum_list(Durations, MonthTab),
    !.

% проверка месяца по заработку
check_month_wage(_, []):-
    % больше месяцев для проверки нет
    true.
    
check_month_wage(EmplKey, [ Y-M | Periods ]) :-
    % если месяц еще не включен в расчет
    \+ wg_month_incl(EmplKey, Y, M, _),
    % и выполняется одно из правил
    rule_month_wage(EmplKey, Y-M, Variant),
    % то добавить факт включения месяца в расчет
    assertz( wg_month_incl(EmplKey, Y, M, Variant) ),
    !,
    % проверить следующий месяц
    check_month_wage(EmplKey, Periods).

check_month_wage(EmplKey, [ _ | Periods ]) :-
    !,
    % проверить следующий месяц
    check_month_wage(EmplKey, Periods).

% заработок за месяц выше или на уровне каждого из полных месяцев
rule_month_wage(EmplKey, YM, Rule) :-
    Rule = by_month_wage_all,
    % правило действительно
    is_valid_rule(Rule),
    % заработок за проверяемый месяц покрывает каждый из расчетных месяцев
    over_month_incl(EmplKey, YM),
    !.

% заработок за месяц выше или на уровне одного из полных месяцев
rule_month_wage(EmplKey, Y-M, Rule) :-
    Rule = by_month_wage_one,
    % правило действительно
    is_valid_rule(Rule),
    % заработок за проверяемый месяц
    usr_wg_TotalLine(EmplKey, Y, M, Wage),
    % есть хотя бы один расчетный месяц
    wg_month_incl(EmplKey, Y1, M1, Variant1),
    % по варианту полного месяца
    wg_full_month_rules(Rules),
    member(Variant1, Rules),
    % заработок за который
    usr_wg_TotalLine(EmplKey, Y1, M1, Wage1),
    % покрывается расчетным
    Wage >= Wage1,
    % то месяц включается в расчет
    !.

% заработок за проверяемый месяц покрывает каждый из расчетных месяцев
over_month_incl(EmplKey, Y-M) :-
    % заработок за проверяемый месяц
    usr_wg_TotalLine(EmplKey, Y, M, Wage),
    % если есть хотя бы один расчетный месяц
    wg_month_incl(EmplKey, Y1, M1, Variant1),
    % по варианту полного месяца
    wg_full_month_rules(Rules),
    member(Variant1, Rules),
    % заработок в котором
    usr_wg_TotalLine(EmplKey, Y1, M1, Wage1),
    % не покрывается расчетным
    \+ Wage >= Wage1,
    % то месяц исключается из расчета
    !,
    fail.

over_month_incl(_, _) :-
    % иначе, месяц включается в расчет
    true.

%
