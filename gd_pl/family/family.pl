% family

%/*
:- [gd_family, gd_people, gd_relationship].
%*/


%
parent(Parent, Child) :-
    parent(Parent, Child, _, _, _).
%
parent(Parent, Child, Parent, Name, "отец") :-
    father(Parent, Name, Parent),
    find_child(Parent, Child, _, _, _, _).
parent(Parent, Child, EmplKey, Name, "отец") :-
    father(Parent, Name, EmplKey),
    \+ Parent = EmplKey,
    find_child(EmplKey, Child, _, _, _, _).
parent(Parent, Child, Parent, Name, "мать") :-
    mother(Parent, Name, Parent),
    find_child(Parent, Child, _, _, _, _).
parent(Parent, Child, EmplKey, Name, "мать") :-
    mother(Parent, Name, EmplKey),
    \+ Parent = EmplKey,
    find_child(EmplKey, Child, _, _, _, _).
%
child(Child, Parent) :-
    child(Child, Parent, _).
%
child(Child, Parent, Parent) :-
    parent(Parent, Child, Parent, _, _).
child(Child, Parent, EmplKey) :-
    parent(Parent, Child, EmplKey, _, _),
    \+ Parent = EmplKey.
%
sister(ID1, ID2) :-
    parent(EmplKey, ID1),
    find_child(EmplKey, ID1, _, _, "дочь", _),
    find_child(EmplKey, ID2, _, _, _, _),
    \+ ID1 = ID2.
%
brother(ID1, ID2) :-
    parent(EmplKey, ID1),
    find_child(EmplKey, ID1, _, _, "сын", _),
    find_child(EmplKey, ID2, _, _, _, _),
    \+ ID1 = ID2.
%
father(EmplKey, Name, EmplKey) :-
    gd_people(EmplKey, Name, "M"),
    find_father(EmplKey).
father(ID, FullName, EmplKey) :-
    gd_people(EmplKey, _, "F"),
    find_father(ID, FullName, EmplKey).
%
find_father(EmplKey) :-
    find_child(EmplKey, _, _, _, _, _),
    !.
find_father(ID, FullName, EmplKey) :-
    gd_family(ID, FullName, EmplKey, Kind, _),
    gd_relationship(Kind, "муж"),
    find_child(EmplKey, _, _, _, _, _),
    !.
%
mother(EmplKey, Name, EmplKey) :-
    gd_people(EmplKey, Name, "F"),
    find_mother(EmplKey).
mother(ID, FullName, EmplKey) :-
    gd_people(EmplKey, _, "M"),
    find_mother(ID, FullName, EmplKey).
%
find_mother(EmplKey) :-
    find_child(EmplKey, _, _, _, _, _),
    !.
find_mother(ID, FullName, EmplKey) :-
    gd_family(ID, FullName, EmplKey, Kind, _),
    gd_relationship(Kind, "жена"),
    find_child(EmplKey, _, _, _, _, _),
    !.
%
find_child(EmplKey, ID, FullName, Kind, KindName, DateOfBirth) :-
    gd_family(ID, FullName, EmplKey, Kind, DateOfBirth),
    gd_relationship(Kind, KindName),
    (KindName = "сын" ; KindName = "дочь").

%
