%
:- module( date, [
            get_local_date_time/1,  %% -DateTime
                                    % 'yyyy-mm-dd hh:nn:ss'
            get_local_date_time/2,  %% -Date, -Time
                                    % 'yyyy-mm-dd', 'hh:nn:ss'
            date_add/4,             %% +Date, +Add, +Part, -Date1
                                    % Part: year; month; day
            date_diff/3,            %% +Date, ?Add, +Date1
                                    %
            atom_date/2,            %% ?Atom, ?Date
                                    % 'yyyy-mm-dd', date(Y,M,D)
            is_date/1,              %% +Date
                                    % 'yyyy-mm-dd' or date(Y,M,D)
            month_days/3            %% +Year, ?Month, ?Days
                                    %
            ]).

%
get_local_date_time(DateTime) :-
    get_local_date_time(Date, Time),
    atomic_list_concat([Date, ' ', Time], DateTime),
    !.
%
get_local_date_time(Date, Time) :-
    get_time(TimeStamp),
    stamp_date_time(TimeStamp, DateTime, local),
    DateTime = date(Y, M, D, H, N, S,_,_,_),
    atom_date(Date, date(Y,M,D)),
    number_chars(H, Hs), chars_nn(Hs, [H1, H2]),
    number_chars(N, Ns), chars_nn(Ns, [N1, N2]),
    S0 is round(S),
    number_chars(S0, Ss), chars_nn(Ss, [S1, S2]),
    atom_chars(Time, [H1, H2, ':', N1, N2, ':', S1, S2]),
    !.

%
date_add(Date, Add, Part, Date1) :-
    is_date(Date), integer(Add), date_part(Part),
    ( atom(Date), atom_date(Date, Date2) ; Date2 = Date ),
    !,
    date_shift(Date2, Add, Part, Date3),
    ( atom(Date), atom_date(Date1, Date3) ; Date1 = Date3 ),
    !.

%
date_shift(Date, 0, _, Date) :-
    !.
 date_shift(Date, Add, Part, Date1) :-
    Shift is sign(Add),
    date_shift_one(Date, Part, Date2, Shift),
    Add1 is Add - Shift,
    !,
    date_shift(Date2, Add1, Part, Date1).

%
date_diff(Date, Add, Date1) :-
    is_date(Date), is_date(Date1),
    ( atom(Date), atom_date(Date, Date2) ; Date2 = Date ),
    ( atom(Date1), atom_date(Date1, Date3) ; Date3 = Date1 ),
    ( Date @< Date1, Shift = 1; Date @> Date1, Shift = -1 ; Shift = 0),
    !,
    date_diff(Date2, Add, day, Date3, Shift, 0),
    !.

%
date_diff(Date, Add, _, Date, _, Add) :-
    !.
date_diff(Date, Add, Part, Date1, Shift, Add0) :-
    date_shift_one(Date, Part, Date2, Shift),
    plus(Add0, Shift, Add1),
    !,
    date_diff(Date2, Add, Part, Date1, Shift, Add1).

%
date_shift_one(date(Y, M, D), day, date(Y, M, D1), Shift) :-
    plus(D, Shift, D1),
    is_date(date(Y, M, D1)),
    !.
date_shift_one(date(Y, M, _), day, date(Y, M1, D1), Shift) :-
    plus(M, Shift, M1),
    ( Shift == 1 ->  D1 = 1 ; month_days(Y, M1, D1) ),
    is_date(date(Y, M1, D1)),
    !.
date_shift_one(date(Y, _, _), day, date(Y1, M1, D1), Shift) :-
    plus(Y, Shift, Y1),
    ( Shift == 1 -> M1 is 1, D1 = 1 ; M1 = 12, D1 = 31 ),
    is_date(date(Y1, M1, D1)),
    !.
date_shift_one(date(Y, M, D), month, date(Y, M1, D), Shift) :-
    plus(M, Shift, M1),
    is_date(date(Y, M1, D)),
    !.
date_shift_one(date(Y, M, _), month, date(Y, M1, D1), Shift) :-
    plus(M, Shift, M1),
    month_days(Y, M1, D1),
    is_date(date(Y, M1, D1)),
    !.
date_shift_one(date(Y, _, D), month, date(Y1, M1, D), Shift) :-
    plus(Y, Shift, Y1),
    ( Shift == 1 -> M1 = 1 ; M1 = 12 ),
    is_date(date(Y1, M1, D)),
    !.
date_shift_one(date(Y, M, D), year, date(Y1, M, D), Shift) :-
    plus(Y, Shift, Y1),
    is_date(date(Y1, M, D)),
    !.
date_shift_one(date(Y, M, _), year, date(Y1, M, D1), Shift) :-
    plus(Y, Shift, Y1),
    month_days(Y1, M, D1),
    is_date(date(Y1, M, D1)),
    !.

%
date_part(year).
date_part(month).
date_part(day).

%
atom_date(YYYYMMDD, date(YYYY, MM, DD)) :-
    atom(YYYYMMDD),
    ( var(YYYY) ; integer(YYYY) ),
    ( var(MM) ; integer(MM) ),
    ( var(DD) ; integer(DD) ),
    !,
    atom_chars(YYYYMMDD, [Y1, Y2, Y3, Y4, '-', M1, M2, '-', D1, D2 | Time ]),
    is_time_chars(Time),
    catch( number_chars(YYYY, [Y1, Y2, Y3, Y4]), _, fail ),
    catch( number_chars(MM, [M1, M2]), _, fail ),
    catch( number_chars(DD, [D1, D2]), _, fail ),
    is_date(date(YYYY, MM, DD)),
    !.
%
atom_date(YYYYMMDD, date(Y, M, D)) :-
    var(YYYYMMDD),
    integer(Y), integer(M), integer(D),
    !,
    is_date(date(Y, M, D)),
    number_chars(Y, Ys), chars_nnnn(Ys, [Y1, Y2, Y3, Y4]),
    number_chars(M, Ms), chars_nn(Ms, [M1, M2]),
    number_chars(D, Ds), chars_nn(Ds, [D1, D2]),
    atom_chars(YYYYMMDD, [Y1, Y2, Y3, Y4, '-', M1, M2, '-', D1, D2]),
    !.

%
chars_nnnn([N1, N2, N3, N4], [N1, N2, N3, N4]).
chars_nnnn([N2, N3, N4], ['0', N2, N3, N4]).
chars_nnnn([N3, N4], ['0', '0', N3, N4]).
chars_nnnn([N4], ['0', '0', '0', N4]).

%
chars_nn([N1, N2], [N1, N2]).
chars_nn([N2], ['0', N2]).

%
is_date(date(Y, M, D)) :-
    integer(Y), integer(M), integer(D),
    between(1994, 2054, Y),
    month_days(Y, M, LastDay),
    between(1, LastDay, D),
    !.
%
is_date(YYYYMMDD) :-
    atom(YYYYMMDD),
    atom_date(YYYYMMDD, Date),
    !,
    is_date(Date).

%
month_days(Year, 2, Days) :-
    month_days_feb(Year, 2, Days),
    !.
month_days(_, Month, Days) :-
    month_days_other(Month, Days),
    !.

%
month_days_feb(Year, 2, 29) :-
    integer(Year),
    0 is Year mod 400.
month_days_feb(Year, 2, 29) :-
    integer(Year),
    0 is Year mod 4,
    \+ 0 is Year mod 100.
month_days_feb(_, 2, 28).

%
month_days_other(1, 31).
month_days_other(3, 31).
month_days_other(4, 30).
month_days_other(5, 31).
month_days_other(6, 30).
month_days_other(7, 31).
month_days_other(8, 31).
month_days_other(9, 30).
month_days_other(10, 31).
month_days_other(11, 30).
month_days_other(12, 31).

%
is_time_chars([]) :-
    !.
is_time_chars([' '|Time]) :-
    is_time_chars(Time),
    !.
is_time_chars([H1, H2, ':', Mn1, Mn2, ':', S1, S2 | FFF ]) :-
    !,
    is_fract_chars(FFF),
    catch( number_chars(HH, [H1, H2]), _, fail ),
    HH >= 0, HH < 24,
    catch( number_chars(Mn, [Mn1, Mn2]), _, fail ),
    Mn >= 0, Mn < 60,
    catch( number_chars(SS, [S1, S2]), _, fail ),
    SS >= 0, SS < 60,
    !.

%
is_fract_chars([]) :-
    !.
is_fract_chars(['.', F1, F2, F3]) :-
    catch( number_chars(FFF, [F1, F2, F3]), _, fail ),
    integer(FFF),
    !.
    
%