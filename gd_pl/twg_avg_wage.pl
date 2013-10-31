% twg_avg_wage

:- retractall(debug_mode).

%/* %%% begin debug mode section

%% saved state
:- [load_atom, date, dataset].
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
:-
    [
    usr_wg_MovementLine,
    usr_wg_TblCalDay,
    usr_wg_TblCalLine,
    usr_wg_TblCal_FlexLine,
    usr_wg_HourType,
    wg_TblCharge,
    usr_wg_FeeType,
    usr_wg_BadHourType,
    usr_wg_BadFeeType
    ].
%%

%% dynamic state
:-
    [param_list].
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
avg_wage:-
    % объявить параметры контекста
    Scope = wg_avg_wage, PK = [pEmplKey-EmplKey],
    % для каждого первичного ключа расчета из входных параметров
    get_param_list(Scope, in, PK),
    % подготовить данные
    engine_loop(Scope, in, PK),
    get_local_date_time(DT1),
    new_param_list(Scope, debug, [begin-DT1|PK]),
    % вычислить среднедневной заработок по сотруднику
    avg_wage(Scope, PK, AvgWage, Variant),
    % сформировать выходные параметры
    once( get_data(Scope, in, usr_wg_MovementLine,
                [fEmplKey-EmplKey, fMovementType-1, fListNumber-ListNumber]) ),
    append(PK, [pListNumber-ListNumber, pAvgWage-AvgWage, pVariant-Variant], OutPairs),
    new_param_list(Scope, out, OutPairs),
    get_local_date_time(DT2),
    new_param_list(Scope, debug, [end-DT2|PK]),
    % найти альтернативу
    fail.
avg_wage :-
    % больше альтернатив нет
    !.

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
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
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
             usr_wg_TblCalLine1(Scope, PK, _, Date, Duration, _),
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
    % дата расчета
    find_param(Scope, run, PK, pDateCalc-DateCalc),
    % год расчета
    atom_date(DateCalc, date(CalcYear, _, _)),
    % взять часы
    findall( WDuration,
            % для рабочего дня
            ( get_data(Scope, in, usr_wg_TblCalDay, [
                fEmplKey-EmplKey, fTheDay-TheDay, fWDuration-WDuration,
                fWorkDay-1, fTblCalKey-TblCalKey ]),
            % с контролем наличия часов
            WDuration > 0,
            % по типу графика
            get_schedule(Scope, PK, TheDay, TblCalKey),
            % дата для которого совпадает с проверяемым годом
            atom_date(TheDay, date(CalcYear, _, _)) ),
    % в список часов графика
            WDurations),
    % всего часов по графику
    sum_list(WDurations, TotalNorm),
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

% первый месяц работы
is_first_month(Scope, PK, Y-M) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % для первого движения по типу 1 (прием на работу)
    get_data(Scope, in, usr_wg_MovementLine,
        [fEmplKey-EmplKey, fDateBegin-DateBegin, fMovementType-1]),
    % дата совпадает с проверяемым месяцем
    atom_date(DateBegin, date(Y, M, _)),
    !.

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
    PK = [pEmplKey-EmplKey],
    % если для первого движения по типу 1 (прием на работу)
    get_data(Scope, in, usr_wg_MovementLine, [
        fEmplKey-EmplKey, fDocumentKey-DocKey, fFirstMove-DocKey,
        fDateBegin-DateBegin, fScheduleKey-ScheduleKey, fMovementType-1 ]),
    % где дата совпадает с проверяемым месяцем
    atom_date(DateBegin, date(Y, M, _)),
    % первый рабочий день по типу графика первого движения
    once( ( get_data(Scope, in, usr_wg_TblCalDay, [
                fEmplKey-EmplKey, fTheDay-TheDay,
                fWorkDay-1, fTblCalKey-ScheduleKey ]),
    % дата для которого совпадает с проверяемым месяцем
    atom_date(TheDay, date(Y, M, _)) ) ),
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
    usr_wg_TblCalLine1(Scope, PK, _, Date, Duration, _),
    % с контролем наличия часов
    Duration > 0,
    % дата для которого совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % то в месяце есть отработанные часы
    !.

% в месяце есть оплата
is_month_paid(Scope, PK, Y-M) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % если есть хотя бы одно начисление
    get_data(Scope, in, wg_TblCharge, [
        fEmplKey-EmplKey, fDateBegin-Date, fFeeTypeKey-FeeTypeKey ]),
    % соответствующего типа
    get_data(Scope, in, usr_wg_FeeType, [
        fEmplKey-EmplKey, fFeeTypeKey-FeeTypeKey ]),
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
    % расчитать график и табель за месяц
    calc_month_norm_tab(Scope, PK, Y-M, _, _),
    !,
    % проверить остальные месяцы
    check_month_tab(Scope, PK, Periods).
check_month_tab(Scope, PK, [_|Periods]) :-
    !,
    % проверить остальные месяцы
    check_month_tab(Scope, PK, Periods).

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

%
total_houres_norm_tab(Scope, PK, Y-M, MonthNorm, MonthTab) :-
    get_param_list(Scope, temp, PK, Pairs),
    member_list([pYM-Y-M, pTHoures-MonthTab, pNHoures-MonthNorm], Pairs),
    !.
total_houres_norm_tab(Scope, PK, Y-M, MonthNorm, MonthTab) :-
    calc_month_norm_tab(Scope, PK, Y-M, _, _),
    get_param_list(Scope, temp, PK, Pairs),
    member_list([pYM-Y-M, pTHoures-MonthTab, pNHoures-MonthNorm], Pairs),
    !.

%
calc_month_norm_tab(Scope, PK, Y-M, NormDays, TabDays) :-
    % расчитать график за месяц
    calc_month_norm(Scope, PK, Y-M, NormDays),
    sum_days_houres(NormDays, NDays, NHoures),
    % расчитать табель за месяц
    calc_month_tab(Scope, PK, Y-M, TabDays),
    sum_days_houres(TabDays, TDays, THoures),
    % график и табель не пустые
    \+ NormDays = [], \+ TabDays = [],
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
    PK = [pEmplKey-EmplKey],
    % взять дату/часы
    findall( TheDay-WDuration,
            % для рабочего дня
            ( get_data(Scope, in, usr_wg_TblCalDay, [
                fEmplKey-EmplKey, fTheDay-TheDay, fWDuration-WDuration,
                fWorkDay-1, fTblCalKey-TblCalKey ]),
            % с контролем наличия часов
            WDuration > 0,
            % по типу графика
            get_schedule(Scope, PK, TheDay, TblCalKey),
            % дата для которого совпадает с проверяемым месяцем
            atom_date(TheDay, date(Y, M, _)) ),
    % в список дата/часы графика
            NormDays),
    !.

% расчитать табель за месяц
calc_month_tab(Scope, PK, Y-M, TabDays) :-
    % взять дату/часы
    findall( Date-Duration,
            % для отработанного дня
            ( usr_wg_TblCalLine1(Scope, PK, _, Date, Duration, _),
            % с контролем наличия часов
            Duration > 0,
            % дата для которого совпадает с проверяемым месяцем
            atom_date(Date, date(Y, M, _)) ),
    % в список дата/часы табеля
            TabDays),
    !.

%
sum_days_houres(ListDays, Days, Houres) :-
    sum_days_houres(ListDays, Days, Houres, 0, 0),
    !.
sum_days_houres([], Days, Houres, Days, Houres).
sum_days_houres([_-Duration|ListDays], Days, Houres, Days0, Houres0) :-
    ( Duration > 0, Days1 is Days0 + 1 ; Days1 = Days0 ),
    Houres1 is Houres0 + Duration,
    !,
    sum_days_houres(ListDays, Days, Houres, Days1, Houres1).

% тип графика
get_schedule(Scope, PK, TheDay, ScheduleKey) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    findall( % взять тип графика
             DateBegin-ScheduleKey0,
               % где для движения
             ( get_data(Scope, in, usr_wg_MovementLine, [
                     fEmplKey-EmplKey, fDateBegin-DateBegin,
                     fScheduleKey-ScheduleKey0 ]),
               % начальная дата меньше или равна проверяемой дате
               once( ( DateBegin @=< TheDay
               % либо первый день месяца меньше или равен проверяемой дате
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
cacl_month_wage(Scope, PK, Y, M, ModernWage) :-
    get_param_list(Scope, temp, PK, Pairs),
    member_list([pYM-Y-M, pModernWage-ModernWage], Pairs),
    !.
cacl_month_wage(Scope, PK, Y, M, ModernWage) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % взять начисления
    findall( Debit-ModernCoef,
          % для начисления
          ( get_data(Scope, in, wg_TblCharge, [
                fEmplKey-EmplKey, fDateBegin-Date,
                fDebit-Debit, fFeeTypeKey-FeeTypeKey ]),
          % соответствующего типа
          get_data(Scope, in, usr_wg_FeeType, [
                fEmplKey-EmplKey, fFeeTypeKey-FeeTypeKey ]),
          % где дата совпадает с проверяемым месяцем
          atom_date(Date, date(Y, M, _)),
          % с коэффициентом осовременивания
          get_modern_coef(Scope, PK, Date, ModernCoef) ),
    % в список начислений
             Debits ),
    % всего за месяц
    sum_month_debit(Debits, Wage, ModernWage),
    % средний за месяц коэффициент осовременивания
    catch( MonthModernCoef is float( round( ModernWage / Wage * 10000 ) / 10000 ), _, fail),
    % занести во временные параметры заработок
    append(PK, [pYM-Y-M,
                pWage-Wage, pModernWage-ModernWage,
                pModernCoef-MonthModernCoef],
                Pairs),
    new_param_list(Scope, temp, Pairs),
    !.

%
sum_month_debit(Debits, Wage, ModernWage) :-
    sum_month_debit(Debits, Wage, ModernWage, 0, 0),
    !.
sum_month_debit([], Wage, ModernWage, Wage, ModernWage0) :-
    catch( ModernWage is float( round( ModernWage0 * 10000 ) / 10000 ), _, fail).
sum_month_debit([Debit-ModernCoef | Debits], Wage, ModernWage, Wage0, ModernWage0) :-
    Wage1 is Wage0 + Debit,
    ModernWage1 is ModernWage0 + Debit*ModernCoef,
    !,
    sum_month_debit(Debits, Wage, ModernWage, Wage1, ModernWage1).

% коэффициент осовременивания
get_modern_coef(Scope, PK, TheDay, ModernCoef) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % дата расчета
    find_param(Scope, run, PK, pDateCalc-DateCalc),
    % взять дату и ставку
    findall( DateBegin-Rate,
             % где для движения
             ( get_data(Scope, in, usr_wg_MovementLine, [
                     fEmplKey-EmplKey, fDateBegin-DateBegin, fRate-Rate ]),
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
    % то взять последнюю ставку из следующего и всех оставшихся движений
    last([Date2-Rate2 | Movements], _-RateLast),
    % и вычислить коэффициент для текущего движения
    catch( ModernCoef is float( round( RateLast / Rate1 * 10000 ) / 10000 ), _, fail),
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
rule_month_wage(Scope, PK, Y-M, Rule) :-
    Rule = by_month_wage_all,
    % правило действительно
    is_valid_rule(Rule),
    % заработок за проверяемый месяц
    cacl_month_wage(Scope, PK, Y, M, Wage),
    % с коэффициентом осовременивания на первое число месяца
    atom_date(Date, date(Y, M, 1)),
    get_modern_coef(Scope, PK, Date, ModernCoef),
    % взять заработок
    findall( Wage1,
            % для расчетного месяца
            ( get_month_incl(Scope, PK, Y1, M1, Variant1),
            % с коэффициентом осовременивания на первое число месяца
            atom_date(Date1, date(Y1, M1, 1)),
            get_modern_coef(Scope, PK, Date1, ModernCoef1),
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
    PK = [pEmplKey-EmplKey],
    % если есть хотя бы один день по табелю
    usr_wg_TblCalLine1(Scope, PK, _, Date, _, HoureType),
    % дата для которого совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % с плохим типом часов
    get_data(Scope, in, usr_wg_BadHourType, [fEmplKey-EmplKey, fID-HoureType]),
    !.
% есть плохой тип начислений
month_bad_type(Scope, PK, Y-M) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey],
    % если есть хотя бы одно начисление
    get_data(Scope, in, wg_TblCharge, [
        fEmplKey-EmplKey, fDateBegin-Date, fFeeTypeKey-FeeTypeKey ]),
    % где дата совпадает с проверяемым месяцем
    atom_date(Date, date(Y, M, _)),
    % с плохим типом начисления
    get_data(Scope, in, usr_wg_BadFeeType, [fEmplKey-EmplKey, fID-FeeTypeKey]),
    !.

% день по табелю
usr_wg_TblCalLine1(Scope, PK, FirstMoveKey, Date, Duration, HoureType) :-
    PK = [pEmplKey-EmplKey],
    gd_pl_ds(Scope, in, usr_wg_TblCalLine, 5, _),
    catch( usr_wg_TblCalLine(EmplKey, FirstMoveKey, Date, Duration, HoureType), _, fail).
% или по табелю мастера
usr_wg_TblCalLine1(Scope, PK, FirstMoveKey, Date, Duration, HoureType) :-
    PK = [pEmplKey-EmplKey],
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
              PK = [pEmplKey-EmplKey],
              append([EmplKey], TeilArgs, Args),
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
    member_list([pDateCalc-DateCalc], Pairs),
    %
    atom_date(DateCalc, date(Y, M, _)), atom_date(DateCalcTo, date(Y, M, 1)),
    MonthAdd is -MonthQty, date_add(DateCalcTo, MonthAdd, month, DateCalcFrom),
    atom_date(DateNormFrom0, date(Y, 1, 1)),
    ( DateNormFrom0 @> DateCalcFrom, DateNormFrom = DateCalcFrom
      ; DateNormFrom = DateNormFrom0 ),
    Y1 is Y + 1, atom_date(DateNormTo, date(Y1, 1, 1)),
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
avg_wage_in(EmplKey, DateCalc0) :-
    Scope = wg_avg_wage, Type = in,
    ( is_date(DateCalc0), DateCalc = DateCalc0
      ;
      atom_chars(DateCalc0, [D1, D2, '.', M1, M2, '.', Y1, Y2, Y3, Y4]),
      atom_chars(DateCalc, [Y1, Y2, Y3, Y4, '-', M1, M2, '-', D1, D2])
    ),
    new_param_list(Scope, Type, [pEmplKey-EmplKey, pDateCalc-DateCalc]),
    !.

% загрузка общих входных параметров
avg_wage_in_public(Connection, MonthQty, AvgDays, FeeGroupKey,
                    BadHourType_xid_IN, BadHourType_dbid_IN,
                    BadFeeType_xid_IN, BadFeeType_dbid_IN) :-
    Scope = wg_avg_wage, Type = in,
    new_param_list(Scope, Type,
        [pConnection-Connection,
        pMonthQty-MonthQty, pAvgDays-AvgDays, pFeeGroupKey-FeeGroupKey,
        pBadHourType_xid_IN-BadHourType_xid_IN,
        pBadHourType_dbid_IN-BadHourType_dbid_IN,
        pBadFeeType_xid_IN-BadFeeType_xid_IN,
        pBadFeeType_dbid_IN-BadFeeType_dbid_IN]),
    !.

% выгрузка данных выполнения по сотруднику
avg_wage_run(EmplKey, DateCalcFrom, DateCalcTo) :-
    Scope = wg_avg_wage, Type = run,
    PK = [pEmplKey-EmplKey],
    get_param_list(Scope, Type, PK, Pairs),
    once( member_list(
            [pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo],
            Pairs) ).

% выгрузка SQL-запросов по сотруднику
avg_wage_sql(EmplKey, Connection, PredicateName, Arity, SQL) :-
    Scope = wg_avg_wage, Type = query, TypeNextStep = data,
    PK = [pEmplKey-EmplKey], Query = PredicateName/Arity,
    find_param_list(Scope, Type, PK,
            [pConnection-Connection, pQuery-Query, pSQL-SQL]),
    \+ find_param_list(Scope, TypeNextStep, PK,
            [pConnection-Connection, pQuery-Query, pSQL-SQL]).

% подтвеждение формирования фактов по сотруднику
avg_wage_kb(EmplKey, Connection, PredicateName, Arity, SQL) :-
    Scope = wg_avg_wage, Type = query, TypeNextStep = data,
    PK = [pEmplKey-EmplKey], Query = PredicateName/Arity,
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
avg_wage_out(EmplKey, AvgWage, Variant) :-
    Scope = wg_avg_wage, Type = out,
    PK = [pEmplKey-EmplKey],
    get_param_list(Scope, Type, PK, Pairs),
    once( member_list([pAvgWage-AvgWage,pVariant-Variant], Pairs) ).

avg_wage_det(EmplKey, Period, Rule, Wage, ModernWage, ModernCoef, TabDays, TabHoures, NormDays, NormHoures) :-
    Scope = wg_avg_wage,
    PK = [pEmplKey-EmplKey],
    get_periods(Scope, PK, Periods),
    member(Y-M, Periods),
    atom_date(Period, date(Y, M, 1)),
    %
    once( ( find_param_list(Scope, temp, PK, [pMonthIncl-MonthIncl|_])
            ; MonthIncl = [] ) ),
    once( ( member(Y-M-Rule, MonthIncl) ; Rule = none ) ),
    %
    once( ( get_param_list(Scope, temp, PK, Pairs1),
                member_list([pYM-Y-M,
                            pWage-Wage, pModernWage-ModernWage,
                            pModernCoef-ModernCoef],
                    Pairs1)
          ;
          [Wage, ModernWage, ModernCoef] = [0, 0, 1]
        ) ),
    %
    once( ( get_param_list(Scope, temp, PK, Pairs2),
                member_list([pYM-Y-M,
                            pTDays-TabDays, pTHoures-TabHoures,
                            pNDays-NormDays, pNHoures-NormHoures],
                    Pairs2)
          ;
          [TabDays, TabHoures, NormDays, NormHoures] = [0, 0, 0, 0]
        ) ),
    %
    true.
 %
%%
