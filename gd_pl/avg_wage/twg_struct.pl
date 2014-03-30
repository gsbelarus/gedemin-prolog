% twg_struct

% расчет структуры
% - для отпусков
% - для больничных

:- retractall(debug_mode).

% ! при использовании в ТП Гедымин
% ! для begin & end debug mode section
% ! убрать символ процента из первой позиции
%/* %%% begin debug mode section

%% saved state
:- ['../gd_pl_state/load_atom', '../gd_pl_state/date', '../gd_pl_state/dataset'].
%%

%% include
%#INCLUDE lib
:- [lib].
%#INCLUDE params
:- [params].
%%
%#INCLUDE twg_struct_sql
:- [twg_struct_sql].
%#INCLUDE twg_struct_in_params
%:- [twg_struct_in_params].

%% facts
:-  init_data,
    [
    wg_holiday,
    wg_vacation_slice,
    gd_const_budget,
    usr_wg_TblDayNorm
    ].
%%
%% dynamic state
:- [param_list].
%%

%% flag
:- assertz(debug_mode).
%%

% ! при использовании в ТП Гедымин
% ! для begin & end debug mode section
% ! убрать символ процента из первой позиции
%*/ %%% end debug mode section

:- ps32k_lgt(64, 128, 64).

:- init_data.

/* реализация */

struct_vacation_sql(DocKey, DateBegin, DateEnd, PredicateName, Arity, SQL) :-
    Pairs = [pDocKey-DocKey, pDateBegin-DateBegin, pDateEnd-DateEnd],
    get_sql(wg_struct_vacation, in, Query, SQL0, Params),
    is_valid_sql(Query),
    Query = PredicateName/Arity,
    member_list(Params, Pairs),
    prepare_sql(SQL0, Params, SQL),
    Pairs1 = [pDocKey-DocKey,
              pQuery-Query, pSQL-SQL],
    new_param_list(wg_struct_vacation, run, Pairs1).

struct_sick_sql(EmplKey, FirstMoveKey, DateBegin, DateEnd, PredicateName, Arity, SQL) :-
    DateCalcFrom = DateBegin,
    date_add(DateEnd, 1, day, DateCalcTo),
    Pairs0 = [pBudget_xid-147073065, pBudget_dbid-1224850260],
    get_param_list(wg_struct_sick, in, Pairs0),
    append(Pairs0,
                [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
                 pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo],
            Pairs),
    new_param_list(wg_struct_sick, run, Pairs),
    get_sql(wg_struct_sick, in, Query, SQL0, Params),
    is_valid_sql(Query),
    Query = PredicateName/Arity,
    member_list(Params, Pairs),
    prepare_sql(SQL0, Params, SQL),
    Pairs1 = [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey,
              pQuery-Query, pSQL-SQL],
    new_param_list(wg_struct_sick, run, Pairs1).

struct_vacation_in(DateCalc, DateBegin, DateEnd, AvgWage, SliceOption) :-
    atom_date(DateCalc, date(Year, Month, _)),
    month_days(Year, Month, Days),
    atom_date(AccDate, date(Year, Month, Days)),
    once( (SliceOption = 0, FilterVcType = 0 ; true) ),
    findall( VcType-Slice,
                ( wg_vacation_slice(VcType, Slice), VcType = FilterVcType ),
             SliceList0 ),
    keysort(SliceList0, [Slice0|SliceList1]),
    append(SliceList1, [Slice0], SliceList),
    struct_vacation_calc(SliceList, _-0, AccDate, DateBegin, DateEnd, AvgWage),
    !.

struct_sick_in(DateCalc, DateBegin, DateEnd, AvgWage, CalcType, BudgetOption) :-
    atom_date(DateCalc, date(Year, Month, _)),
    month_days(Year, Month, Days),
    atom_date(AccDate, date(Year, Month, Days)),
    Pairs = [pFirstCalcType-FirstCalcType,
             pFirstDuration-FirstDuration, pFirstPart-FirstPart],
    get_param_list(wg_struct_sick, in, Pairs),
    date_diff(DateBegin, Duration0, DateEnd),
    Duration is Duration0 + 1,
    ( CalcType = FirstCalcType,
      SliceList0 = [FirstPart-FirstDuration]
    ;
      SliceList0 = []
    ),
    append(SliceList0, [1.0-Duration], SliceList),
    struct_sick_calc(SliceList, _-0, AccDate, DateBegin, DateEnd, AvgWage, BudgetOption),
    !.

struct_vacation_calc([Slice|SliceList], _-Slice0, AccDate, DateBegin, DateEnd, AvgWage) :-
    Slice0 =:= 0,
    !,
    struct_vacation_calc(SliceList, Slice, AccDate, DateBegin, DateEnd, AvgWage).
struct_vacation_calc(_, _, _, '', '', _) :-
    !.
struct_vacation_calc([], _-Slice, _, _, _, _) :-
    Slice =:= 0,
    !.
struct_vacation_calc(SliceList, VcType-Slice, AccDate, DateBegin, DateEnd, AvgWage) :-
    make_period(DateBegin, DateEnd, DateBegin1, DateEnd1, DateBegin2, DateEnd2, Slice, Slice2),
    atom_date(DateBegin1, date(Y, M, _)),
    atom_date(IncludeDate, date(Y, M, 1)),
    sum_vacation_days(DateBegin1, DateEnd1, 1, Duration),
    Summa is Duration * AvgWage,
    OutPairs = [
                pAccDate-AccDate, pIncludeDate-IncludeDate,
                pDuration-Duration, pSumma-Summa,
                pDateBegin-DateBegin1, pDateEnd-DateEnd1,
                pVcType-VcType
                ],
    new_param_list(struct_vacation, out, OutPairs),
    !,
    struct_vacation_calc(SliceList, VcType-Slice2, AccDate, DateBegin2, DateEnd2, AvgWage).

struct_sick_calc([Slice|SliceList], _-Slice0, AccDate, DateBegin, DateEnd, AvgWage, BudgetOption) :-
    Slice0 =:= 0,
    !,
    struct_sick_calc(SliceList, Slice, AccDate, DateBegin, DateEnd, AvgWage, BudgetOption).
struct_sick_calc(_, _, _, '', '', _, _) :-
    !.
struct_sick_calc([], _-Slice, _, _, _, _, _) :-
    Slice =:= 0,
    !.
struct_sick_calc(SliceList, SickPart-Slice, AccDate, DateBegin, DateEnd, AvgWage0, BudgetOption) :-
    make_period(DateBegin, DateEnd, DateBegin1, DateEnd1, DateBegin2, DateEnd2, Slice, Slice2),
    atom_date(DateBegin1, date(Y, M, _)),
    atom_date(IncludeDate, date(Y, M, 1)),
    Percent is SickPart * 100,
    sum_sick_days(DateBegin1, DateEnd1, 1, DOI, 0, HOI),
    ( BudgetOption = 1,
      get_avg_wage_budget(wg_struct_sick, in, Y, M, AvgWage)
    ;
      AvgWage = AvgWage0
    ),
    Summa is DOI * AvgWage,
    OutPairs = [
                pAccDate-AccDate, pIncludeDate-IncludeDate,
                pPercent-Percent, pDOI-DOI, pHOI-HOI, pSumma-Summa,
                pDateBegin-DateBegin1, pDateEnd-DateEnd1
                ],
    new_param_list(struct_sick, out, OutPairs),
    !,
    struct_sick_calc(SliceList, SickPart-Slice2, AccDate, DateBegin2, DateEnd2, AvgWage0, BudgetOption).

make_period(DateBegin, DateEnd, DateBegin, DateEnd1, DateBegin2, DateEnd2, Slice, Slice2) :-
    head_period(DateBegin, DateEnd, DateEnd1, Slice, Slice2),
    teil_period(DateEnd, DateEnd1, DateBegin2, DateEnd2),
    !.

head_period(DateBegin, DateEnd, DateBegin, Slice, Slice2) :-
   date_add(DateBegin, 1, day, DateBegin1),
   atom_date(DateBegin, date(Y, M, _)),
   ( \+ atom_date(DateBegin1, date(Y, M, _)), next_slice(DateBegin, Slice, Slice2)
   ; DateBegin1 @> DateEnd, Slice2 = 0
   ; Slice =:= 1, next_slice(DateBegin, Slice, Slice2)
   ),
   !.
head_period(DateBegin, DateEnd, DateEnd1, Slice0, Slice2) :-
   date_add(DateBegin, 1, day, DateBegin1),
   next_slice(DateBegin, Slice0, Slice1),
   !,
   head_period(DateBegin1, DateEnd, DateEnd1, Slice1, Slice2).

next_slice(DateBegin, Slice, Slice) :-
   wg_holiday(DateBegin),
   !.
next_slice(_, Slice, Slice2) :-
   Slice2 is Slice - 1,
   !.

teil_period(DateEnd, DateEnd, '', '') :-
    !.
teil_period(DateEnd, DateEnd1, DateBegin2, DateEnd) :-
    date_add(DateEnd1, 1, day, DateBegin2),
    !.

sum_vacation_days(DateBegin, DateBegin, Duration0, Duration1) :-
    ( wg_holiday(DateBegin), Duration1 is Duration0 - 1
    ; Duration1 = Duration0 ),
    !.
sum_vacation_days(DateBegin, DateEnd, Duration0, Duration) :-
    date_add(DateBegin, 1, day, DateBegin1),
    ( wg_holiday(DateBegin), Duration1 = Duration0
    ; Duration1 is Duration0 + 1 ),
    !,
    sum_vacation_days(DateBegin1, DateEnd, Duration1, Duration).

sum_sick_days(DateBegin, DateBegin, DOI, DOI, HOI0, HOI) :-
    get_sick_how(DateBegin, HOW),
    HOI is HOI0 + HOW,
    !.
sum_sick_days(DateBegin, DateEnd, DOI0, DOI, HOI0, HOI) :-
    date_add(DateBegin, 1, day, DateBegin1),
    DOI1 is DOI0 + 1,
    get_sick_how(DateBegin, HOW),
    HOI1 is HOI0 + HOW,
    !,
    sum_sick_days(DateBegin1, DateEnd, DOI1, DOI, HOI1, HOI).
    

get_sick_how(TheDay, WDuration) :-
    Pairs =  [pEmplKey-EmplKey, pFirstMoveKey-FirstMoveKey],
    get_param_list(wg_struct_sick, run, Pairs),
    get_data(wg_struct_sick, in, usr_wg_TblDayNorm, [
                fEmplKey-EmplKey, fFirstMoveKey-FirstMoveKey,
                fTheDay-TheDay, fWDuration-WDuration ]),
    !.
get_sick_how(_, 0) :-
    !.

struct_vacation_out(AccDate, IncludeDate, Duration, Summa, DateBegin, DateEnd, VcType) :-
    OutPairs = [
                pAccDate-AccDate, pIncludeDate-IncludeDate,
                pDuration-Duration, pSumma-Summa,
                pDateBegin-DateBegin, pDateEnd-DateEnd,
                pVcType-VcType
                ],
    get_param_list(struct_vacation, out, OutPairs).

struct_sick_out(AccDate, IncludeDate, Percent, DOI, HOI, Summa, DateBegin, DateEnd) :-
    OutPairs = [
                pAccDate-AccDate, pIncludeDate-IncludeDate,
                pPercent-Percent, pDOI-DOI, pHOI-HOI, pSumma-Summa,
                pDateBegin-DateBegin, pDateEnd-DateEnd
                ],
    get_param_list(struct_sick, out, OutPairs).

% взять среднедневной БПМ на текущий месяц
get_avg_wage_budget(Scope, Type, Y, M, AvgWageBudget) :-
    % первая дата месяца
    atom_date(FirstMonthDate, date(Y, M, 1)),
    % взять БПМ
    findall( Budget0,
                  % взять данные по БПМ
                ( get_data(Scope, Type, gd_const_budget, [
                            fConstDate-ConstDate, fBudget-Budget0]),
                  % где дата константы меньше первой даты месяца
                  ConstDate @< FirstMonthDate
                ),
    % в список БПМ
    BudgetList),
    % проверить список БПМ
    \+ BudgetList = [],
    % последние данные по БПМ за месяц
    last(BudgetList, MonthBudget),
    % календарных дней в месяце
    month_days(Y, M, MonthDays),
    % среднедневной БПМ
    AvgWageBudget is round(MonthBudget / MonthDays),
    !.
get_avg_wage_budget(_, _, _, _, 0) :-
    !.
    
/**/
