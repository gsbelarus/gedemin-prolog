%

date_add(Date, Add, Part, Date1) :-
    ground(Date), is_date(Date),
    number(Add), date_part(Part),
    ( atom(Date), atom_date(Date, Date2) ; Date2 = Date ),
    date_shift(Date2, Add, Part, Date3),
    ( atom(Date), atom_date(Date1, Date3) ; Date1 = Date3 ),
    !.

date_shift(Date, 0, _, Date) :-
    !.

date_shift(Date, Add, Part, Date1) :-
    Shift is sign(Add),
    date_shift_one(Date, Part, Date2, Shift),
    Add1 is Add - Shift,
    !,
    date_shift(Date2, Add1, Part, Date1).

date_shift_one(date(Y, M, D), day, date(Y, M, D1), Shift) :-
    D1 is D + Shift,
    is_date(date(Y, M, D1)),
    !.

date_shift_one(date(Y, M, _), day, date(Y, M1, D1), Shift) :-
    M1 is M + Shift,
    ( 1 is Shift,  D1 is 1 ; month_days(_, M1, D1) ),
    is_date(date(Y, M1, D1)),
    !.

date_shift_one(date(Y, _, _), day, date(Y1, M1, D1), Shift) :-
    Y1 is Y + Shift,
    ( 1 is Shift -> M1 is 1, D1 is 1 ; M1 is 12, D1 is 31 ),
    is_date(date(Y1, M1, D1)),
    !.

date_shift_one(date(Y, M, D), month, date(Y, M1, D), Shift) :-
    M1 is M + Shift,
    is_date(date(Y, M1, D)),
    !.

date_shift_one(date(Y, M, _), month, date(Y, M1, D1), Shift) :-
    M1 is M + Shift,
    month_days(_, M1, D1),
    is_date(date(Y, M1, D1)),
    !.

date_shift_one(date(Y, _, D), month, date(Y1, M1, D), Shift) :-
    Y1 is Y + Shift,
    ( 1 is Shift -> M1 is 1 ; M1 is 12 ),
    is_date(date(Y1, M1, D)),
    !.

date_shift_one(date(Y, M, D), year, date(Y1, M, D), Shift) :-
    Y1 is Y + Shift,
    is_date(date(Y1, M, D)),
    !.

date_shift_one(date(Y, M, _), year, date(Y1, M, D1), Shift) :-
    Y1 is Y + Shift,
    month_days(Y1, M, D1),
    is_date(date(Y1, M, D1)),
    !.

date_part(year).
date_part(month).
date_part(day).

atom_date(YYYYMMDD, date(YYYY, MM, DD)) :-
    atom(YYYYMMDD),
    ( var(YYYY) ; number(YYYY) ),
    ( var(MM) ; number(MM) ),
    ( var(DD) ; number(DD) ),
    !,
    atom_chars(YYYYMMDD, [Y1, Y2, Y3, Y4, '-', M1, M2, '-', D1, D2]),
    catch( number_chars(YYYY, [Y1, Y2, Y3, Y4]), _, fail ),
    catch( number_chars(MM, [M1, M2]), _, fail ),
    catch( number_chars(DD, [D1, D2]), _, fail ),
    is_date(date(YYYY, MM, DD)).

atom_date(YYYYMMDD, date(Y, M, D)) :-
    var(YYYYMMDD),
    number(Y), number(M), number(D),
    !,
    is_date(date(Y, M, D)),
    number_chars(Y, Ys), chars_nnnn(Ys, [Y1, Y2, Y3, Y4]),
    number_chars(M, Ms), chars_nn(Ms, [M1, M2]),
    number_chars(D, Ds), chars_nn(Ds, [D1, D2]),
    atom_chars(YYYYMMDD, [Y1, Y2, Y3, Y4, '-', M1, M2, '-', D1, D2]),
    !.

chars_nnnn([N1, N2, N3, N4], [N1, N2, N3, N4]).
chars_nnnn([N2, N3, N4], ['0', N2, N3, N4]).
chars_nnnn([N3, N4], ['0', '0', N3, N4]).
chars_nnnn([N4], ['0', '0', '0', N4]).

chars_nn([N1, N2], [N1, N2]).
chars_nn([N2], ['0', N2]).

is_date(date(Y, M, D)) :-
    number(Y), number(M), number(D),
    !,
    Y >= 0, Y =< 9999,
    month_days(Y, M, LastDay),
    D > 0, D =< LastDay,
    !.

is_date(YYYYMMDD) :-
    atom(YYYYMMDD),
    atom_date(YYYYMMDD, Date),
    !,
    is_date(Date).

month_days(_, 1, 31).
month_days(YYYY, 2, 29) :-
    0 is YYYY mod 400,
    !.
month_days(YYYY, 2, 29) :-
    0 is YYYY mod 4,
    \+ 0 is YYYY mod 100.
month_days(_, 2, 28).
month_days(_, 3, 31).
month_days(_, 4, 30).
month_days(_, 5, 31).
month_days(_, 6, 30).
month_days(_, 7, 31).
month_days(_, 8, 31).
month_days(_, 9, 30).
month_days(_, 10, 31).
month_days(_, 11, 30).
month_days(_, 12, 31).

%