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

generate_some_rec(ID, Name, Number) :-
    integer(Number),
    between(1, Number, ID),
    atomic_list_concat(["Record", ID], Name).
