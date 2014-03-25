% lib

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
    replace_list(InCodes, SearchCodes, ReplaceCodes, OutCodes),
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
    !,
    \+ In = [].

%
integer_list([]).
integer_list([Head|Tail]) :-
    integer(Head),
    integer_list(Tail).

%
replace_list([InHead1,InHead2,InHead3|InChars], [InHead1,InHead2,InHead3|SearchChars], ReplaceChars, OutChars) :-
    append([InHead1,InHead2,InHead3|SearchChars], RestChars, [InHead1,InHead2,InHead3|InChars]),
    append(ReplaceChars, RestChars, OutChars),
    !.
replace_list([InHead|InChars], [InHead|SearchChars], ReplaceChars, OutChars) :-
    append([InHead|SearchChars], RestChars, [InHead|InChars]),
    append(ReplaceChars, RestChars, OutChars),
    !.
replace_list([InHead|InTail], SearchChars, ReplaceChars, [InHead|OutChars]) :-
    !,
    replace_list(InTail, SearchChars, ReplaceChars, OutChars).

%
remove_list(_, [], []) :-
    !.
remove_list([Elem|Elems], List, Rest) :-
    remove_list(Elem, List, List1),
    remove_list(Elems, List1, Rest),
    !.
remove_list(Elem, [Elem|[]], []).
remove_list(Elem, [Elem|Tail], Rest) :-
    remove_list(Elem, Tail, Rest),
    !.
remove_list(Elem, [Head|Tail], [Head|Rest]) :-
    remove_list(Elem, Tail, Rest).

%
member_list([], _) :-
    !.
member_list([Head|Tail], List) :-
    member(Head, List),
    !,
    member_list(Tail, List).

%
