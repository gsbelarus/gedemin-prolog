% lib

% over_list(+Over, +List)
over_list(Over, [Head|[]]) :-
    Over >= Head.
over_list(Over, [Head|Tail]) :-
    Over >= Head,
    !,
    over_list(Over, Tail).

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

% replace_all(+In, +Search, +Replace, -Out)
replace_all(In, Search, Replace, Out) :-
    replace(In, Search, Replace, In1),
    \+ In = In1,
    !,
    replace_all(In1, Search, Replace, Out).
replace_all(In, _, _, In).

%
term_to_atom_list([], []).
term_to_atom_list([Head|Tail], [Head1|Tail1]) :-
    ( atom(Head), Head1 = Head ; term_to_atom(Head, Head1) ),
    !,
    term_to_atom_list(Tail, Tail1).

%
atom_chars_list([], []).
atom_chars_list([Head|Tail], [Head1|Tail1]) :-
    atom_chars(Head, Head1),
    !,
    atom_chars_list(Tail, Tail1).

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
member_list([], _).
member_list([Head|Tail], List) :-
    member(Head, List),
    member_list(Tail, List).

%
ground_list([]).
ground_list([Head|Tail]) :-
    ground(Head),
    ground_list(Tail).

%
atom_list([]).
atom_list([Head|Tail]) :-
    atom(Head),
    atom_list(Tail).

%
atomic_list([]).
atomic_list([Head|Tail]) :-
    atomic(Head),
    atomic_list(Tail).

%
integer_list([]).
integer_list([Head|Tail]) :-
    integer(Head),
    integer_list(Tail).

%
