% Примеры использования PL-объектов

hello_world(Msg) :-
    format(atom(Msg), '~w~w~w', ['Hello', ' ', 'World']).
hello_world(Msg) :-
    findall(X, some_fact(X), Xs),
    atomic_list_concat(Xs, Msg).
hello_world("Hello last World").

some_fact(hello).
some_fact('Next').
some_fact("World").

some_fact(1, 'Delphi').
some_fact(2, 'VBScript').
some_fact(3, 'Firebird').
some_fact(4, 'FastReport').
some_fact(5, 'SWI-Prolog').
some_fact(none, 0).
some_fact('1995-01-01', "Анжелика").
some_fact('2003-01-01', "Гедымин").
some_fact('2015-01-01', 2.6).

:- dynamic([gd_place/4]).

% gd_place(ID, Parent, Name, PlaceType)

place_info(Name, PlaceName, PlaceType) :-
    place_name_type(_, Name, PlaceName, PlaceType).

place_name_type(ID, Name, Name, PlaceType) :-
    gd_place(ID, _, Name, PlaceType).
place_name_type(ID, Name, PlaceName, PlaceType) :-
    gd_place(ID, Parent, Name, _),
    place_name_type(Parent, _, PlaceName, PlaceType).

:-  style_check(-atom).

gd_sql(gd_place,
"
SELECT
  p.ID, p.PARENT, p.NAME, p.PLACETYPE
FROM
  GD_PLACE p
"
).

