%

over_list(Over, [Head|[]]):-
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
    
make_list(Num, [], Num).
make_list(Num, [_|Tail], Zero) :-
    Num1 is Num - 1,
    !,
    make_list(Num1, Tail, Zero).

% replace(+In, +Search, +Replace, -Out)
replace(In, Search, Replace, Out) :-
    atomic_list([In, Search, Replace]),
    term_to_atom_list([In, Search, Replace], [In1, Search1, Replace1]),
    atom_chars_list([In1, Search1, Replace1], [InChars, SearchChars, ReplaceChars]),
    replace_list(InChars, SearchChars, ReplaceChars, OutChars),
    atom_chars(Out, OutChars),
    !.

% replace_all(+In, +Search, +Replace, -Out)
replace_all(In, Search, Replace, Out) :-
    replace(In, Search, Replace, In1),
    !,
    replace_all(In1, Search, Replace, Out).
replace_all(In, _, _, In).

%
replace_list(InChars, SearchChars, ReplaceChars, OutChars) :-
    append(SearchChars, RestChars, InChars),
    append(ReplaceChars, RestChars, OutChars),
    !.
replace_list([InHead|InTail], SearchChars, ReplaceChars, [InHead|OutChars]) :-
    !,
    replace_list(InTail, SearchChars, ReplaceChars, OutChars).

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
