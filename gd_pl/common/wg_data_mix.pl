%% wg_data_mix
%  смешанные данные для twg_avg_wage, twg_fee
%

%:- ['../gd_pl_state/date', '../gd_pl_state/dataset'].
%:- ['../common/lib', '../common/params'].

/* реализация - общий код */

% взять БВ
get_min_wage(Scope, DateCalcTo, MinWage) :-
    findall( MinWage0,
                  % взять данные по БВ
                ( get_data(Scope, kb, usr_wg_FCRate, [
                            fDate-Date, fMinWage-MinWage0]),
                  % где дата константы меньше первой даты месяца
                  Date @< DateCalcTo
                ),
    % в список БВ
    MinWageList),
    % последние данные по БВ
    last(MinWageList, MinWage),
    !.
get_min_wage(_, _, 0) :-
    !.

% взять БПМ
get_budget(Scope, DateCalcTo, Budget) :-
    findall( Budget0,
                  % взять данные по БПМ
                ( get_data(Scope, kb, gd_const_budget, [
                            fConstDate-ConstDate, fBudget-Budget0]),
                  % где дата константы меньше первой даты месяца
                  ConstDate @< DateCalcTo
                ),
    % в список БПМ
    BudgetList),
    % последние данные по БПМ
    last(BudgetList, Budget),
    !.
get_budget(_, _, 0) :-
    !.

% взять дату последнего приема на работу
get_last_hire(Scope, PK, DateIn) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % взять даты
    findall( EmplKey-FirstMoveKey-DateIn0,
             % для первого движения по типу 1 (прием на работу)
             get_data(Scope, kb, usr_wg_MovementLine, [
                         fEmplKey-EmplKey,
                         fDocumentKey-FirstMoveKey, fFirstMoveKey-FirstMoveKey,
                         fDateBegin-DateIn0, fMovementType-1 ]),
    % в список дат приема на работу
    DateInList ),
    % определить дату последнего приема на работу
    last(DateInList, EmplKey-FirstMoveKey-DateIn),
    !.

% формирование временных данных по графику работы
make_schedule(Scope, PK) :-
    % временные данные по графику работы уже есть
    get_param_list(Scope, temp, [pScheduleKey-_|PK]),
    !.
make_schedule(Scope, PK) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % взять данные по движению
    findall( Date-ScheduleKey,
             get_data(Scope, kb, usr_wg_MovementLine, [
                         fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                         fDateBegin-Date, fScheduleKey-ScheduleKey]),
    MoveList ),
    % взять дату ограничения расчета
    get_param_list(Scope, run, [pDateCalcTo-DateCalcTo|PK]),
    % добавить временные данные по графику работы
    add_schedule(Scope, PK, MoveList, DateCalcTo),
    !.

% добавить временные данные по графику работы
add_schedule(_, _, [], _) :-
    !.
add_schedule(Scope, PK, [DateFrom-ScheduleKey], DateCalcTo) :-
    append(PK,
            [pDateFrom-DateFrom, pDateTo-DateCalcTo, pScheduleKey-ScheduleKey],
                Pairs),
    new_param_list(Scope, temp, Pairs),
    !.
add_schedule(Scope, PK, [DateFrom-ScheduleKey, DateTo-ScheduleKey1 | MoveList], DateCalcTo) :-
    append(PK,
            [pDateFrom-DateFrom, pDateTo-DateTo, pScheduleKey-ScheduleKey],
                Pairs),
    new_param_list(Scope, temp, Pairs),
    !,
    add_schedule(Scope, PK, [DateTo-ScheduleKey1 | MoveList], DateCalcTo).

% взять последний график рабочего времени
get_last_schedule(Scope, PK, ScheduleKey) :-
    % разложить первичный ключ
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    % взять график
    findall( ScheduleKey0,
             % для движения по сотруднику
             get_data(Scope, kb, usr_wg_MovementLine, [
                         fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                         fScheduleKey-ScheduleKey0]),
    % в список графиков
    ScheduleKeyList ),
    % определить последний график рабочего времени
    last(ScheduleKeyList, ScheduleKey),
    !.

% проверить вхождение даты в график
check_schedule(Scope, PK, TheDay, ScheduleKey) :-
    append(PK,
            [pDateFrom-DateFrom, pDateTo-DateTo, pScheduleKey-ScheduleKey],
                Pairs),
    get_param_list(Scope, temp, Pairs),
    TheDay @>= DateFrom, TheDay @< DateTo,
    !.
check_schedule(Scope, PK, _, ScheduleKey) :-
    get_last_schedule(Scope, PK, ScheduleKey),
    !.

% расчитать табель за месяц по одному из параметров
calc_month_tab(Scope, PK, Y-M, TabDays) :-
    % параметры выбора табеля
    member(TabelOption, [tbl_cal_flex, tbl_cal, tbl_charge, dbf_sums]),
    % взять данные из табеля
    findall( Date-DOW-HOW,
            % для проверяемого месяца
            ( usr_wg_TblCalLine_mix(Scope, PK, Y-M, Date, DOW, HOW, _, TabelOption),
            % с контролем наличия дней или часов
            once( ( DOW > 0 ; HOW > 0 ) )
            ),
    % в список дата-день-часы
    TabDays),
    % проверить список табеля
    \+ TabDays = [],
    !.
calc_month_tab(_, _, _, []) :-
    !.

% сумма дней и часов
sum_days_houres(ListDays, Days, Houres) :-
    sum_days_houres(ListDays, Days, Houres, '', ''),
    !.
sum_days_houres(ListDays, Days, Houres, DateBegin, DateEnd) :-
    sum_days_houres(ListDays, Days, Houres, 0, 0, DateBegin, DateEnd),
    !.
%
sum_days_houres([], Days, Houres, Days, Houres, _, _).
sum_days_houres([Date-DOW-HOW|ListDays], Days, Houres, Days0, Houres0, DateBegin, DateEnd) :-
      % если в заданном периоде
    ( ( Date @>= DateBegin, Date @=< DateEnd
      % или полный расчет
      ; [DateBegin, DateEnd] = ['', '']
      ),
      % то добавить дни и часы
      Days1 is Days0 + DOW,
      Houres1 is Houres0 + HOW
    ; % иначе исключать
      Days1 is Days0,
      Houres1 is Houres0
    ),
    !,
    sum_days_houres(ListDays, Days, Houres, Days1, Houres1, DateBegin, DateEnd).

/* реализация - смешанные данные */

%% взять данные по начислению
% начисление из TblCharge
usr_wg_TblCharge_mix(Scope, ArgPairs, ChargeOption) :-
    ChargeOption = tbl_charge,
    get_data(Scope, kb, usr_wg_TblCharge, [fPayPeriod-PayPeriod|ArgPairs]),
    once( ( PayPeriod < 2
          ; \+ memberchk(Scope, [wg_avg_wage_avg]) )
        ).
% или начисление из dbf
% с согласованием спецификации по TblCharge
usr_wg_TblCharge_mix(Scope, ArgPairs, ChargeOption) :-
    ChargeOption = dbf_sums,
    % спецификация usr_wg_TblCharge
    ValuePairs = [
                fEmplKey-EmplKey, fFirstMoveKey-_,
                fCalYear-CalYear, fCalMonth-CalMonth, fDateBegin-DateBegin,
                fDebit-Debit, fFeeTypeKey-FeeTypeKey
                ],
    member_list(ArgPairs, ValuePairs),
    % спецификация usr_wg_DbfSums
    DataPairs =  [
                fEmplKey-EmplKey,
                fInYear-CalYear, fInMonth-CalMonth, fDateBegin-DateBegin,
                fInSum-Debit, fSickProp-FeeTypeKey
                ],
    get_data(Scope, kb, usr_wg_DbfSums, DataPairs).

%% взять данные по графику
% день месяца по календарному графику
usr_wg_TblDayNorm_mix(Scope, PK, Y-M, Date, Duration, WorkDay, NormOption) :-
    NormOption = tbl_cal_flex,
    get_Flex_by_type(Scope, PK, Y-M, Date, WorkDay, Duration, _, "plan").
% или день месяца по справочнику графика рабочего времени
usr_wg_TblDayNorm_mix(Scope, PK, Y-M, TheDay, WDuration, WorkDay, NormOption) :-
    NormOption = tbl_day_norm,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    get_data(Scope, kb, usr_wg_TblCalDay, [
                fScheduleKey-ScheduleKey,
                fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                fWYear-Y, fWMonth-M, fTheDay-TheDay,
                fWDuration-WDuration, fWorkDay-WorkDay ]),
    check_schedule(Scope, PK, TheDay, ScheduleKey).

%% взять данные по табелю
% день месяца по табелю мастера
usr_wg_TblCalLine_mix(Scope, PK, Y-M, Date, Days, Duration, HoureType, TabelOption) :-
    TabelOption = tbl_cal_flex,
    get_Flex_by_type(Scope, PK, Y-M, Date, Days, Duration, HoureType, "fact").
% или день месяца по табелю
usr_wg_TblCalLine_mix(Scope, PK, Y-M, Date, Days, Duration, HoureType, TabelOption) :-
    TabelOption = tbl_cal,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    get_data(Scope, kb, usr_wg_TblCalLine, [
                fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                fCalYear-Y, fCalMonth-M, fDate-Date,
                fDuration-Duration, fHoureType-HoureType]),
    once( (Duration > 0, Days = 1 ; Days = 0) ).
% или табель дни-часы из начислений
usr_wg_TblCalLine_mix(Scope, PK, Y-M, Date, DOW, HOW, 0, TabelOption) :-
    TabelOption = tbl_charge,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    ArgPairs = [fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                fCalYear-Y, fCalMonth-M, fDateBegin-Date,
                fFeeTypeKey-FeeTypeKey, fDOW-DOW, fHOW-HOW],
    get_data(Scope, kb, usr_wg_TblCharge, [fPayPeriod-_|ArgPairs]),
    once( get_data(Scope, kb, usr_wg_FeeType, [
                    fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                    fFeeTypeKey-FeeTypeKey, fAvgDayHOW-1]) ).
% или день месяца из dbf
usr_wg_TblCalLine_mix(Scope, PK, Y-M, Date, 0, InHoures, 0, TabelOption) :-
    TabelOption = dbf_sums,
    PK = [pEmplKey-EmplKey, pFirstMoveKey-_],
    get_data(Scope, kb, usr_wg_DbfSums, [
                fEmplKey-EmplKey, fInHoures-InHoures,
                fInYear-Y, fInMonth-M, fDateBegin-Date]).

% день месяца по календарному графику или табелю мастера
% FlexType: "plan" ; "fact"
get_Flex_by_type(Scope, PK, Y-M, Date, Days, Duration, HoureType, FlexType) :-
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    gd_pl_ds(Scope, kb, usr_wg_TblCal_FlexLine, 68, _),
    length(TeilArgs, 62),
    Term =..[ usr_wg_TblCal_FlexLine, FlexType, EmplKey, FirstMoveKey, Y, M, _ | TeilArgs ],
    catch( call( Term ), _, fail ),
    between(1, 31, D),
    atom_date(Date, date(Y, M, D)),
    S is (D - 1) * 2 + 6 + 1,
    H is S + 1,
    arg(S, Term, Duration0),
    once( ( number(Duration0), Duration = Duration0
            ; atom_number(Duration0, Duration)
            ; Duration = 0 ) ),
    arg(H, Term, HoureType0),
    once( ( number(HoureType0), HoureType = HoureType0
            ; atom_number(HoureType0, HoureType)
            ; HoureType = 0 ) ),
    once( (Duration > 0, Days = 1 ; Days = 0) ).

/**/

 %
%%
