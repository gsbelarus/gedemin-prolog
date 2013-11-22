﻿% twg_avg_wage

:- retractall(debug_mode).

%/* %%% begin debug mode section

%% saved state
:- ['../gd_pl_state/load_atom', '../gd_pl_state/date', '../gd_pl_state/dataset'].
%%

%% include
%#INCLUDE lib
:- [lib].
%#INCLUDE params
:- [params].
%#INCLUDE twg_avg_wage_sql
:- [twg_avg_wage_sql].
%#INCLUDE twg_avg_wage_in_params
%:- [twg_avg_wage_in_params].
%%

%% facts
:-  init_data,
    [
    usr_wg_MovementLine,
    usr_wg_TblDayNorm,
    usr_wg_TblYearNorm,
    usr_wg_TblCalLine,
    usr_wg_TblCal_FlexLine,
    usr_wg_HourType,
    usr_wg_TblCharge,
    usr_wg_FeeType,
    usr_wg_BadHourType,
    usr_wg_BadFeeType
    ].
%%

%% dynamic state
:- [param_list].
%%

%% flag
:- assertz(debug_mode).
%%

%*/ %%% end debug mode section

% варианты правил расчета
% [по расчетным месяцам, по среднечасовому]
wg_valid_rules([by_calc_month, by_avg_houre]).
% по расчетным месяцам (принятие месяца для исчисления)
% [соответствие табеля графику по дням и часам, по часам за месяц]
wg_valid_rules([by_day_houres, by_month_houres]).
% [заработок больше всех расчетных месяцев]
wg_valid_rules([by_month_wage_all]).
% [отсутствие в месяце плохих типов начислений и часов]
wg_valid_rules([by_month_no_bad_type]).

% варианты правил полных месяцев
% [соответствие табеля графику по дням и часам, по часам за месяц]
wg_full_month_rules([by_day_houres, by_month_houres]).

% правило действительно
is_valid_rule(Rule) :-
    wg_valid_rules(ValidRules),
    member(Rule, ValidRules),
    !.

% среднедневной заработок
avg_wage(Variant) :-
    % объявить параметры контекста
    Scope = wg_avg_wage,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % для каждого первичного ключа расчета из входных параметров
    get_param_list(Scope, in, PK),
    % подготовить данные
    engine_loop(Scope, in, PK),
    get_local_date_time(DT1),
    new_param_list(Scope, debug, [begin-DT1|PK]),
    % вычислить среднедневной заработок по сотруднику
    calc_avg_wage(Scope, PK, AvgWage, Variant),
    % сформировать выходные параметры
    once( get_data(Scope, in, usr_wg_MovementLine,
                [fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                 fMovementType-1, fListNumber-ListNumber]) ),
    append(PK, [pListNumber-ListNumber, pAvgWage-AvgWage, pVariant-Variant], OutPairs),
    new_param_list(Scope, out, OutPairs),
    get_local_date_time(DT2),
    new_param_list(Scope, debug, [end-DT2|PK]),
    % найти альтернативу
    fail.
avg_wage(_) :-
    % больше альтернатив нет
    !.

% среднедневной заработок по сотруднику (по расчетным месяцам)
calc_avg_wage(Scope, PK, AvgWage, Rule) :-
    % удаление временных параметров
    forall( get_param_list(Scope, temp, PK, Pairs),
            dispose_param_list(Scope, temp, Pairs) ),
    % периоды для проверки
    get_periods(Scope, PK, Periods),
    % проверка по табелю
    check_month_tab(Scope, PK, Periods),
    % добавление во временные параметры данных по заработку
    add_month_wage(Scope, PK, Periods),
    % проверка дальнейшего расчета
    Rule = by_calc_month,
    % правило действительно
    is_valid_rule(Rule),
    % если есть хотя бы один расчетный месяц
    ( exist_month_incl(Scope, PK),
    % то проверка по заработку
      check_month_wage(Scope, PK, Periods)
      ; true ),
    % проверка на отсутствие плохих типов начислений и часов
    check_month_no_bad_type(Scope, PK, Periods),
    % есть хотя бы один расчетный месяц
    exist_month_incl(Scope, PK),
    % взять заработок
    findall( Wage,
             % за расчетный месяц
             ( get_month_incl(Scope, PK, Y, M, _),
             % расчитать заработок
             cacl_month_wage(Scope, PK, Y, M, Wage) ),
    % в список заработков
             Wages ),
    % общий заработок за расчетные месяцы
    sum_list(Wages, Amount),
    % количество расчетных месяцев
    length(Wages, Num),
    % среднемесячное количество календарных дней
    get_param(Scope, in, pAvgDays-AvgDays),
    % среднедневной заработок
    catch( AvgWage0 is Amount / Num / AvgDays, _, fail),
    AvgWage is float( round(AvgWage0) ),
    !.
% среднедневной заработок по сотруднику (по среднечасовому)
calc_avg_wage(Scope, PK, AvgWage, Rule) :-
    Rule = by_avg_houre,
    % правило действительно
    is_valid_rule(Rule),
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % периоды для проверки
    get_periods(Scope, PK, Periods),
    % взять заработок
    findall( Wage,
             % за период проверки
             ( member(Y-M, Periods),
             % расчитать заработок
             cacl_month_wage(Scope, PK, Y, M, Wage)
             ),
    % в список заработков
             Wages ),
    % общий заработок по табелю
    sum_list(Wages, Amount),
    % взять часы
    findall( Duration,
             % за период проверки
             ( member(Y-M, Periods),
             % для отработанного дня
             usr_wg_TblCalLine_mix(Scope, PK, Date, Duration, _),
             % с контролем наличия часов
             Duration > 0,
             % дата для которого совпадает с проверяемым месяцем
             atom_date(Date, date(Y, M, _)) ),
    % в список часов
            Durations),
    % всего часов по табелю
    sum_list(Durations, TotalTab),
    % среднечасовой заработок
    catch( AvgHoureWage is Amount / TotalTab, _, fail ),
    % всего часов по графику за расчетный год
    get_data(Scope, in, usr_wg_TblYearNorm, [
                fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                fWHoures-TotalNorm]),
    % среднемесячное количество расчетных рабочих часов
    catch( AvgMonthNorm is TotalNorm / 12, _, fail ),
    % среднемесячное количество календарных дней
    get_param(Scope, in, pAvgDays-AvgDays),
    % среднедневной заработок
    catch( AvgWage0 is AvgHoureWage * AvgMonthNorm / AvgDays, _, fail),
    AvgWage is float( round(AvgWage0) ),
    !.

% периоды для проверки
get_periods(Scope, PK, Periods) :-
    find_param_list(Scope, run, PK, Pairs),
    member_list([pDateCalcFrom-DateFrom, pDateCalcTo-DateTo], Pairs),
    make_periods(DateFrom, DateTo, Periods),
    !.

% создать список периодов
make_periods(DateFrom, DateTo, [Y-M|Periods]) :-
    DateFrom @< DateTo,
    atom_date(DateFrom, date(Y, M, D)),
    date_add(date(Y, M, D), 1, month, DateFrom0),
    atom_date(DateFrom1, DateFrom0),
    !,
    make_periods(DateFrom1, DateTo, Periods).
make_periods(_, _, []).

% месяц значимый
is_value_month(Scope, PK, Y-M) :-
    % первый месяц работы полный или это не первый месяц работы
    is_full_first_month(Scope, PK, Y-M),
    % в месяце есть отработанные часы
    is_month_worked(Scope, PK, Y-M),
    % в месяце есть оплата
    is_month_paid(Scope, PK, Y-M),
    !.

% первый месяц работы полный или это не первый месяц работы
is_full_first_month(Scope, PK, Y-M) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % если для первого движения по типу 1 (прием на работу)
    get_data(Scope, in, usr_wg_MovementLine, [
        fEmplKey-EmplKey, fDocumentKey-FirstMoveKey, fFirstMoveKey-FirstMoveKey,
        fDateBegin-DateBegin, fMovementType-1 ]),
    % где дата совпадает с проверяемым месяцем
    atom_date(DateBegin, date(Y, M, _)),
    % первый рабочий день по графику для проверяемого месяца
    once( get_data(Scope, in, usr_wg_TblDayNorm, [
            fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
            fTheDay-TheDay, fWYear-Y, fWMonth-M, fWorkDay-1 ]) ),
    !,
    % больше или равен дате первого движения
    TheDay @>= DateBegin,
    % то первый месяц работы полный
    !.
is_full_first_month(_, _, _) :-
    % проверяемый месяц не является первым месяцем работы
    !.

% в месяце есть отработанные часы
is_month_worked(Scope, PK, Y-M) :-
    % если есть хотя бы один рабочий день
    usr_wg_TblCalLine_mix(Scope, PK, Date, Duration, _),
    % с контролем наличия часов
    Duration > 0,
    % дата для которого совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % то в месяце есть отработанные часы
    !.

% в месяце есть оплата
is_month_paid(Scope, PK, Y-M) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % если есть хотя бы одно начисление
    get_data(Scope, in, usr_wg_TblCharge, [
        fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
        fDateBegin-Date, fFeeTypeKey-FeeTypeKey ]),
    % соответствующего типа
    get_data(Scope, in, usr_wg_FeeType, [
        fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey, fFeeTypeKey-FeeTypeKey ]),
    % где дата совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % то в месяце есть оплата
    !.

% взять расчетный месяц
get_month_incl(Scope, PK, Y, M, Variant) :-
    append(PK, [pMonthIncl-MonthInclList], Pairs),
    get_param_list(Scope, temp, Pairs),
    member(pMonthIncl-MonthInclList, Pairs),
    member(Y-M-Variant, MonthInclList).

% принять месяц для исчисления
take_month_incl(Scope, PK, Y, M, Variant) :-
    append(PK, [pMonthIncl-MonthInclList], Pairs),
    get_param_list(Scope, temp, Pairs),
    keysort([Y-M-Variant | MonthInclList], MonthInclList1),
    append(PK, [pMonthIncl-MonthInclList1], Pairs1),
    dispose_param_list(Scope, temp, Pairs),
    new_param_list(Scope, temp, Pairs1),
    !.
take_month_incl(Scope, PK, Y, M, Variant) :-
    append(PK, [pMonthIncl-[Y-M-Variant]], Pairs),
    new_param_list(Scope, temp, Pairs),
    !.

% есть хотя бы один расчетный месяц
exist_month_incl(Scope, PK) :-
    get_month_incl(Scope, PK, _, _, _),
    !.

% проверка месяца по табелю
check_month_tab(_, _, []):-
    % больше месяцев для проверки нет
    !.
check_month_tab(Scope, PK, [Y-M|Periods]) :-
    % если месяц значимый
    is_value_month(Scope, PK, Y-M),
    % и выполняется одно из правил
    rule_month_tab(Scope, PK, Y-M, Variant),
    % то принять месяц для исчисления
    take_month_incl(Scope, PK, Y, M, Variant),
    !,
    % проверить остальные месяцы
    check_month_tab(Scope, PK, Periods).
check_month_tab(Scope, PK, [Y-M|Periods]) :-
    % проверить расчет по часам для графика и табеля
    total_houres_norm_tab(Scope, PK, Y-M, _, _),
    !,
    % проверить остальные месяцы
    check_month_tab(Scope, PK, Periods).
check_month_tab(Scope, PK, [_|Periods]) :-
    !,
    % проверить остальные месяцы
    check_month_tab(Scope, PK, Periods).

% добавление временных данных по расчету заработков
add_month_wage(_, _, []):-
    % больше месяцев для проверки нет
    !.
add_month_wage(Scope, PK, [Y-M|Periods]) :-
    % расчитать заработок
    cacl_month_wage(Scope, PK, Y, M, _),
    !,
    % проверить остальные месяцы
    add_month_wage(Scope, PK, Periods).
add_month_wage(Scope, PK, [_|Periods]) :-
    !,
    % проверить остальные месяцы
    add_month_wage(Scope, PK, Periods).

% правила включения месяца в расчет
rule_month_tab(Scope, PK, Y-M, Rule) :-
    % по дням и часам
    Rule = by_day_houres,
    % правило действительно
    is_valid_rule(Rule),
    % расчитать график и табель за месяц
    calc_month_norm_tab(Scope, PK, Y-M, NormDays, TabDays),
    % если все элементы списка графика есть в табеле
    member_list(NormDays, TabDays),
    % то месяц включается в расчет
    !.
rule_month_tab(Scope, PK, Y-M, Rule) :-
    % по часам за месяц
    Rule = by_month_houres,
    % правило действительно
    is_valid_rule(Rule),
    % взять итоги по часам для графика и табеля
    total_houres_norm_tab(Scope, PK, Y-M, MonthNorm, MonthTab),
    % если табель покрывает график по итогам месяца
    MonthTab >= MonthNorm,
    % то месяц включается в расчет
    !.

% итоги по часам для графика и табеля
total_houres_norm_tab(Scope, PK, Y-M, MonthNorm, MonthTab) :-
    append(PK, [pYM-Y-M, pTHoures-MonthTab, pNHoures-MonthNorm], Pairs),
    get_param_list(Scope, temp, Pairs),
    !.
total_houres_norm_tab(Scope, PK, Y-M, MonthNorm, MonthTab) :-
    calc_month_norm_tab(Scope, PK, Y-M, _, _),
    append(PK, [pYM-Y-M, pTHoures-MonthTab, pNHoures-MonthNorm], Pairs),
    get_param_list(Scope, temp, Pairs),
    !.

% расчитать график и табель за месяц
calc_month_norm_tab(Scope, PK, Y-M, NormDays, TabDays) :-
    % расчитать график за месяц
    calc_month_norm(Scope, PK, Y-M, NormDays),
    % график не пустой
    \+ NormDays = [],
    % сумма дней и часов по графику
    sum_days_houres(NormDays, NDays, NHoures),
    % расчитать табель за месяц
    calc_month_tab(Scope, PK, Y-M, TabDays),
    % сумма дней и часов по табелю
    sum_days_houres(TabDays, TDays, THoures),
    % занести во временные параметры дни и часы
    append(PK, [pYM-Y-M,
                pTDays-TDays, pTHoures-THoures,
                pNDays-NDays, pNHoures-NHoures],
                Pairs),
    new_param_list(Scope, temp, Pairs),
    !.

% расчитать график за месяц
calc_month_norm(Scope, PK, Y-M, NormDays) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % взять дату/часы
    findall( TheDay-WDuration,
            % для рабочего дня
            ( get_data(Scope, in, usr_wg_TblDayNorm, [
                fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                fTheDay-TheDay, fWYear-Y, fWMonth-M,
                fWDuration-WDuration, fWorkDay-1 ]),
            % с контролем наличия часов
            WDuration > 0 ),
    % в список дата/часы графика
            NormDays),
    !.

% расчитать табель за месяц
calc_month_tab(Scope, PK, Y-M, TabDays) :-
    % взять дату/часы
    findall( Date-Duration,
            % для отработанного дня
            ( usr_wg_TblCalLine_mix(Scope, PK, Date, Duration, _),
            % с контролем наличия часов
            Duration > 0,
            % дата для которого совпадает с проверяемым месяцем
            atom_date(Date, date(Y, M, _)) ),
    % в список дата/часы табеля
            TabDays),
    !.

% сумма дней и часов
sum_days_houres(ListDays, Days, Houres) :-
    sum_days_houres(ListDays, Days, Houres, 0, 0),
    !.
sum_days_houres([], Days, Houres, Days, Houres).
sum_days_houres([_-Duration|ListDays], Days, Houres, Days0, Houres0) :-
    ( Duration > 0, Days1 is Days0 + 1 ; Days1 = Days0 ),
    Houres1 is Houres0 + Duration,
    !,
    sum_days_houres(ListDays, Days, Houres, Days1, Houres1).

% расчитать заработок за месяц
cacl_month_wage(Scope, PK, Y, M, ModernWage) :-
    append(PK, [pYM-Y-M, pModernWage-ModernWage], Pairs),
    get_param_list(Scope, temp, Pairs),
    !.
cacl_month_wage(Scope, PK, Y, M, ModernWage) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % взять начисления
    findall( Debit-ModernCoef-Rate0-RateLast0,
          % для начисления
          ( get_data(Scope, in, usr_wg_TblCharge, [
                fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                fDateBegin-TheDay, fDebit-Debit, fFeeTypeKey-FeeTypeKey ]),
          % соответствующего типа
          get_data(Scope, in, usr_wg_FeeType, [
                fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                fFeeTypeKey-FeeTypeKey ]),
          % где дата совпадает с проверяемым месяцем
          atom_date(TheDay, date(Y, M, _)),
          % с коэффициентом осовременивания
          get_modern_coef(Scope, PK, TheDay, ModernCoef, Rate0, RateLast0) ),
    % в список начислений
             Debits ),
    % оклад и текущий оклад от первого начисления
    Debits = [ _-_-Rate-RateLast | _ ],
    % всего за месяц
    sum_month_debit(Debits, Wage, ModernWage),
    % средний за месяц коэффициент осовременивания
    catch( MonthModernCoef is float( round( ModernWage / Wage * 10000 ) / 10000 ), _, fail),
    % занести во временные параметры данные по заработку
    append(PK, [pYM-Y-M,
                pWage-Wage, pModernWage-ModernWage,
                pModernCoef-MonthModernCoef,
                pRate-Rate, pRateLast-RateLast],
                Pairs),
    new_param_list(Scope, temp, Pairs),
    !.

% итого зарплата и осовремененная зарплата за месяц
sum_month_debit(Debits, Wage, ModernWage) :-
    sum_month_debit(Debits, Wage, ModernWage, 0, 0),
    !.
sum_month_debit([], Wage, ModernWage, Wage, ModernWage0) :-
    catch( ModernWage is float( round( ModernWage0 * 10000 ) / 10000 ), _, fail),
    !.
sum_month_debit([Debit-ModernCoef-_-_ | Debits], Wage, ModernWage, Wage0, ModernWage0) :-
    Wage1 is Wage0 + Debit,
    ModernWage1 is ModernWage0 + Debit*ModernCoef,
    !,
    sum_month_debit(Debits, Wage, ModernWage, Wage1, ModernWage1).

% коэффициент осовременивания
get_modern_coef(Scope, PK, TheDay, ModernCoef, Rate1, RateLast) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % дата расчета
    find_param(Scope, run, PK, pDateCalc-DateCalc),
    % взять дату и ставку
    findall( DateBegin-Rate,
             % где для движения
             ( get_data(Scope, in, usr_wg_MovementLine, [
                     fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                     fDateBegin-DateBegin, fRate-Rate ]),
             % дата меньше расчетной
             DateBegin @< DateCalc ),
    % в список движений
            Movements ),
    % вычислить коэффициент
    calc_modern_coef(TheDay, Movements, ModernCoef, Rate1, RateLast),
    !.

% вычислить коэффициент
calc_modern_coef(_, [ _-RateLast | [] ], 1.0, RateLast, RateLast) :-
    % если последнее движение, то коэффициент 1
    !.
calc_modern_coef(TheDay, [ Date1-Rate1, Date2-Rate2 | Movements ], ModernCoef, Rate1, RateLast) :-
    % если проверяемая дата больше или равна даты текущего движения
    TheDay @>= Date1,
    % и меньше даты следующего движения
    TheDay @< Date2,
    % то взять последнюю ставку из следующего и всех оставшихся движений
    last([Date2-Rate2 | Movements], _-RateLast),
    % и вычислить коэффициент для текущего движения
    catch( ModernCoef0 is float( round( RateLast / Rate1 * 10000 ) / 10000 ), _, fail),
    ( ModernCoef0 < 1.0, ModernCoef = 1.0 ; ModernCoef = ModernCoef0 ),
    !.
calc_modern_coef(TheDay, [ _ | Movements ], ModernCoef, Rate, RateLast) :-
    % проверить для остальных движений
    !,
    calc_modern_coef(TheDay, Movements, ModernCoef, Rate, RateLast).

% проверка месяца по заработку
check_month_wage(_, _, []):-
    % больше месяцев для проверки нет
    true.
check_month_wage(Scope, PK, [Y-M|Periods]) :-
    % если месяц еще не включен в расчет
    \+ get_month_incl(Scope, PK, Y, M, _),
    % и выполняется одно из правил
    rule_month_wage(Scope, PK, Y-M, Variant),
    % то принять месяц для исчисления
    take_month_incl(Scope, PK, Y, M, Variant),
    !,
    % проверить следующий месяц
    check_month_wage(Scope, PK, Periods).
check_month_wage(Scope, PK, [_|Periods]) :-
    !,
    % проверить следующий месяц
    check_month_wage(Scope, PK, Periods).

% заработок за месяц выше или на уровне каждого из полных месяцев
rule_month_wage(Scope, PK, Y-M, Rule) :-
    Rule = by_month_wage_all,
    % правило действительно
    is_valid_rule(Rule),
    % заработок за проверяемый месяц
    cacl_month_wage(Scope, PK, Y, M, Wage),
    % с коэффициентом осовременивания на первое число месяца
    atom_date(Date, date(Y, M, 1)),
    get_modern_coef(Scope, PK, Date, ModernCoef, _, _),
    % взять заработок
    findall( Wage1,
            % для расчетного месяца
            ( get_month_incl(Scope, PK, Y1, M1, Variant1),
            % с коэффициентом осовременивания на первое число месяца
            atom_date(Date1, date(Y1, M1, 1)),
            get_modern_coef(Scope, PK, Date1, ModernCoef1, _, _),
            % где коэффициент для проверяемого и расчетного равны
            ModernCoef =:= ModernCoef1,
            % который принят для исчисления по варианту полного месяца
            wg_full_month_rules(Rules),
            member(Variant1, Rules),
            % с заработком за месяц
            cacl_month_wage(Scope, PK, Y1, M1, Wage1) ),
    % в список заработков
            Wages1 ),
    % если заработок проверяемого месяца покрывает все из расчетных
    over_list(Wage, Wages1),
    % то месяц включается в расчет
    !.

% проверка месяца по типу начислений
check_month_no_bad_type(_, _, []):-
    % больше месяцев для проверки нет
    true.
check_month_no_bad_type(Scope, PK, [Y-M|Periods]) :-
    % если месяц еще не включен в расчет
    \+ get_month_incl(Scope, PK, Y, M, _),
    % первый месяц работы полный или это не первый месяц работы
    is_full_first_month(Scope, PK, Y-M),
    % в месяце есть оплата
    is_month_paid(Scope, PK, Y-M),
    % и выполняется одно из правил
    rule_month_no_bad_type(Scope, PK, Y-M, Variant),
    % то принять месяц для исчисления
    take_month_incl(Scope, PK, Y, M, Variant),
    !,
    % проверить следующий месяц
    check_month_no_bad_type(Scope, PK, Periods).
check_month_no_bad_type(Scope, PK, [_|Periods]) :-
    !,
    % проверить следующий месяц
    check_month_no_bad_type(Scope, PK, Periods).

% отсутствие плохих типов начислений и часов
rule_month_no_bad_type(Scope, PK, Y-M, Rule) :-
    Rule = by_month_no_bad_type,
    % правило действительно
    is_valid_rule(Rule),
    % если нет плохих типов начислений и часов
    \+ month_bad_type(Scope, PK, Y-M),
    % то месяц включается в расчет
    !.

% есть плохой тип часов
month_bad_type(Scope, PK, Y-M) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % если есть хотя бы один день по табелю
    usr_wg_TblCalLine_mix(Scope, PK, Date, _, HoureType),
    % дата для которого совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % с плохим типом часов
    get_data(Scope, in, usr_wg_BadHourType, [
        fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey, fID-HoureType]),
    !.
% есть плохой тип начислений
month_bad_type(Scope, PK, Y-M) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % если есть хотя бы одно начисление
    get_data(Scope, in, usr_wg_TblCharge, [
        fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
        fDateBegin-Date, fFeeTypeKey-FeeTypeKey ]),
    % где дата совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % с плохим типом начисления
    get_data(Scope, in, usr_wg_BadFeeType,
        [fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey, fID-FeeTypeKey]),
    !.

% день по табелю
usr_wg_TblCalLine_mix(Scope, PK, Date, Duration, HoureType) :-
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    gd_pl_ds(Scope, in, usr_wg_TblCalLine, 5, _),
    catch( usr_wg_TblCalLine(EmplKey, FirstMoveKey, Date, Duration, HoureType), _, fail).
% или по табелю мастера
usr_wg_TblCalLine_mix(Scope, PK, Date, Duration, HoureType) :-
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    gd_pl_ds(Scope, in, usr_wg_TblCal_FlexLine, 65, _),
    make_list(62, TeilArgs),
    Term =.. [ usr_wg_TblCal_FlexLine, EmplKey, FirstMoveKey, DateBegin | TeilArgs ],
    catch( call( Term ), _, fail),
    atom_date(DateBegin, date(Y, M, _)),
    member(D, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
                17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]),
    atom_date(Date, date(Y, M, D)),
    S is (D - 1) * 2 + 1,
    H is S + 1,
    nth1(S, TeilArgs, Duration0),
    once( ( number(Duration0), Duration = Duration0
            ; atom_number(Duration0, Duration)
            ; Duration is 0 ) ),
    nth1(H, TeilArgs, HoureType0),
    once( ( number(HoureType0), HoureType = HoureType0
            ; atom_number(HoureType0, HoureType)
            ; HoureType is 0 ) ).


%% engine_loop(+Scope, +Type, +PK)
%

% args handler
engine_loop(Scope, Type, PK) :-
    \+ ground_list([Scope, Type, PK]),
    !,
    fail.
% fail handler
engine_loop(Scope, _, PK) :-
    engine_fail_step(Type),
    get_param_list(Scope, Type, PK),
    !,
    fail.
% deal handler
engine_loop(Scope, Type, PK) :-
    engine_deal_step(Type),
    !,
    get_param_list(Scope, Type, PK),
    !.
% data handler
engine_loop(Scope, Type, PK) :-
    engine_data_step(Type, TypeNextStep),
    get_param_list(Scope, Type, PK),
    \+ get_param_list(Scope, TypeNextStep, PK),
    prepare_data(Scope, Type, PK, TypeNextStep),
    !,
    engine_loop(Scope, TypeNextStep, PK).
engine_loop(Scope, Type, PK) :-
    engine_data_step(Type, TypeNextStep),
    !,
    engine_loop(Scope, TypeNextStep, PK).
% restart handler
engine_loop(Scope, Type, PK) :-
    engine_restart_step(Type, TypeNextStep),
    forall( ( get_param_list(Scope, ParamType, PK, Pairs),
              \+ ParamType = TypeNextStep ),
            dispose_param_list(Scope, ParamType, Pairs)
          ),
    !,
    engine_loop(Scope, TypeNextStep, PK).
% clean handler
engine_loop(Scope, Type, PK) :-
    engine_clean_step(Type, CleanType, NextType),
    forall( ( get_param_list(Scope, ParamType, PK, Pairs),
              ParamType = CleanType ),
            dispose_param_list(Scope, ParamType, Pairs)
          ),
    once( find_param(Scope, NextType, PK, pConnection-Connection) ),
    forall( ( get_sql(Connection, Query/Arity, _, _),
              current_functor(Query, Arity) ),
            ( length(PK, Len),
              Arity1 is Arity - Len,
              make_list(Arity1, TeilArgs),
              PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
              append([EmplKey, FirstMoveKey], TeilArgs, Args),
              Term =.. [Query | Args ],
              retractall( Term ) )
            ),
    garbage_collect,
    !.
% error handler
engine_loop(Scope, Type, PK) :-
    engine_error_step(TypeNextStep),
    \+ get_param_list(Scope, TypeNextStep, PK),
    get_local_date_time(DT),
    append(PK, [Type, DT], PairsNextStep),
    new_param_list(Scope, TypeNextStep, PairsNextStep),
    !,
    fail.

%
engine_data_step(in, run).
engine_data_step(run, query).
engine_data_step(query, data).
%
engine_deal_step(run) :-
    debug_mode,
    !.
engine_deal_step(data).
%
engine_fail_step(out).
engine_fail_step(error).
%
engine_restart_step(restart, in).
%
engine_clean_step(clean, data, query).
%
engine_error_step(error).

 %
%%

%% prepare_data(+Scope, +Type, +PK, +TypeNextStep)
% wg_avg_wage-in-run
prepare_data(Scope, Type, PK, TypeNextStep) :-
    Scope = wg_avg_wage, Type = in, TypeNextStep = run,
    get_param_list(Scope, Type,
            [pConnection-_, pMonthQty-MonthQty], ConnectionPairs),
    get_param_list(Scope, Type, PK, Pairs),
    member_list([pDateCalc-DateCalc, pMonthOffset-MonthOffset], Pairs),
    %
    atom_date(DateCalc, date(Y0, M0, _)),
    atom_date(DateCalcTo0, date(Y0, M0, 1)),
    MonthOffset1 is (- MonthOffset),
    date_add(DateCalcTo0, MonthOffset1, month, DateCalcTo),
    MonthAdd is (- MonthQty),
    date_add(DateCalcTo, MonthAdd, month, DateCalcFrom),
    date_add(DateCalcTo, -1, day, DateCalcTo1),
    atom_date(DateCalcTo1, date(Y, _, _)),
    atom_date(DateNormFrom, date(Y, 1, 1)),
    Y1 is Y + 1,
    atom_date(DateNormTo, date(Y1, 1, 1)),
    %
    append(Pairs,
            [pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo,
            pDateNormFrom-DateNormFrom, pDateNormTo-DateNormTo
            |ConnectionPairs],
        PairsNextStep),
    new_param_list(Scope, TypeNextStep, PairsNextStep),
    !.
% wg_avg_wage-run-query
prepare_data(Scope, Type, PK, TypeNextStep) :-
    Scope = wg_avg_wage, Type = run, TypeNextStep = query,
    get_param_list(Scope, Type, PK, Pairs),
    member(pConnection-Connection, Pairs),
    forall( ( get_sql(Connection, Query, SQL, Params),
              member_list(Params, Pairs),
              prepare_sql(SQL, Params, PrepSQL),
              \+ find_param_list(Scope, TypeNextStep, PK,
                    [pConnection-Connection, pQuery-Query, pSQL-PrepSQL])
            ),
            ( append(PK,
                [pConnection-Connection, pQuery-Query, pSQL-PrepSQL],
                PairsNextStep),
              new_param_list(Scope, TypeNextStep, PairsNextStep)
            )
          ),
    !.
% подготовка SQL-строки
prepare_sql(InSQL, [], InSQL).
prepare_sql(InSQL,[Key-Value|Pairs], OutSQL) :-
    replace_all(InSQL, Key, Value, InSQL1),
    prepare_sql(InSQL1, Pairs, OutSQL).
 %
%%

%% расширение для клиента
%

% загрузка входных данных по сотруднику
avg_wage_in(EmplKey, FirstMoveKey, DateCalc) :-
    avg_wage_in(EmplKey, FirstMoveKey, DateCalc, 0).
%
avg_wage_in(EmplKey, FirstMoveKey, DateCalc0, MonthOffset) :-
    Scope = wg_avg_wage, Type = in,
    ( is_date(DateCalc0), DateCalc = DateCalc0
      ;
      atom_chars(DateCalc0, [D1, D2, '.', M1, M2, '.', Y1, Y2, Y3, Y4]),
      atom_chars(DateCalc, [Y1, Y2, Y3, Y4, '-', M1, M2, '-', D1, D2])
    ),
    new_param_list(Scope, Type,
        [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
         pDateCalc-DateCalc, pMonthOffset-MonthOffset]),
    !.

% загрузка общих входных параметров
avg_wage_in_public(Connection, MonthQty, AvgDays,
                    FeeGroupKey_xid, FeeGroupKey_dbid,
                    BadHourType_xid_IN, BadHourType_dbid,
                    BadFeeType_xid_IN, BadFeeType_dbid) :-
    Scope = wg_avg_wage, Type = in,
    new_param_list(Scope, Type,
        [pConnection-Connection,
        pMonthQty-MonthQty, pAvgDays-AvgDays,
        pFeeGroupKey_xid-FeeGroupKey_xid,
        pFeeGroupKey_dbid-FeeGroupKey_dbid,
        pBadHourType_xid_IN-BadHourType_xid_IN,
        pBadHourType_dbid-BadHourType_dbid,
        pBadFeeType_xid_IN-BadFeeType_xid_IN,
        pBadFeeType_dbid-BadFeeType_dbid]),
    !.

% выгрузка данных выполнения по сотруднику
avg_wage_run(EmplKey, FirstMoveKey, DateCalcFrom, DateCalcTo) :-
    Scope = wg_avg_wage, Type = run,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    append(PK, [pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo], Pairs),
    get_param_list(Scope, Type, Pairs).
    
% выгрузка SQL-запросов по сотруднику
avg_wage_sql(EmplKey, FirstMoveKey, Connection, PredicateName, Arity, SQL) :-
    Scope = wg_avg_wage, Type = query, TypeNextStep = data,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    Query = PredicateName/Arity,
    find_param_list(Scope, Type, PK,
            [pConnection-Connection, pQuery-Query, pSQL-SQL]),
    \+ find_param_list(Scope, TypeNextStep, PK,
            [pConnection-Connection, pQuery-Query, pSQL-SQL]).

% подтвеждение формирования фактов по сотруднику
avg_wage_kb(EmplKey, FirstMoveKey, Connection, PredicateName, Arity, SQL) :-
    Scope = wg_avg_wage, Type = query, TypeNextStep = data,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    Query = PredicateName/Arity,
    find_param_list(Scope, Type, PK,
            [pConnection-Connection, pQuery-Query, pSQL-SQL]),
    \+ find_param_list(Scope, TypeNextStep, PK,
            [pConnection-Connection, pQuery-Query, pSQL-SQL]),
    append(PK,
            [pConnection-Connection, pQuery-Query, pSQL-SQL],
            PairsNextStep),
    new_param_list(Scope, TypeNextStep, PairsNextStep),
    !.

% выгрузка выходных данных по сотруднику
avg_wage_out(EmplKey, FirstMoveKey, AvgWage, Variant) :-
    Scope = wg_avg_wage, Type = out,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    append(PK, [pAvgWage-AvgWage, pVariant-Variant], Pairs),
    get_param_list(Scope, Type, Pairs).

% выгрузка детальных выходных данных по сотруднику
avg_wage_det(EmplKey, FirstMoveKey, Period, Rule, Wage, ModernWage, ModernCoef,
                TabDays, TabHoures, NormDays, NormHoures,
                Rate, RateLast) :-
    Scope = wg_avg_wage,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    %
    append(PK, [pYM-Y-M,
                    pTDays-TabDays, pTHoures-TabHoures,
                    pNDays-NormDays, pNHoures-NormHoures],
            Pairs),
    get_param_list(Scope, temp, Pairs),
    %
    atom_date(Period, date(Y, M, 1)),
    %
    once( ( find_param_list(Scope, temp, PK, [pMonthIncl-MonthIncl|_])
            ; MonthIncl = [] ) ),
    once( ( member(Y-M-Rule, MonthIncl) ; Rule = none ) ),
    %
    once( ( ( append(PK, [pYM-Y-M,
                            pWage-Wage, pModernWage-ModernWage,
                            pModernCoef-ModernCoef,
                            pRate-Rate, pRateLast-RateLast],
                    Pairs1),
              get_param_list(Scope, temp, Pairs1) )
            ;
              [Wage, ModernWage, ModernCoef, Rate, RateLast] = [0, 0, 1, 0, 0]
          ) ),
    %
    TabHoures > 0, Wage > 0,
    %
    true.

% удаление данных по сотруднику
avg_wage_clean(EmplKey, FirstMoveKey) :-
    Scope = wg_avg_wage,
    get_type_list(TypeList),
    member(Type, TypeList),
    gd_pl_ds(Scope, Type, Name, _, _),
    del_data(Scope, Type, Name, [fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey]),
    fail.
avg_wage_clean(EmplKey, FirstMoveKey) :-
    Scope = wg_avg_wage,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    get_param_list(Scope, Type, PK, Pairs),
    dispose_param_list(Scope, Type, Pairs),
    fail.
avg_wage_clean(_, _) :-
    !.

 %
%%