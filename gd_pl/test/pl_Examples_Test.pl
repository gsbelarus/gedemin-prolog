% Примеры использования PL-объектов

:- dynamic([hello_world_fact/1]).

add_world :-
        assertz( hello_world_fact("Hello dynamic World") ). 

hello_world(Msg) :-
    format(atom(Msg), '~w~w~w', ['Hello', ' ', 'World']).
hello_world(Msg) :-
    findall(X, some_fact(X), Xs),
    atomic_list_concat(Xs, Msg).
hello_world("Hello another World").
hello_world(Msg) :-
    hello_world_fact(Msg).
    
some_fact(hello).
some_fact('Next').
some_fact("World").

some_fact(1, 'Delphi').
some_fact(2, 'VBScript').
some_fact(3, 'Firebird').
some_fact(4, 'FastReport').
some_fact(5, 'SWI-Prolog').
some_fact(none, 0).
some_fact('1995-01-01', "Angelica").
some_fact('2003-01-01', "Gedemin").
some_fact('2015-01-01', 2.6).

