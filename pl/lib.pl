%

over_list(Over, [ Head | [] ]):-
    Over >= Head.

over_list(Over, [ Head | Tail ]) :-
    Over >= Head,
    !,
    over_list(Over, Tail).

%