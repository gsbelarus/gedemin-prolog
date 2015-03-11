%% twg_pu
% Зарплата и Отдел кадров -> Зарплата -> 06. Персонифицированный учёт
%   ПУ-3
%

:- style_check([-atom]).

:- dynamic(debug_mode/0).
% ! при использовании в ТП Гедымин
% ! комментировать следующую строку
%:- assertz(debug_mode).

%%% begin debug mode section
:- if(debug_mode).

%% saved state
:- ['../gd_pl_state/load_atom', '../gd_pl_state/date', '../gd_pl_state/dataset'].
%%

%% include
%#INCLUDE lib
%#INCLUDE params
%#INCLUDE wg_data_mix
:- ['../common/lib', '../common/params', '../common/wg_data_mix'].
%#INCLUDE twg_pu_sql
:- [twg_pu_sql].
%#INCLUDE twg_pu_in_params
%:- [twg_pu_in_params].
%%

%% facts
:-  init_data,
    working_directory(_, 'kb'),
    [
    usr_wg_MovementLine,
    usr_wg_KindOfWork,
    usr_wg_PersonalCard,
    gd_people,
    usr_wg_Contract,
    usr_wg_TblCharge,
    usr_wg_FeeType,
    usr_wg_FeeTypeSick,
    usr_wg_FeeType_Dict,
    usr_wg_TblCalLine,
    usr_wg_TblCal_FlexLine,
    usr_wg_HourType,
    usr_wg_ExclDays,
    gd_const_AvgSalaryRB
    ],
    working_directory(_, '..').
%%

%% dynamic state
:- ['kb/param_list'].
%%

:- else.

:- ps32k_lgt(64, 128, 64).

:- endif.
%%% end debug mode section

/* реализация - расчет */

% расчет итогового начисления
pu_calc(Scope, EmplKey) :-
    % - для ПУ
    memberchk(Scope, [wg_pu_3]),
    % для каждого сотрудника
    get_param(Scope, in, pEmplKey-EmplKey),
    % удалить временные данные по расчету
    forall( get_param_list(Scope, temp, [pEmplKey-EmplKey], Pairs),
            dispose_param_list(Scope, temp, Pairs)
    ),
    % выполнить расчет
    make_rep_periods(Scope, EmplKey),
    make_pu_tab(Scope, EmplKey),
    forall( member(CatType/IsContract-IsPractice, [1/0-0, 3/1-0]),
            ( make_work_periods(Scope, EmplKey, CatType/IsContract-IsPractice),
              add_rep_amount(Scope, EmplKey, CatType),
              add_sick_amount(Scope, EmplKey, CatType),
              %add_soc_amount(Scope, EmplKey, CatType),
              make_exp_periods(Scope, EmplKey, CatType)
            )
    ),
    % найти альтернативу
    fail.
pu_calc(_, _) :-
    % больше альтернатив нет
    !.

%
make_rep_periods(Scope, EmplKey) :-
    get_param_list(Scope, run, [
                    pEmplKey-EmplKey,
                    pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo ]),
    make_rep_periods(Scope, EmplKey, DateCalcFrom, DateCalcTo),
    !.
%

make_rep_periods(_, _, DateCalcTo, DateCalcTo) :-
    !.
make_rep_periods(Scope, EmplKey, DateCalcFrom, DateCalcTo) :-
    atom_date(DateCalcFrom, date(Y, M, _)),
    new_param_list(Scope, temp, [
                    pEmplKey-EmplKey, pRepYM-Y-M ]),
    date_add(DateCalcFrom, 1, day, DateCalcFrom1),
    !,
    make_rep_periods(Scope, EmplKey, DateCalcFrom1, DateCalcTo).

make_pu_tab(Scope, EmplKey) :-
    get_param_list(Scope, in, [
                    pEmplKey-EmplKey,
                    pTabOption-1 ]),
    abolish(wg_pu_tab/5),
    dynamic(wg_pu_tab/5),
    PK = [pEmplKey-EmplKey, pFirstMoveKey-_],
    member(TabelOption, [tbl_cal_flex, tbl_cal]),
    usr_wg_TblCalLine_mix(Scope, PK, _, Day, _, _, HourType, TabelOption),
    get_data(Scope, kb, usr_wg_HourType, [
                fID-HourType, fAlias-Alias, fForPU3-ForPU3 ]),
    assertz( wg_pu_tab(Scope, PK, Day, Alias, ForPU3) ),
    fail.
make_pu_tab(_, _).

%
make_work_periods(Scope, EmplKey, CatType/IsContract-IsPractice) :-
    findall( FirstMoveKey/Date-MovementType,
             ( get_data(Scope, kb, usr_wg_MovementLine, [
                         fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                         fDateBegin-Date,
                         fMovementType-MovementType, fKindOfWorkKey-KindOfWorkKey,
                         fIsContract-IsContract, fIsPractice-IsPractice ]),
               memberchk(MovementType, [1, 3]),
               ( CatType = 1
                -> \+ get_data(Scope, kb, usr_wg_KindOfWork, [
                                  fID-KindOfWorkKey, fAlias-"kwByWork" ])
               ; get_data(Scope, kb, usr_wg_KindOfWork, [
                             fID-KindOfWorkKey, fAlias-"kwByWorkOuter" ])
               )
             ),
    MoveList ),
    \+ MoveList = [],
    get_param_list(Scope, run, [
                    pEmplKey-EmplKey,
                    pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo ]),
    move_to_work_periods(MoveList, DateCalcFrom, DateCalcTo, WorkPeriods),
    new_param_list(Scope, temp, [
                    pEmplKey-EmplKey,
                    pCatType-CatType, pWorkPeriods-WorkPeriods ]),
    !.
make_work_periods(_, _, _).

%
move_to_work_periods([], _, _, []).
move_to_work_periods([DocKey/DateBegin-1], DateCalcFrom, DateCalcTo, [DocKey/WorkBegin-WorkEnd]) :-
    ( DateBegin @< DateCalcFrom
     -> WorkBegin = DateCalcFrom
    ; WorkBegin = DateBegin
    ),
    date_add(DateCalcTo, -1, day, WorkEnd).
move_to_work_periods([_/_-3, DocKey/DateBegin-3 | MoveTeil], DateCalcFrom, DateCalcTo, MoveRest) :-
    !,
    move_to_work_periods([DocKey/DateBegin-3 | MoveTeil], DateCalcFrom, DateCalcTo, MoveRest).
move_to_work_periods([_/_-3, DocKey/DateBegin-1 | MoveTeil], DateCalcFrom, DateCalcTo, MoveRest) :-
    !,
    move_to_work_periods([DocKey/DateBegin-1 | MoveTeil], DateCalcFrom, DateCalcTo, MoveRest).
move_to_work_periods([DocKey/DateBegin-1, DocKeyNext/DateBeginNext-1 | MoveTeil], DateCalcFrom, DateCalcTo, [DocKey/DateBegin-DateEnd | MoveRest]) :-
    date_add(DateBegin, -1, day, DateEnd),
    !,
    move_to_work_periods([DocKeyNext/DateBeginNext-1 | MoveTeil], DateCalcFrom, DateCalcTo, MoveRest).

move_to_work_periods([DocKey/DateBegin-1, DocKey/DateEnd-3 | MoveTeil], DateCalcFrom, DateCalcTo, [DocKey/WorkBegin-WorkEnd | MoveRest]) :-
    ( DateBegin @< DateCalcFrom
     -> WorkBegin = DateCalcFrom
    ; WorkBegin = DateBegin
    ),
    ( DateEnd @< DateCalcTo
     -> \+ DateEnd @< DateCalcFrom,
       WorkEnd = DateEnd
    ; date_add(DateCalcTo, -1, day, WorkEnd)
    ),
    !,
    move_to_work_periods(MoveTeil, DateCalcFrom, DateCalcTo, MoveRest).
move_to_work_periods([_/_-1, _/_-3 | MoveTeil], DateCalcFrom, DateCalcTo, MoveRest) :-
    !,
    move_to_work_periods(MoveTeil, DateCalcFrom, DateCalcTo, MoveRest).

%
add_rep_amount(Scope, EmplKey, CatType) :-
    CatType = 1,
    get_param_list(Scope, temp, [
                    pEmplKey-EmplKey,
                    pCatType-CatType, pWorkPeriods-WorkPeriods ]),
    % взять суммы СВ
    findall( Y-M/ChargeSum,
              % по начислениям
            ( get_data(Scope, kb, usr_wg_TblCharge, [
                        fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                        fCalYear-Y, fCalMonth-M,
                        fDebit-Debit, fCredit-Credit,
                        fFeeTypeKey-FeeTypeKey ]),
              ChargeSum is Debit - Credit,
              % для группы СВ
              get_data(Scope, kb, usr_wg_FeeType, [
                         fFeeTypeKey-FeeTypeKey ]),
              % и документов
              memberchk(FirstMoveKey/_-_, WorkPeriods)
            ),
    % в список СВ
    ChargeSumList ),
    forall( get_param_list(Scope, temp, [
                            pEmplKey-EmplKey, pRepYM-Y-M ]),
            ( findall( ChargeSumYM,
                       member(Y-M/ChargeSumYM, ChargeSumList),
              ChargeSumYMList),
              sum_list(ChargeSumYMList, FeeAmount0),
              get_avg_salary_rb(Scope, Y-M, MonthAvgSalary),
              ( get_param_list(Scope, in, [pCommon, pAvgSalaryRB_Coef-Coef])
               -> FeeAmountCheck is round(MonthAvgSalary * Coef)
              ; FeeAmountCheck = FeeAmount0
              ),
              ( FeeAmount0 > FeeAmountCheck
               -> FeeAmount = FeeAmountCheck
              ; FeeAmount = FeeAmount0
              ),
              new_param_list(Scope, temp, [
                              pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                              pCatType-CatType,
                              pYM-Y-M, pFeeAmount-FeeAmount ])
            )
    ),
    !.
add_rep_amount(Scope, EmplKey, CatType) :-
    CatType = 3,
    get_param_list(Scope, temp, [
                    pEmplKey-EmplKey,
                    pCatType-CatType, pWorkPeriods-WorkPeriods ]),
    % по документу
    member(FirstMoveKey/_-_, WorkPeriods),
    % взять суммы
    findall( Y-M/ChargeSum,
              % по начислениям
            ( get_data(Scope, kb, usr_wg_TblCharge, [
                        fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                        fCalYear-Y, fCalMonth-M,
                        fDebit-Debit, fCredit-Credit,
                        fFeeTypeKey-FeeTypeKey ]),
              ChargeSum is Debit - Credit,
              % для группы СВ
              get_data(Scope, kb, usr_wg_FeeType, [
                         fFeeTypeKey-FeeTypeKey ])
            ),
    % в список
    ChargeSumList ),
    forall( get_param_list(Scope, temp, [
                            pEmplKey-EmplKey, pRepYM-Y-M ]),
            ( findall( ChargeSumYM,
                       member(Y-M/ChargeSumYM, ChargeSumList),
              ChargeSumYMList),
              sum_list(ChargeSumYMList, FeeAmount),
              new_param_list(Scope, temp, [
                              pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                              pCatType-CatType,
                              pYM-Y-M, pFeeAmount-FeeAmount ])
            )
    ),
    fail.
add_rep_amount(_, _, _).

%
add_sick_amount(Scope, EmplKey, CatType) :-
    CatType = 1,
    get_param_list(Scope, temp, [
                    pEmplKey-EmplKey,
                    pCatType-CatType, pWorkPeriods-WorkPeriods ]),
    % взять суммы СВ
    findall( Y-M/ChargeSum,
              % по начислениям
            ( get_data(Scope, kb, usr_wg_TblCharge, [
                        fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                        fCalYear-Y, fCalMonth-M,
                        fDebit-Debit, fCredit-Credit,
                        fFeeTypeKey-FeeTypeKey ]),
              ChargeSum is Debit - Credit,
              % для пособий
              get_data(Scope, kb, usr_wg_FeeTypeSick, [
                         fID-FeeTypeKey ]),
              % и документов
              memberchk(FirstMoveKey/_-_, WorkPeriods)
            ),
    % в список СВ
    ChargeSumList ),
    forall( get_param_list(Scope, temp, [
                            pEmplKey-EmplKey, pRepYM-Y-M ]),
            ( findall( ChargeSumYM,
                       member(Y-M/ChargeSumYM, ChargeSumList),
              ChargeSumYMList),
              sum_list(ChargeSumYMList, SickAmount),
              new_param_list(Scope, temp, [
                              pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                              pCatType-CatType,
                              pYM-Y-M, pSickAmount-SickAmount ])
            )
    ),
    !.
add_sick_amount(Scope, EmplKey, CatType) :-
    CatType = 3,
    get_param_list(Scope, temp, [
                    pEmplKey-EmplKey,
                    pCatType-CatType, pWorkPeriods-WorkPeriods ]),
    % по документу
    member(FirstMoveKey/_-_, WorkPeriods),
    % взять суммы
    findall( Y-M/ChargeSum,
              % по начислениям
            ( get_data(Scope, kb, usr_wg_TblCharge, [
                        fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                        fCalYear-Y, fCalMonth-M,
                        fDebit-Debit, fCredit-Credit,
                        fFeeTypeKey-FeeTypeKey ]),
              ChargeSum is Debit - Credit,
              % для пособий
              get_data(Scope, kb, usr_wg_FeeTypeSick, [
                         fID-FeeTypeKey ])
            ),
    % в список
    ChargeSumList ),
    forall( get_param_list(Scope, temp, [
                            pEmplKey-EmplKey, pRepYM-Y-M ]),
            ( findall( ChargeSumYM,
                       member(Y-M/ChargeSumYM, ChargeSumList),
              ChargeSumYMList),
              sum_list(ChargeSumYMList, SickAmount),
              new_param_list(Scope, temp, [
                              pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                              pCatType-CatType,
                              pYM-Y-M, pSickAmount-SickAmount ])
            )
    ),
    fail.
add_sick_amount(_, _, _).

%
make_exp_periods(Scope, EmplKey, CatType) :-
    CatType = 1,
    get_param_list(Scope, temp, [
                    pEmplKey-EmplKey,
                    pCatType-CatType, pWorkPeriods-WorkPeriods ]),
    get_param_list(Scope, run, [
                    pEmplKey-EmplKey,
                    pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo,
                    pTabOption-TabOption ]),
    make_rep_days(DateCalcFrom, DateCalcTo, RepDays),
    form_work_days(RepDays, Scope-EmplKey-CatType, _, WorkPeriods, RepDays1),
    form_skip_days(RepDays1, Scope-EmplKey-_-CatType-TabOption/WorkPeriods, RepDays2),
    RepDays2 = [DayBegin|_],
    form_exp_periods(RepDays2, DayBegin, RepDays3),
    forall( member(ExpPeriod, RepDays3),
            new_param_list(Scope, temp, [
                            pEmplKey-EmplKey, pFirstMoveKey-_,
                            pCatType-CatType, pExpPeriod/ExpPeriod ])
    ),
    % найти месяцы с начислением без ВЗНОСЫВРЕМ
    findall( Y-M,
             ( get_param_list(Scope, temp, [pEmplKey-EmplKey, pRepYM-Y-M]),
               get_param_list(Scope, temp, [
                               pEmplKey-EmplKey, pCatType-CatType,
                               pYM-Y-M, pFeeAmount-FeeAmount ]),
               FeeAmount > 0,
               \+ ( get_param_list(Scope, temp, [
                                       pEmplKey-EmplKey,
                                       pCatType-CatType, pExpPeriod/ExpPeriod ]),
                    ExpPeriod = ExpBegin-ExpEnd/ExpType,
                    ExpType = 1,
                    ( atom_date(ExpBegin, date(Y, M, _))
                    ; atom_date(ExpEnd, date(Y, M, _))
                    )
                  )
             ),
    YMList),
    % для месяцев с начислением без ВЗНОСЫВРЕМ
    forall( ( member(Y-M, YMList),
              atom_date(ExpBegin, date(Y, M, 1))
            ),
              % если есть период ВЗНОСЫВРЕМ
            ( get_param_list(Scope, temp, [
                              pEmplKey-EmplKey,
                              pCatType-CatType, pExpPeriod/ExpPeriod1 ]),
              ExpPeriod1 = ExpBegin1-ExpEnd1/ExpType1,
              ExpType1 = 1,
              ExpBegin @>= ExpBegin1,
              ExpBegin @=< ExpEnd1
              % то ничего не делать
               -> true
              % если есть период ДЕТИ или пропуск или ПОСОБИЕ
            ; member(ExpType1, [3, 0, 2]),
              get_param_list(Scope, temp, [
                              pEmplKey-EmplKey,
                              pCatType-CatType, pExpPeriod/ExpPeriod1 ]),
              ExpPeriod1 = ExpBegin1-ExpEnd1/ExpType1,
              between(1, 31, TheDay),
              atom_date(ExpMid, date(Y, M, TheDay)),
              ExpMid @>= ExpBegin1,
              ExpMid @=< ExpEnd1
              % то ПРЕМИЯ
             ->
              month_days(Y, M, Days),
              atom_date(ExpEnd, date(Y, M, Days)),
              ExpBegin4 = ExpBegin,
              ( ExpEnd1 @< ExpEnd
               -> ExpEnd4 = ExpEnd1
              ; ExpEnd4 = ExpEnd
              ),
              ExpType4 = 4,
              ExpPeriod4 = ExpBegin4-ExpEnd4/ExpType4,
              new_param_list(Scope, temp, [
                              pEmplKey-EmplKey, pFirstMoveKey-_,
                              pCatType-CatType, pExpPeriod/ExpPeriod4 ])
              % иначе далее
            ; true
              % иначе исключить начисление
              /*
              get_param_list(Scope, temp, [
                              pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                              pCatType-CatType,
                              pYM-Y-M, pFeeAmount-_ ], Pairs),
              dispose_param_list(Scope, temp, Pairs),
              new_param_list(Scope, temp, [
                              pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                              pCatType-CatType,
                              pYM-Y-M, pFeeAmount-0 ])
            */
            )
    ),
    !.
make_exp_periods(Scope, EmplKey, CatType) :-
    CatType = 3,
    get_param_list(Scope, temp, [
                    pEmplKey-EmplKey,
                    pCatType-CatType, pWorkPeriods-WorkPeriods ]),
    get_param_list(Scope, run, [
                    pEmplKey-EmplKey,
                    pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo,
                    pTabOption-TabOption ]),
    %
    member(FirstMoveKey/_-_, WorkPeriods),
    %
    make_rep_days(DateCalcFrom, DateCalcTo, RepDays),
    form_work_days(RepDays, Scope-EmplKey-CatType, FirstMoveKey, WorkPeriods, RepDays1),
    form_skip_days(RepDays1, Scope-EmplKey-FirstMoveKey-CatType-TabOption/WorkPeriods, RepDays2),
    RepDays2 = [DayBegin|_],
    form_exp_periods(RepDays2, DayBegin, RepDays3),
    forall( member(ExpPeriod, RepDays3),
            new_param_list(Scope, temp, [
                            pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                            pCatType-CatType, pExpPeriod/ExpPeriod ])
    ),
    !.
make_exp_periods(_, _, _).

% сформировать отчетные дни
make_rep_days(DateCalcTo, DateCalcTo, []) :-
    !.
make_rep_days(DateCalcFrom, DateCalcTo, [DateCalcFrom/(-1)|Rest]) :-
    date_add(DateCalcFrom, 1, day, DateCalcFrom1),
    make_rep_days(DateCalcFrom1, DateCalcTo, Rest).

% сформировать статус рабочих дней
form_work_days([], _, _, _, []).
% ВЗНОСЫВРЕМ
form_work_days([Day/_|Teil], Params, FirstMoveKey, WorkPeriods, [Day/State|Rest]) :-
    Params = _-_-CatType,
    %( Day = '2014-08-11', check_point(Day) ; true),
    ( CatType = 1
      -> true
    ; FirstMoveKey1 = FirstMoveKey
    ),
    member(FirstMoveKey1/DateBegin-DateEnd, WorkPeriods),
    Day @>= DateBegin, Day @=< DateEnd,
    ( is_work_amount(Day, Params)
     -> State = 1
    ; State = 0
    ),
    !,
    form_work_days(Teil, Params, FirstMoveKey, WorkPeriods, Rest).
% не изменять статус
form_work_days([DayState|Teil], Params, FirstMoveKey, WorkPeriods, [DayState|Rest]) :-
    form_work_days(Teil, Params, FirstMoveKey, WorkPeriods, Rest).

% есть начисление группы СВ
is_work_amount(Day, Scope-EmplKey-CatType) :-
    atom_date(Day, date(Y, M, _)),
    get_param_list(Scope, temp, [
                    pEmplKey-EmplKey, pCatType-CatType,
                    pYM-Y-M, pFeeAmount-FeeAmount ]),
    FeeAmount > 0,
    !.

% сформировать статус пропущенных дней
form_skip_days([], _, []).
form_skip_days([Day/State|Teil], Params, [Day/State1|Rest]) :-
    switch_day_state(Day/State, Params, State1),
    !,
    form_skip_days(Teil, Params, Rest).
form_skip_days([Day/State|Teil], Params, [Day/State|Rest]) :-
    form_skip_days(Teil, Params, Rest).

% переключение статуса дня
switch_day_state(Day/State, Scope-EmplKey-FirstMoveKey-CatType-TabOption/WorkPeriods, State1) :-
    TabOption = 1,
    ( CatType = 1
     -> true
    ; FirstMoveKey1 = FirstMoveKey
    ),
    PK = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey1],
    wg_pu_tab(Scope, PK, Day, Alias, 1),
    memberchk(FirstMoveKey1/_-_, WorkPeriods),
    case_day_state(Day/State, Scope-EmplKey-CatType, Alias, State1),
    !.
switch_day_state(Day/State, Scope-EmplKey-FirstMoveKey-CatType-TabOption/WorkPeriods, State1) :-
    %( Day = '2014-03-18' -> check_point(Day/State) ; true),
    TabOption = 0,
    ( CatType = 1
     -> true
    ; FirstMoveKey1 = FirstMoveKey
    ),
    get_data(Scope, kb, usr_wg_ExclDays, [
                fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey1,
                fExclType-ExclType, fHourType-HourType,
                fExclWeekDay-ExclWeekDay,
                fFromDate-FromDate, fToDate-ToDate ]),
    Day @>= FromDate, Day @=< ToDate,
    get_data(Scope, kb, usr_wg_HourType, [
                fID-HourType, fAlias-Alias, fForPU3-1 ]),
    ( ExclType = "SICKLIST"
    ; ExclType = "KINDDAYLINE", weekday(Day, ExclWeekDay)
    ; memberchk(FirstMoveKey1/_-_, WorkPeriods)
    ),
    case_day_state(Day/State, Scope-EmplKey-CatType, Alias, State1),
    !.
switch_day_state(_/State, _, State).

% контрольная точка
check_point(X) :-
    writeq(check_point(X)), nl,
    true.

% выбор нового статуса дня
case_day_state(Day/State, Scope-EmplKey-CatType, Alias, State1) :-
   memberchk(Alias, ["htSick", "htPregnancy"]),
   ( \+ State = 2,
     is_skip_amount(Day, Scope-EmplKey-CatType),
     % ПОСОБИЕ
     State1 = 2
   ; State1 = State
   ),
   !.
% ДЕТИ
case_day_state(_, _, "htCareOf", 3) :-
   !.
% пропуск
case_day_state(_, _, _, 0).

%
is_skip_amount(Day, Scope-EmplKey-CatType) :-
    atom_date(Day, date(Y, M, _)),
    get_param_list(Scope, temp, [
                    pEmplKey-EmplKey, pCatType-CatType,
                    pYM-Y-M, pSickAmount-SickAmount ]),
    SickAmount > 0,
    !.

%
form_exp_periods([DayEnd/State], DayBegin/State, [DayBegin-DayEnd/State]).
form_exp_periods([DayEnd/State, DayNext/StateNext | Teil], DayBegin/State, [DayBegin-DayEnd/State | Rest]) :-
    \+ State = StateNext,
    form_exp_periods([DayNext/StateNext | Teil], DayNext/StateNext, Rest).
form_exp_periods([_ | Teil], DayBegin/State, Rest) :-
    form_exp_periods(Teil, DayBegin/State, Rest).

/* реализация - расширение для клиента */

% загрузка входных данных по сотруднику
pu_calc_in(Scope, EmplKey, DateBegin, DateEnd, EDocType, TabOption, UNPF, PhoneNum) :-
    % - для ПУ
    memberchk(Scope, [wg_pu_3]),
    Type = in, Section = PK,
    % первичный ключ
    PK = [pEmplKey-EmplKey],
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % записать входные параметры
    new_param_list(Scope, Type, [
        pEmplKey-EmplKey,
        pDateBegin-DateBegin, pDateEnd-DateEnd,
        pEDocType-EDocType, pTabOption-TabOption,
        pUNPF-UNPF, pPhoneNum-PhoneNum
        ]),
    !.

% подготовка данных выполнения
pu_calc_prep(Scope) :-
    % - для ПУ
    memberchk(Scope, [wg_pu_3]),
    Type = in, TypeNextStep = run,
    % записать отладочную информацию
    param_list_debug(Scope, Type-TypeNextStep),
    % для каждого сотрудника
    get_param_list(Scope, Type, [
        pEmplKey-_,
        pDateBegin-DateBegin, pDateEnd-DateEnd ],
    Pairs),
    % собрать входные данные
    findall( Pairs0,
             ( member(Template, [pCommon]),
               get_param_list(Scope, Type, [Template], Pairs0)
             ),
    PairsList ),
    append(PairsList, PairsNextStep0),
    % сформировать данные выполнения
    date_add(DateEnd, 1, day, DateCalcTo),
    % записать данные выполнения
    append([ Pairs,
             [
               pDateCalcFrom-DateBegin, pDateCalcTo-DateCalcTo
             ],
             PairsNextStep0
           ],
    PairsNextStep),
    new_param_list(Scope, TypeNextStep, PairsNextStep),
    % найти альтернативу
    fail.
pu_calc_prep(_) :-
    % больше альтернатив нет
    !.

% выгрузка данных выполнения по сотруднику
pu_calc_run(Scope, EmplKey) :-
    % - для ПУ
    memberchk(Scope, [wg_pu_3]),
    Type = run, Section = PK,
    % первичный ключ
    PK = [pEmplKey-EmplKey],
    % взять данные выполнения
    get_param_list(Scope, Type, PK),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    true.

% формирование SQL-запросов по сотруднику
pu_calc_sql(Scope, EmplKey, PredicateName, Arity, SQL) :-
    % - для ПУ
    memberchk(Scope, [wg_pu_3]),
    Type = run, TypeNextStep = query,
    % записать отладочную информацию
    param_list_debug(Scope, Type-TypeNextStep),
    % взять данные выполнения для подстановки параметров
    get_param_list(Scope, Type, [pEmplKey-EmplKey], Pairs),
    % для каждой спецификации набора данных
    gd_pl_ds(Scope, kb, PredicateName, Arity, _),
    Query = PredicateName/Arity,
    is_valid_sql(Query),
    % взять SQL-строку с параметрами
    get_sql(Scope, kb, Query, SQL0, Params),
      % если данные по сотруднику
    ( memberchk(pEmplKey-_, Params)
     -> true
      % или нет данных
    ; \+ current_predicate(Query)
    ),
    % сопоставить параметры с данными выполнения
    member_list(Params, Pairs),
    % подготовить SQL-запрос
    prepare_sql(SQL0, Params, SQL),
    % записать данные по SQL-запросу
    PairsNextStep = [pEmplKey-EmplKey, pQuery-Query, pSQL-SQL],
    new_param_list(Scope, TypeNextStep, PairsNextStep),
    true.

% выгрузка выходных данных по сотруднику
pu_calc_out(Scope, EmplKey, Result) :-
    % - для ПУ
    memberchk(Scope, [wg_pu_3]),
    Type = run, Section = PK,
    % первичный ключ
    PK = [pEmplKey-EmplKey],
    % взять данные выполнения
    get_param_list(Scope, Type, PK),
    % оформить ЭД
    once( ( get_data(Scope, kb, usr_wg_PersonalCard, [
                        fEmplKey-EmplKey, fF-F, fI-I, fO-O,
                        fPersonalNumber-PersonalNumber, fPensionerDate-PensionerDate ])
          ; get_data(Scope, kb, gd_people, [
                        fEmplKey-EmplKey, fF-F, fI-I, fO-O,
                        fPersonalNumber-PersonalNumber ]),
            PensionerDate = '2100-01-01'
    ) ),
    get_param_list(Scope, in, [
                    pEmplKey-EmplKey, pEDocType-EDocType,
                    pDateBegin-DateBegin, pDateEnd-DateEnd,
                    pUNPF-UNPF, pPhoneNum-PhoneNum ]),
    ( EDocType = 0,
      PensionerDate @>= DateBegin,
      PensionerDate @=< DateEnd
     -> get_param_list(Scope, dict, [pEDocType-1, pEDocCode-EDocCode])
    ; get_param_list(Scope, dict, [pEDocType-EDocType, pEDocCode-EDocCode])
    ),
    get_local_date_time(CurrentDate, _),
    cast_date(CurrentDate, EDocDate),
    once( get_param_list(Scope, temp, [
                            pEmplKey-EmplKey, pRepYM-EDocYear-_ ])
    ),
    %
    get_param_list(Scope, temp, [
                    pEmplKey-EmplKey,
                    pCatType-CatType, pWorkPeriods-WorkPeriods ]),
    ( CatType = 1
    ; CatType = 3,
      member(FirstMoveKey/_-_, WorkPeriods)
    ),
    ( CatType = 3,
      get_data(Scope, kb, usr_wg_Contract, [
                fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                fDocumentDate-DocumentDate, fNumber-Number
                ])
     ->
      cast_date(DocumentDate, Date)
    ; Date = " ", Number = " "
    ),
    %
    get_param_list(Scope, dict, [
                    pCategory,
                    pCatType-CatType, pCatCode-CatCode ]),
    %
    findall( FeeAmount,
             get_param_list(Scope, temp, [
                             pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                             pCatType-CatType,
                             pYM-Y-M, pFeeAmount-FeeAmount ]),
    FeeAmountList ),
    sum_list(FeeAmountList, EDocFeeAmount),
    %
    findall( SickAmount,
             get_param_list(Scope, temp, [
                             pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                             pCatType-CatType,
                             pYM-Y-M, pSickAmount-SickAmount ]),
    SickAmountList ),
    sum_list(SickAmountList, EDocSickAmount),
    findall( 1,
             get_param_list(Scope, temp, [
                             pEmplKey-EmplKey, pRepYM-Y-M ]),
    RepCountList ),
    sum_list(RepCountList, EDocRepCount),
    %
    findall( 1,
             ( get_param_list(Scope, temp, [
                                pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                                pCatType-CatType, pExpPeriod/ExpPeriod ]),
               ExpPeriod = _-_/ExpType,
               ExpType >= 0
             ),
    ExpCountList ),
    sum_list(ExpCountList, EDocExpCount),
    %
    %(EDocFeeAmount + EDocSickAmount) > 0,
    %
    format( string(EDocHeader),
            "~w~w~w~w~w~w~w~w~w~w~w~w~w~w~w~w~w~w~w~0f~w~0f~w~0f~w~0f~w~w~w~w~w~w~w~n",
            [ "<ПУ-3=", EDocCode, "=", UNPF, "=", PersonalNumber, "=",
              F, "=", I, "=", O, "=", CatCode, "=", Number, "=", Date, "= = =",
              EDocFeeAmount, "=", EDocSickAmount, "=0=0=",
              EDocRepCount, "=", EDocExpCount, "=",
              EDocDate, "= =", EDocYear, "=", PhoneNum, "="
            ] ),
    %
    findall( FeeStr,
             ( get_param_list(Scope, temp, [pEmplKey-EmplKey, pRepYM-Y-M]),
               get_param_list(Scope, temp, [
                               pEmplKey-EmplKey, pCatType-CatType,
                               pYM-Y-M, pFeeAmount-FeeAmount ]),
               get_param_list(Scope, temp, [
                               pEmplKey-EmplKey, pCatType-CatType,
                               pYM-Y-M, pSickAmount-SickAmount ]),
               ( get_param_list(Scope, temp, [
                                  pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                                  pCatType-CatType, pExpPeriod/ExpPeriod ]),
                 ExpPeriod = ExpBegin-ExpEnd/ExpType,
                 ExpType >= 0,
                 between(1, 31, TheDay),
                 atom_date(ExpBegin1, date(Y, M, TheDay)),
                 ExpBegin1 @>= ExpBegin,
                 ExpBegin1 @=< ExpEnd
                -> true
               ),
               %check_point(Y-M-ExpPeriod),
               ( CatType = 3
                -> FeeAmount + SickAmount > 0
               ; true
               ),
               format( string(FeeStr),
                       "~w~0f~w~0f~w~0f~w~n",
                       [ "НЧСЛ=", M, "=",
                         FeeAmount, "=", SickAmount, "=0=0=0="
                       ] )
             ),
    FeeStrList ),
    %
    findall( ExpStr,
             ( get_param_list(Scope, temp, [
                                pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                                pCatType-CatType, pExpPeriod/ExpPeriod ]),
               ExpPeriod = ExpBegin-ExpEnd/ExpType,
               ExpType > 0,
               get_param_list(Scope, dict, [pExpType-ExpType, pExpCode-ExpCode]),
               cast_date(ExpBegin, EDocExpBegin),
               cast_date(ExpEnd, EDocExpEnd),
               format( string(ExpStr1),
                       "~w~w~w~w~w~w~w~n",
                       [ "СТАЖ=", EDocExpBegin, "=", EDocExpEnd, "= =",
                         ExpCode, "= = ="
                     ] ),
               ( CatType = 3, ExpType = 1
                ->
                 get_param_list(Scope, dict, [pExpType-5, pExpCode-ExpCode5]),
                 format( string(ExpStr2),
                         "~w~w~w~w~w~w~w~n",
                         [ "СТАЖ=", EDocExpBegin, "=", EDocExpEnd, "= =",
                           ExpCode5, "= = ="
                       ] )
               ; ExpStr2 = ""
               ),
               atomic_list_to_string([ExpStr1, ExpStr2], ExpStr)
             ),
    ExpStrList ),
    %
    append([[EDocHeader], FeeStrList, ExpStrList, [">\n"]], ResultList),
    atomic_list_to_string(ResultList, Result),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    true.

cast_date(CurrentDate, EDocDate) :-
    atom_chars(CurrentDate, [Y1, Y2, Y3, Y4, '-', M1, M2, '-', D1, D2]),
    atom_chars(EDocDate, [D1, D2, '/', M1, M2, '/', Y1, Y2, Y3, Y4]),
    !.

% удаление данных по сотруднику
pu_clean(Scope, EmplKey) :-
    gd_pl_ds(Scope, Type, PredicateName, Arity, _),
    Query = PredicateName/Arity,
    is_valid_sql(Query),
    get_sql(Scope, Type, Query, _, Params),
    memberchk(pEmplKey-_, Params),
    del_data(Scope, Type, PredicateName, [fEmplKey-EmplKey]),
    fail.
pu_clean(Scope, EmplKey) :-
    get_scope_type(Scope-Type),
    get_param_list(Scope, Type, [pEmplKey-EmplKey], Pairs),
    dispose_param_list(Scope, Type, Pairs),
    fail.
pu_clean(_, _) :-
    !.

/**/

 %
%%
