%

%
replace(In, Search, Replace, Out) :-
    term_to_atom_list([In, Search, Replace], [In1, Search1, Replace1]),
    atom_chars_list([In1, Search1, Replace1], [InChars, SearchChars, ReplaceChars]),
    replace_list(InChars, SearchChars, ReplaceChars, OutChars),
    atom_chars(Out, OutChars),
    !.

%
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
atom_list([]).
atom_list([Head|Tail]) :-
    atom(Head),
    atom_list(Tail).

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
ground_list([]).
ground_list([Head|Tail]) :-
    ground(Head),
    ground_list(Tail).

%
remove_from_list(_, [], []).
remove_from_list([Elem|Elems], List, Rest) :-
    remove_from_list(Elem, List, List1),
    remove_from_list(Elems, List1, Rest),
    !.
remove_from_list(Elem, [Elem|[]], []).
remove_from_list(Elem, [Elem|Tail], Rest) :-
    remove_from_list(Elem, Tail, Rest),
    !.
remove_from_list(Elem, [Head|Tail], [Head|Rest]) :-
    remove_from_list(Elem, Tail, Rest).

%
member_list([], _).
member_list([Head|Tail], List) :-
    member(Head, List),
    member_list(Tail, List).

%
over_list(Over, [Head|[]]):-
    Over >= Head.
over_list(Over, [Head|Tail]) :-
    Over >= Head,
    !,
    over_list(Over, Tail).

%
