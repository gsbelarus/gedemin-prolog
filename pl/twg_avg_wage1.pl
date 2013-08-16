%
:- ensure_loaded(lib).
:- ensure_loaded(date).
:- ensure_loaded(params).
:- ensure_loaded(sql1).
%

% варианты правил расчета
wg_valid_rules([by_calc_month, by_avg_houre]).
wg_valid_rules([by_day_houres, by_month_houres]).
wg_valid_rules([by_month_wage_all, -by_month_wage_avg, -by_month_wage_one]).
wg_valid_rules([by_month_no_bad_type]).

% варианты правил полных месяцев
wg_full_month_rules([by_day_houres, by_month_houres]).

% правило действительно
is_valid_rule(Rule) :-
    wg_valid_rules(ValidRules),
    member(Rule, ValidRules),
    !.

% среднедневной заработок
avg_wage :-
    % объявить параметры контекста
    Scope = wg_avg_wage, PK = [pEmplKey-_],
    % для каждого первичного ключа расчета из входных параметров
    get_param_list(Scope, in, PK),
    % подготовить данные
    engine_loop(Scope, in, PK),
    % вычислить среднедневной заработок по сотруднику
    avg_wage(Scope, PK, AvgWage, Variant),
    % сформировать выходные параметры
    append(PK, [pAvgWage-AvgWage, pVariant-Variant], OutPairs),
    new_param_list(Scope, out, OutPairs),
    % найти альтернативу
    writeln( PK ),
    fail.
avg_wage :-
    % завершить вычисления
    Scope = wg_avg_wage, PK = [pEmplKey-_],
    forall(
        % для каждого первичного ключа расчета из входных параметров
        ( get_param_list(Scope, in, PK, InPairs),
        % вывести результат расчета
        find_param_list(Scope, temp, PK, TempPairs),
        find_param_list(Scope, out, PK, OutPairs) ),
        writeln( InPairs-OutPairs-TempPairs )
          ).

% среднедневной заработок по сотруднику (по расчетным месяцам)
avg_wage(Scope, PK, AvgWage, Rule) :-
    Rule = by_calc_month,
    % правило действительно
    is_valid_rule(Rule),
    % удаление временных параметров
    forall( get_param_list(Scope, temp, PK, Pairs),
            dispose_param_list(Scope, temp, Pairs) ),
    % периоды для проверки
    get_periods(Scope, PK, Periods),
    % проверка по табелю
    check_month_tab(Scope, PK, Periods),
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
avg_wage(Scope, PK, AvgWage, Rule) :-
    Rule = by_avg_houre,
    % правило действительно
    is_valid_rule(Rule),
    % периоды для проверки
    get_periods(Scope, PK, Periods),
    % взять заработок
    findall( Wage,
             % за период проверки
             ( member(Y-M, Periods),
             % расчитать заработок
             cacl_month_wage(Scope, PK, Y, M, Wage) ),
    % в список заработков
             Wages ),
    % общий заработок по табелю
    sum_list(Wages, Amount),
    % взять часы
    findall( Duration,
             % за период проверки
             ( member(Y-M, Periods),
             % для отработанного дня
             usr_wg_TblCalLine1(PK, _, Date, Duration, _),
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
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % дата расчета
    get_param(Scope, run, pDateCalc-DateCalc),
    % год расчета
    atom_date(DateCalc, date(CalcYear, _, _)),
    % взять часы
    findall( WDuration,
            % для рабочего дня
            ( usr_wg_TblCalDay(EmplKey, TheDay, WDuration, 1, TblCalKey),
            % с контролем наличия часов
            WDuration > 0,
            % по типу графика
            get_schedule(PK, TheDay, TblCalKey),
            % дата для которого совпадает с проверяемым годом
            atom_date(TheDay, date(CalcYear, _, _)) ),
    % в список дата/часы графика
            WDurations),
    % всего часов по графику
    sum_list(WDurations, TotalNorm),
    % среднемесячное количество расчетных рабочих часов
    catch( AvgMonthNorm is TotalNorm / 12, _, fail ),
    % среднемесячное количество календарных дней
    get_param(Scope, in, pAvgDays-AvgDays),
    % среднедневной заработок
    catch( AvgWage0 is  AvgHoureWage * AvgMonthNorm / AvgDays, _, fail),
    AvgWage is float( round(AvgWage0) ),
    !.

% периоды для проверки
get_periods(Scope, PK, Periods) :-
    find_param_list(Scope, run, PK, List),
    member_list([pDateCalcFrom-DateFrom, pDateCalcTo-DateTo], List),
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

% месяц полный
is_full_month(PK, Y-M) :-
    % первый месяц работы полный или это не первый месяц работы
    is_full_first_month(PK, Y-M),
    % в месяце есть отработанные часы
    is_month_worked(PK, Y-M),
    % в месяце есть оплата
    is_month_paid(PK, Y-M),
    !.

% первый месяц работы полный или это не первый месяц работы
is_full_first_month(PK, Y-M) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % если для первого движения по типу 1 (прием на работу)
    usr_wg_MovementLine(EmplKey, DocKey, DocKey, DateBegin, ScheduleKey, 1, _),
    % где дата совпадает с проверяемым месяцем
    atom_date(DateBegin, date(Y, M, _)),
    % первый рабочий день по типу графика первого движения
    once( ( usr_wg_TblCalDay(EmplKey, TheDay, _, 1, ScheduleKey),
    % дата для которого совпадает с проверяемым месяцем
    atom_date(TheDay, date(Y, M, _)) ) ),
    !,
    % больше или равен дате первого движения
    TheDay @>= DateBegin,
    % то первый месяц работы полный
    true.
is_full_first_month(_, _) :-
    % проверяемый месяц не является первым месяцем работы
    !.

% в месяце есть отработанные часы
is_month_worked(PK, Y-M) :-
    % если есть хотя бы один рабочий день
    usr_wg_TblCalLine1(PK, _, Date, Duration, _),
    % с контролем наличия часов
    Duration > 0,
    % дата для которого совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % то в месяце есть отработанные часы
    !.

% в месяце есть оплата
is_month_paid(PK, Y-M) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % если есть хотя бы одно начисление
    wg_TblCharge(EmplKey, _, Date, _, FeeTypeKey),
    % соответствующего типа
    usr_wg_FeeType(EmplKey, _, FeeTypeKey),
    % где дата совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % то в месяце есть оплата
    !.
% взять расчетный месяц
get_month_incl(Scope, PK, Y, M, Variant) :-
    get_param_list(Scope, temp, PK, Pairs),
    member(pMonthIncl-MonthInclList, Pairs),
    member(Y-M-Variant, MonthInclList).

% принять месяц для исчисления
take_month_incl(Scope, PK, Y, M, Variant) :-
    get_param_list(Scope, temp, PK, Pairs),
    member(pMonthIncl-MonthInclList, Pairs),
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
    % если месяц полный
    is_full_month(PK, Y-M),
    % и выполняется одно из правил
    rule_month_tab(PK, Y-M, Variant),
    % то принять месяц для исчисления
    take_month_incl(Scope, PK, Y, M, Variant),
    !,
    % проверить остальные месяцы
    check_month_tab(Scope, PK, Periods).
check_month_tab(Scope, PK, [_|Periods]) :-
    !,
    % проверить остальные месяцы
    check_month_tab(Scope, PK, Periods).

% правила включения месяца в расчет
rule_month_tab(PK, Y-M, Rule) :-
    Rule = by_day_houres,
    % правило действительно
    is_valid_rule(Rule),
    % расчитать график за месяц
    calc_month_norm(PK, Y-M, NormDays),
    % расчитать табель за месяц
    calc_month_tab(PK, Y-M, TabDays),
    % если все элементы списка графика есть в табеле
    member_list(NormDays, TabDays),
    % то месяц включается в расчет
    !.
rule_month_tab(PK, Y-M, Rule) :-
    Rule = by_month_houres,
    % правило действительно
    is_valid_rule(Rule),
    % расчитать график за месяц
    calc_month_norm(PK, Y-M, NormDays),
    % всего часов за месяц по табелю
    findall( WDuration, member(_-WDuration, NormDays), WDurations),
    sumlist(WDurations, MonthNorm),
    % расчитать табель за месяц
    calc_month_tab(PK, Y-M, TabDays),
    % всего часов за месяц по графику
    findall( Duration, member(_-Duration, TabDays), Durations),
    sumlist(Durations, MonthTab),
    % если табель покрывает график по итогам месяца
    MonthTab >= MonthNorm,
    % то месяц включается в расчет
    !.

% расчитать график за месяц
calc_month_norm(PK, Y-M, NormDays) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % взять дату/часы
    findall( TheDay-WDuration,
            % для рабочего дня
            ( usr_wg_TblCalDay(EmplKey, TheDay, WDuration, 1, TblCalKey),
            % с контролем наличия часов
            WDuration > 0,
            % по типу графика
            get_schedule(PK, TheDay, TblCalKey),
            % дата для которого совпадает с проверяемым месяцем
            atom_date(TheDay, date(Y, M, _)) ),
    % в список дата/часы графика
            NormDays),
    % график не пустой
    \+ NormDays = [],
    !.

% расчитать табель за месяц
calc_month_tab(PK, Y-M, TabDays) :-
    % взять дату/часы
    findall( Date-Duration,
            % для отработанного дня
            ( usr_wg_TblCalLine1(PK, _, Date, Duration, _),
            % с контролем наличия часов
            Duration > 0,
            % дата для которого совпадает с проверяемым месяцем
            atom_date(Date, date(Y, M, _)) ),
    % в список дата/часы табеля
            TabDays),
    % табель не пустой
    \+ TabDays = [],
    !.

% тип графика
get_schedule(PK, TheDay, ScheduleKey) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    findall( % взять тип графика
             DateBegin-ScheduleKey0,
               % где для движения
             ( usr_wg_MovementLine(EmplKey, _, _, DateBegin, ScheduleKey0, _, _),
               % начальная дата меньше или равна проверяемой дате
               once( ( DateBegin @=< TheDay
               % или первый день месяца меньше или равен проверяемой дате
                       ; atom_date(DateBegin, date(Y, M, _)),
                       atom_date(DateBegin1, date(Y, M, 1)),
                       DateBegin1 @=< TheDay ) )
             ),
             % в список типов
             ScheduleKeys ),
    % взять последний тип из списка
    last(ScheduleKeys, _-ScheduleKey),
    !.

% расчитать заработок за месяц
cacl_month_wage(Scope, PK, Y, M, Wage) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % взять формулу
    findall( Debit*ModernCoef,
          % для начисления
          ( wg_TblCharge(EmplKey, _, Date, Debit, FeeTypeKey),
          % соответствующего типа
          usr_wg_FeeType(EmplKey, _, FeeTypeKey),
          % где дата совпадает с проверяемым месяцем
          atom_date(Date, date(Y, M, _)),
          % с коэффициентом осовременивания
          get_modern_coef(Scope, PK, Date, ModernCoef) ),
    % в список начислений
             Debits ),
    % всего за месяц
    sum_list(Debits, Wage),
    !.

% коэффициент осовременивания
get_modern_coef(Scope, PK, TheDay, ModernCoef) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % дата расчета
    get_param(Scope, run, pDateCalc-DateCalc),
    % взять дату и ставку
    findall( DateBegin-Rate,
             % где для движения
             ( usr_wg_MovementLine(EmplKey, _, _, DateBegin, _, _, Rate),
             % дата меньше расчетной
             DateBegin @< DateCalc ),
    % в список движений
            Movements ),
    % вычислить коэффициент
    calc_modern_coef(TheDay, Movements, ModernCoef),
    !.

% вычислить коэффициент
calc_modern_coef(TheDay, [ Date1-Rate1, Date2-Rate2 | Movements ], ModernCoef) :-
    % если проверяемая дата больше или равна даты текущего движения
    TheDay @>= Date1,
    % и меньше даты следующего движения
    TheDay @< Date2,
    % то взять последнюю ставку
    last([Date2-Rate2 | Movements], _-RateLast),
    % и вычислить коэффициент для текущего движения
    ModernCoef is RateLast/Rate1,
    !.
calc_modern_coef(TheDay, [ _ | Movements ], ModernCoef) :-
    % проверить для остальных движений
    !,
    calc_modern_coef(TheDay, Movements, ModernCoef).
calc_modern_coef(_, _, 1.0) :-
    % если коэффициент не может быть вычислен, то его значение 1
    !.

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
rule_month_wage(Scope, PK, YM, Rule) :-
    Rule = by_month_wage_all,
    % правило действительно
    is_valid_rule(Rule),
    % если для каждого из расчетных месяцев
    forall(
        % взять заработки проверяемого и одного из расчетных
        month_wage_check_calc(Scope, PK, YM, Wage, Wage1),
        % заработок проверяемого месяца покрывает расчетный
        Wage >= Wage1
          ),
    % то месяц включается в расчет
    !.
% заработок за месяц выше или на уровне среднего по полным месяцам
rule_month_wage(Scope, PK, Y-M, Rule) :-
    Rule = by_month_wage_avg,
    % правило действительно
    is_valid_rule(Rule),
    % заработок за проверяемый месяц
    cacl_month_wage(Scope, PK, Y, M, Wage),
    % взять заработок
    findall( Wage1,
             % для расчетного месяца
             ( get_month_incl(Scope, PK, Y1, M1, Variant1),
             % по варианту полного месяца
             wg_full_month_rules(Rules),
             member(Variant1, Rules),
             % расчитать заработок
             cacl_month_wage(Scope, PK, Y1, M1, Wage1) ),
    % в список заработков
             Wages1 ),
    % общий заработок за полные месяцы
    sum_list(Wages1, Amount),
    % количество полных месяцев
    length(Wages1, Num),
    % средний заработок за полные месяцы
    catch( AvgMonthWage is Amount / Num, _, fail),
    % заработок проверяемого месяца покрывает средний
    Wage >= AvgMonthWage,
    !.
% заработок за месяц выше или на уровне одного из полных месяцев
rule_month_wage(Scope, PK, YM, Rule) :-
    Rule = by_month_wage_one,
    % правило действительно
    is_valid_rule(Rule),
    % если заработок за проверяемый месяц
    month_wage_check_calc(Scope, PK, YM, Wage, Wage1),
    % покрывает заработок какого-либо из расчетных месяцев
    Wage >= Wage1,
    % то месяц включается в расчет
    !.

% заработки за проверяемый и один из расчетных месяцев
month_wage_check_calc(Scope, PK, Y-M, Wage, Wage1) :-
    % заработок за проверяемый месяц
    cacl_month_wage(Scope, PK, Y, M, Wage),
    atom_date(Date, date(Y, M, 1)),
    get_modern_coef(Scope, PK, Date, ModernCoef),
    % для расчетного месяца
    get_month_incl(Scope, PK, Y1, M1, Variant1),
    atom_date(Date1, date(Y1, M1, 1)),
    get_modern_coef(Scope, PK, Date1, ModernCoef1),
    ModernCoef =:= ModernCoef1,
    % по варианту полного месяца
    wg_full_month_rules(Rules),
    member(Variant1, Rules),
    % заработок за расчетный месяц
    cacl_month_wage(Scope, PK, Y1, M1, Wage1).

% проверка месяца по типу начислений
check_month_no_bad_type(_, _, []):-
    % больше месяцев для проверки нет
    true.
check_month_no_bad_type(Scope, PK, [Y-M|Periods]) :-
    % если месяц еще не включен в расчет
    \+ get_month_incl(Scope, PK, Y, M, _),
    % месяц полный
    is_full_month(PK, Y-M),
    % и выполняется одно из правил
    rule_month_no_bad_type(PK, Y-M, Variant),
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
rule_month_no_bad_type(PK, Y-M, Rule) :-
    Rule = by_month_no_bad_type,
    % правило действительно
    is_valid_rule(Rule),
    % если нет плохих типов начислений и часов
    month_no_bad_type(PK, Y-M),
    % то месяц включается в расчет
    !.

% есть плохой тип начислений
month_no_bad_type(PK, Y-M) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % если есть хотя бы одно начисление
    wg_TblCharge(EmplKey, _, Date, _, FeeTypeKey),
    % где дата совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % с плохим типом начисления
    bad_fee_type(FeeTypeKey),
    % то месяц не включается в расчет
    !,
    fail.
% есть плохой тип часов
month_no_bad_type(PK, Y-M) :-
    % если есть хотя бы один рабочий день
    usr_wg_TblCalLine1(PK, _, Date, _, HoureType),
    % дата для которого совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % с плохим типом часов
    bad_houre_type(HoureType),
    % то месяц не включается в расчет
    !,
    fail.
% есть часы и начисление
month_no_bad_type(PK, Y-M) :-
    % если в проверяемом месяце есть отработанные часы
    is_month_worked(PK, Y-M),
    % и есть оплата
    is_month_paid(PK, Y-M),
    % то месяц включается в расчет
    !.

% плохие типы начислений
bad_fee_type(150998870). % Б 80%

% плохие типы часов
bad_houre_type(147060485). % УБЗ
bad_houre_type(147060501). % Т
bad_houre_type(147060503). % А

%% engine_loop(+Scope, +Type, +PK)
% args handler
engine_loop(Scope, Type, PK) :-
    \+ ground_list([Scope, Type, PK]),
    !,
    fail.
% restart handler
engine_loop(Scope, Type, PK) :-
    engine_restart_step(Type, TypeNextStep),
    forall( ( get_param_list(Scope, ParamType, PK, Pairs),
              \+ ParamType = TypeNextStep ),
            dispose_param_list(Scope, ParamType, Pairs)
          ),
    !,
    engine_loop(Scope, TypeNextStep, PK).
% stop handler
engine_loop(Scope, Type, PK) :-
    engine_stop_step(Type),
    get_param_list(Scope, Type, PK, _),
    !.
% data handler
engine_loop(Scope, Type, PK) :-
    engine_data_step(Type, TypeNextStep),
    get_param_list(Scope, Type, PK, _),
    \+ get_param_list(Scope, TypeNextStep, PK, _),
    prepare_data(Scope, Type, PK, TypeNextStep),
    !,
    engine_loop(Scope, TypeNextStep, PK).
% fail stop handler
engine_loop(Scope, _, PK) :-
    engine_stop_step(Type),
    get_param_list(Scope, Type, PK, _),
    !,
    fail.
% error handler
engine_loop(Scope, Type, PK) :-
    engine_error_step(TypeNextStep),
    \+ get_param_list(Scope, TypeNextStep, PK, _),
    get_date_time(DT),
    append(PK, [Type, DT], PairsNextStep),
    new_param_list(Scope, TypeNextStep, PairsNextStep),
    !,
    fail.
% deadlock
engine_loop(_, _, _) :-
    !.

%
engine_restart_step(restart, in).
%
engine_data_step(in, run).
engine_data_step(run, query).
engine_data_step(query, data).
%
engine_stop_step(data).
engine_stop_step(out).
engine_stop_step(got).
engine_stop_step(error).
%
engine_error_step(error).
%%

%% prepare_data(+Scope, +Type, +PK, +TypeNextStep)
% wg_avg_wage-in-run
prepare_data(Scope, Type, PK, TypeNextStep) :-
    Scope = wg_avg_wage, Type = in, TypeNextStep = run,
    get_param_list(Scope, Type,
        [pConnection-Connection, pMonthQty-MonthQty, pFeeGroupKey-FeeGroupKey]),
    get_param_list(Scope, Type, PK, Pairs),
    member_list([pDateCalc-DateCalc], Pairs),
    % calc run data
    atom_date(DateCalc, date(Y,M,_)), atom_date(DateCalcTo, date(Y,M,1)),
    MonthAdd is -MonthQty, date_add(DateCalcTo, MonthAdd, month, DateCalcFrom),
    atom_date(DateNormFrom0, date(Y,1,1)),
    ( DateNormFrom0 @> DateCalcFrom, DateNormFrom = DateCalcFrom
      ; DateNormFrom = DateNormFrom0 ),
    Y1 is Y + 1, atom_date(DateNormTo, date(Y1,1,1)),
    %
    append(Pairs,
        [pConnection-Connection, pFeeGroupKey-FeeGroupKey,
         pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo,
         pDateNormFrom-DateNormFrom, pDateNormTo-DateNormTo],
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
              \+ get_param_list(Scope, TypeNextStep,
                    [pConnection-Connection, pQuery-Query, pSQL-PrepSQL])
            ),
            ( append(PK,
                [pConnection-Connection, pQuery-Query, pSQL-PrepSQL],
                PairsNextStep),
              new_param_list(Scope, TypeNextStep, PairsNextStep)
            )
          ),
    !.
% wg_avg_wage-query-data
prepare_data(Scope, Type, PK, TypeNextStep) :-
    Scope = wg_avg_wage, Type = query, TypeNextStep = data,
    forall( ( find_param_list(Scope, Type, PK,
                  [pConnection-Connection, pQuery-Query, pSQL-SQL]),
              \+ get_param_list(Scope, TypeNextStep,
                    [pConnection-Connection, pQuery-Query, pSQL-SQL])
            ),
            ( set_connection(Connection),
              forall( odbc_query(Connection, SQL, Rec),
                      assert_record([Query], Rec) ),
              close_connection(Connection),
              append(PK,
                [pConnection-Connection, pQuery-Query, pSQL-SQL],
                PairsNextStep),
              new_param_list(Scope, TypeNextStep, PairsNextStep)
            )
          ),
    !.
%

% взять день по табелю
usr_wg_TblCalLine1(PK, FirstMoveKey, Date, Duration, HoureType) :-
    PK = [pEmplKey-EmplKey],
    usr_wg_TblCalLine(EmplKey, FirstMoveKey, Date, Duration, HoureType).
% или по табелю мастера
usr_wg_TblCalLine1(PK, FirstMoveKey, Date, Duration, HoureType) :-
    PK = [pEmplKey-EmplKey],
    make_list(62, List),
    Term =.. [ usr_wg_TblCal_FlexLine, EmplKey, FirstMoveKey, DateBegin | List ],
    catch( call( Term ), _, fail),
    atom_date(DateBegin, date(Y, M, _)),
    member(D, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
        17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]),
    atom_date(Date, date(Y, M, D)),
    S is (D - 1) * 2 + 1,
    H is S + 1,
    nth1(S, List, Duration0),
    once( ( number(Duration0), Duration = Duration0
            ; atom_number(Duration0, Duration)
            ; Duration is 0 ) ),
    nth1(H, List, HoureType0),
    once( ( number(HoureType0), HoureType = HoureType0
            ; atom_number(HoureType0, HoureType)
            ; HoureType is 0) ).

%
