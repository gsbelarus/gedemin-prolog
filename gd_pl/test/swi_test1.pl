% test
:- ['../gd_pl_state/dataset'].

%:- ['tch.qlf'].
% tch(ID, TotalYear, TotalMonth, FeeTypeKey, EmplKey, Debit, Credit)
gd_pl_ds(tch, 7, [
                 fID-_, fTotalYear-_, fTotalMonth-_, fFeeTypeKey-_,
                 fEmplKey-_, fDebit-_, fCredit-_
                 ]).

%
test11(TotalDebit, TotalCredit) :-
    findall( Debit-Credit,
             tch(_, _, _, _, _, Debit, Credit),
    Pairs ),
    sum_pairs(Pairs, TotalDebit-TotalCredit),
    assertz( tch_total(group_by([all]), TotalDebit, TotalCredit) ),
    !.

test41(TotalDebit, TotalCredit) :-
    findall( Debit-Credit,
             get_data(tch, [fDebit-Debit, fCredit-Credit]),
    Pairs ),
    sum_pairs(Pairs, TotalDebit-TotalCredit),
    assertz( tch_total(group_by([all]), TotalDebit, TotalCredit) ),
    !.

%
test12(TotalDebit1, TotalCredit1) :-
    test11(TotalDebit1, TotalCredit1),
    setof( FeeTypeKey,
           ID^TotalYear^TotalMonth^EmplKey^Debit^Credit^
           tch(ID, TotalYear, TotalMonth, FeeTypeKey, EmplKey, Debit, Credit),
    FeeTypeList ),
    forall( member(FeeType, FeeTypeList),
            ( findall( Debit-Credit,
                       tch(_, _, _, FeeType, _, Debit, Credit),
              Pairs),
              sum_pairs(Pairs, TotalDebit2-TotalCredit2),
              assertz( tch_total(group_by([ft-FeeType]), TotalDebit2, TotalCredit2) )
            )
    ),
    !.

test13(TotalDebit1, TotalCredit1) :-
    test12(TotalDebit1, TotalCredit1),
    setof( EmplKey,
           ID^TotalYear^TotalMonth^FeeTypeKey^Debit^Credit^
           tch(ID, TotalYear, TotalMonth, FeeTypeKey, EmplKey, Debit, Credit),
    EmplList ),
    forall( member(Empl, EmplList),
            ( findall( Debit-Credit,
                       tch(_, _, _, _, Empl, Debit, Credit),
              Pairs),
              sum_pairs(Pairs, TotalDebit2-TotalCredit2),
              assertz( tch_total(group_by([empl-Empl]), TotalDebit2, TotalCredit2) )
            )
    ),
    !.

test14(TotalDebit1, TotalCredit1) :-
    test13(TotalDebit1, TotalCredit1),
    setof( FeeTypeKey-EmplKey,
           ID^TotalYear^TotalMonth^Debit^Credit^
           tch(ID, TotalYear, TotalMonth, FeeTypeKey, EmplKey, Debit, Credit),
    FeeTypeEmplList ),
    forall( member(FeeType-Empl, FeeTypeEmplList),
            ( findall( Debit-Credit,
                       tch(_, _, _, FeeType, Empl, Debit, Credit),
              Pairs),
              sum_pairs(Pairs, TotalDebit2-TotalCredit2),
              assertz( tch_total(group_by([ft-FeeType, empl-Empl]), TotalDebit2, TotalCredit2) )
            )
    ),
    !.

test21(TotalDebit1, TotalCredit1) :-
    test11(TotalDebit1, TotalCredit1),
    setof( TotalYear-TotalMonth,
           ID^FeeTypeKey^EmplKey^Debit^Credit^
           tch(ID, TotalYear, TotalMonth, FeeTypeKey, EmplKey, Debit, Credit),
    YMList ),
    forall( member(Y-M, YMList),
            ( findall( Debit-Credit,
                       tch(_, Y, M, _, _, Debit, Credit),
              Pairs),
              sum_pairs(Pairs, TotalDebit2-TotalCredit2),
              assertz( tch_total(group_by([y-Y, m-M]), TotalDebit2, TotalCredit2) )
            )
    ),
    !.

test22(TotalDebit1, TotalCredit1) :-
    test21(TotalDebit1, TotalCredit1),
    setof( TotalYear-TotalMonth-FeeTypeKey,
           ID^EmplKey^Debit^Credit^
           tch(ID, TotalYear, TotalMonth, FeeTypeKey, EmplKey, Debit, Credit),
    YMFTList ),
    forall( member(Y-M-FeeType, YMFTList),
            ( findall( Debit-Credit,
                       tch(_, Y, M, FeeType, _, Debit, Credit),
              Pairs),
              sum_pairs(Pairs, TotalDebit2-TotalCredit2),
              assertz( tch_total(group_by([y-Y, m-M, ft-FeeType]), TotalDebit2, TotalCredit2) )
            )
    ),
    !.

test33(_, _) :-
    bagof( Debit-Credit,
           ID^EmplKey^
           tch(ID, TotalYear, TotalMonth, FeeTypeKey, EmplKey, Debit, Credit),
    Pairs ),
    sum_pairs(Pairs, TotalDebit2-TotalCredit2),
    assertz( tch_total( group_by([y-TotalYear, m-TotalMonth, ft-FeeTypeKey]),
                        TotalDebit2, TotalCredit2 )
           ),
    fail.
test33(_, _) :-
    bagof( Debit-Credit,
           ID^FeeTypeKey^EmplKey^
           tch(ID, TotalYear, TotalMonth, FeeTypeKey, EmplKey, Debit, Credit),
    Pairs ),
    sum_pairs(Pairs, TotalDebit2-TotalCredit2),
    assertz( tch_total( group_by([y-TotalYear, m-TotalMonth]),
                        TotalDebit2, TotalCredit2 )
           ),
    fail.
test33(TotalDebit, TotalCredit) :-
    findall( Debit-Credit,
             tch(_, _, _, _, _, Debit, Credit),
    Pairs ),
    sum_pairs(Pairs, TotalDebit-TotalCredit),
    assertz( tch_total(group_by([all]), TotalDebit, TotalCredit) ),
    !.

test44 :-
    GroupBy = [],
    Data = [fDebit-_, fCredit-_],
    retractall( tch_total( group_by(GroupBy), sum(SumDataList) ) ),
    aggr_sum(tch, GroupBy, Data, SumDataList),
    assertz( tch_total( group_by(GroupBy), sum(SumDataList) ) ),
    fail.
test44 :-
    GroupBy = [fTotalYear-_, fTotalMonth-_],
    Data = [fDebit-_, fCredit-_],
    retractall( tch_total( group_by(GroupBy), sum(SumDataList) ) ),
    aggr_sum(tch, GroupBy, Data, SumDataList),
    assertz( tch_total( group_by(GroupBy), sum(SumDataList) ) ),
    fail.
test44 :-
    GroupBy = [fTotalYear-_, fTotalMonth-_, fFeeTypeKey-_],
    Data = [fDebit-_, fCredit-_],
    retractall( tch_total( group_by(GroupBy), sum(SumDataList) ) ),
    aggr_sum(tch, GroupBy, Data, SumDataList),
    assertz( tch_total( group_by(GroupBy), sum(SumDataList) ) ),
    fail.
test44 :-
    true.

%
test51(OutList1-OutList2-OutList3) :-
    Data = [fDebit-_, fCredit-_],
    %
    GroupBy1 = [],
    findall( GroupBy1-SumDataList,
             aggr_sum(tch, GroupBy1, Data, SumDataList),
    OutList1 ),
    %
    GroupBy2 = [fTotalYear-_, fTotalMonth-_],
    findall( GroupBy2-SumDataList,
             aggr_sum(tch, GroupBy2, Data, SumDataList),
    OutList2 ),
    %
    GroupBy3 = [fTotalYear-_, fTotalMonth-_, fFeeTypeKey-_],
    findall( GroupBy3-SumDataList,
             aggr_sum(tch, GroupBy3, Data, SumDataList),
    OutList3 ),
    !.

%
aggr_sum(Functor, GroupBy, Data, SumDataList) :-
    append(GroupBy, Data, Query),
    bagof( Data, get_data(Functor, Query), DataList ),
    sum_data_list(Data, DataList, SumDataList),
    true.

%
sum_data_list(Data, DataList, SumDataList) :-
    init_sum_data(Data, SumDataList0),
    sum_data_list_(DataList, SumDataList0, SumDataList),
    !.
%
sum_data_list_([], SumDataList, SumDataList).
sum_data_list_([Data|DataList], SumDataList0, SumDataList) :-
    sum_data(Data, SumDataList0, SumDataList1),
    sum_data_list_(DataList, SumDataList1, SumDataList).

%
init_sum_data([], []).
init_sum_data([Key-_|Tail], [Key-0|Rest]) :-
    init_sum_data(Tail, Rest).
    
%
sum_data([], [], []).
sum_data([Key-Value|KeyValues], [Key-Value0|SumDataList0], [Key-Value1|SumDataList1]) :-
    Value1 is Value0 + Value,
    sum_data(KeyValues, SumDataList0, SumDataList1).
    
%
sum_pairs(Pairs, SumPairs) :-
    sum_pairs(Pairs, 0-0, SumPairs),
    !.
%
sum_pairs([], Sum1-Sum2, Sum1-Sum2).
sum_pairs([X1-X2|Xs], Sum01-Sum02, SumPairs) :-
    Sum11 is Sum01 + X1,
    Sum12 is Sum02 + X2,
    sum_pairs(Xs, Sum11-Sum12, SumPairs).
