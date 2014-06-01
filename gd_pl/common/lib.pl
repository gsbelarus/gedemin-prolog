﻿% lib

% день недели
weekday(date(Year, Month, Day), WeekDay) :-
    A is (14 - Month) // 12,
    Y is Year - A,
    M is Month + 12 * A - 2,
    WeekDay0 is (7000 + (Day + Y + Y // 4 - Y // 100 + Y // 400 + (31 * M) // 12)) mod 7,
    WeekDay is WeekDay0 + 1,
    !.
weekday(Date, WeekDay) :-
    atom_date(Date, date(Year, Month, Day)),
    weekday(date(Year, Month, Day), WeekDay),
    !.

% подготовка SQL-строки
prepare_sql(InSQL, [], InSQL) :-
    !.
prepare_sql(InSQL,[Key-Value|Pairs], OutSQL) :-
    replace_all(InSQL, Key, Value, InSQL1),
    !,
    prepare_sql(InSQL1, Pairs, OutSQL).

% to_currency(+NumIn, -NumOut)
to_currency(NumIn, NumOut) :-
    to_currency(NumIn, NumOut, 4),
    !.
% to_currency(+NumIn, -NumOut, +Round)
to_currency(NumIn, NumOut, Round) :-
    number(NumIn), integer(Round),
    NumOut is float( round( NumIn * (10 ** Round) ) / (10 ** Round) ),
    !.

% make_list(+Num, -List)
make_list(Num, List) :-
    integer(Num),
    make_list(Num, List, 0),
    !.
    
make_list(Num, [], Num) :-
    !.
make_list(Num, [_|Tail], Zero) :-
    Num1 is Num - 1,
    !,
    make_list(Num1, Tail, Zero).


% exist_in(+Search, +In)
exist_in(Search, In) :-
    text_list([Search, In], [SearchCodes, InCodes]),
    append(_, MiddleCodes, InCodes),
    append(SearchCodes, _, MiddleCodes),
    !.

% replace_all(+In, +Search, +Replace, -Out)
replace_all(In, Search, Replace, Out) :-
    replace(In, Search, Replace, In1),
    \+ In = In1,
    !,
    replace_all(In1, Search, Replace, Out).
replace_all(In, _, _, In).

% replace(+In, +Search, +Replace, -Out)
replace(In, Search, Replace, Out) :-
    text_list([In, Search, Replace], [InCodes, SearchCodes, ReplaceCodes]),
    append(Part1, MiddleCodes, InCodes),
    append(SearchCodes, Part2, MiddleCodes),
    append([Part1, ReplaceCodes, Part2], OutCodes),
    text_in_out(In, OutCodes, Out),
    !.
replace(In, _, _, In).

%
text_list([], []) :-
    !.
text_list([Head|Teil], [Head1|Rest]) :-
    text_in_out(Head, Head1, Head),
    !,
    text_list(Teil, Rest).

%
text_in_out(In, OutCodes, Out) :-
    ( atom(In), atom_codes(Out, OutCodes)
    ; string(In), string_codes(Out, OutCodes)
    ; number(In), number_codes(Out, OutCodes)
    ; integer_list(In), Out = In ),
    !.

%
integer_list([]) :-
    !.
integer_list([Head|Tail]) :-
    integer(Head),
    !,
    integer_list(Tail).

%
member_list([], _) :-
    !.
member_list([Head|Tail], List) :-
    memberchk(Head, List),
    !,
    member_list(Tail, List).

%