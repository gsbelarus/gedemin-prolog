% lib

%:- ['../gd_pl_state/date'].

:- dynamic(denom_mode/0).
% ! для режима деноминации убрать комментарий в следующей строке
%:- assertz(denom_mode).

:- ( \+ locale_property(ru, _),
     locale_create(_, default, [
                               alias(ru),
                               decimal_point(','),
                               thousands_sep(' '),
                               grouping([repeat(3)])
                               ])
   ; true ).

:- ( \+ locale_property(comma, _),
     locale_create(_, default, [
                               alias(comma),
                               decimal_point(','),
                               thousands_sep(''),
                               grouping([repeat(3)])
                               ])
   ; true ).

:- ( \+ locale_property(dot, _),
     locale_create(_, default, [
                               alias(dot),
                               decimal_point('.'),
                               thousands_sep(''),
                               grouping([repeat(3)])
                               ])
   ; true ).
   
:- set_locale(comma).

% format_br(+InStr, -OutStr)
:- if(denom_mode).
format_br(InStr, OutStr) :-
    Search = "~0f", Replace = "~2:f",
    replace_all(InStr, Search, Replace, OutStr),
    !.
:- else.
format_br(Str, Str).
:- endif.

% round_br(+ExpIn, -NumOut)
:- if(denom_mode).
round_br(ExpIn, NumOut) :-
    % BYN
    round_br(ExpIn, NumOut, 2).
:- else.
round_br(ExpIn, NumOut) :-
    % BYR
    round_br(ExpIn, NumOut, 0).
:- endif.

% round_br(+ExpIn, -NumOut, +Round)
round_br(ExpIn, NumOut, Round) :-
   NumIn is ExpIn,
   to_currency(NumIn, NumOut, Round).
    
% desc for predsort
desc(Order, Term1, Term2) :-
    compare(Order0, Term1, Term2),
    ( Order0 = '>', Order = '<'
    ; Order0 = '<', Order = '>'
    ; Order = Order0
    ),
    !.

% round_sum(+SumIn, -SumOut, +RoundType, +RoundValue)
:- if(denom_mode).
round_sum(SumIn, SumOut, _, _) :-
    % BYN
    to_currency(SumIn, SumOut, 2).
:- else.
round_sum(SumIn, SumOut, RoundType, RoundValue) :-
    % BYR
    number(SumIn), integer(RoundType), number(RoundValue),
    Delta = 0.00001,
    round_sum(SumIn, SumOut, RoundType, RoundValue, Delta),
    !.
:- endif.

% round_sum(+SumIn, -SumOut, +RoundType, +RoundValue, +Delta)
round_sum(SumIn, SumOut, 1, _, Delta) :-
    round_sum(SumIn, SumOut, 2, 10, Delta).
round_sum(SumIn, SumOut, 2, RoundValue, Delta) :-
    SumOut is round((SumIn + Delta) / RoundValue) * RoundValue,
    !.
round_sum(SumIn, SumOut, 3, RoundValue, Delta) :-
    SumOut is float_integer_part((SumIn + Delta) / RoundValue) * RoundValue,
    !.
round_sum(Sum, Sum, _, _, _) :-
    !.

% to_currency(+NumIn, -NumOut)
to_currency(NumIn, NumOut) :-
    to_currency(NumIn, NumOut, 4),
    !.
% to_currency(+NumIn, -NumOut, +Round)
to_currency(NumIn, NumOut, Round) :-
    number(NumIn), integer(Round),
    NumOut is float( round( NumIn * (10 ** Round) ) / (10 ** Round) ),
    !.

% atomic_list_to_string(+List, -String)
atomic_list_to_string(List, String) :-
    current_predicate( atomics_to_string/2 ),
    atomics_to_string(List, String),
    !.
atomic_list_to_string(List, String) :-
    atomic_list_concat(List, Atom),
    atom_string(Atom, String),
    !.
% atomic_list_to_string(+List, +Separator, -String)
atomic_list_to_string(List, Separator, String) :-
    current_predicate( atomics_to_string/3 ),
    atomics_to_string(List, Separator, String),
    !.
atomic_list_to_string(List, Separator, String) :-
    atomic_list_concat(List, Separator, Atom),
    atom_string(Atom, String),
    !.

% date_format(+DateIn, -DateOut)
date_format(DateIn, DateOut) :-
    date_format(DateIn, DateOut, ru),
    !.
% date_format(+DateIn, -DateOut, ?Locale)
date_format(DateIn, DateOut, ru) :-
    atom_date(DateIn, _),
    atom_chars(DateIn, [Y1, Y2, Y3, Y4, '-', M1, M2, '-', D1, D2]),
    atom_chars(DateOut, [D1, D2, '.', M1, M2, '.', Y1, Y2, Y3, Y4]).
date_format(date(Y, M, D), DateOut, Locale) :-
    atom_date(DateIn, date(Y, M, D)),
    date_format(DateIn, DateOut, Locale).
date_format(_, '', _).

% month_name(?Month, ?Name)
month_name(Month, Name) :-
    month_name(Month, Name, ru).
%
month_name(1, "январь", ru).
month_name(2, "февраль", ru).
month_name(3, "март", ru).
month_name(4, "апрель", ru).
month_name(5, "май", ru).
month_name(6, "июнь", ru).
month_name(7, "июль", ru).
month_name(8, "август", ru).
month_name(9, "сентябрь", ru).
month_name(10, "октябрь", ru).
month_name(11, "ноябрь", ru).
month_name(12, "декабрь", ru).

% term_to_file(+Term, +FilePath, +Mode, +Options)
term_to_file(Term, FilePath, Mode, Options) :-
    memberchk(Mode, [write, append]),
    open(FilePath, Mode, Stream, Options),
    forall( catch(Term, _, fail),
            ( writeq(Stream, Term), write(Stream,'.'), nl(Stream) )
          ),
    close(Stream, [force(true)]),
    !.
term_to_file(Term, FilePath, Mode) :-
    Options = [create([write]), encoding(utf8)],
    term_to_file(Term, FilePath, Mode, Options),
    !.
term_to_file(Term, FilePath) :-
    Mode = write,
    term_to_file(Term, FilePath, Mode),
    !.

% get_local_stamp(-Stamp)
get_local_stamp(Stamp) :-
    get_local_date_time(DateTime),
    get_time(TimeStamp),
    Fract is round(float_fractional_part(TimeStamp) * 1000) // 1,
    atomic_list_concat([DateTime, '.', Fract], Stamp),
    !.

% день недели
weekday(date(Year, Month, Day), WeekDay) :-
    A is (14 - Month) // 12,
    Y is Year - A,
    M is Month + 12 * A - 2,
    WeekDay0 is (7000 + (Day + Y + Y // 4 - Y // 100 + Y // 400 + (31 * M) // 12)) mod 7,
    WeekDay is WeekDay0 + 1,
    !.
weekday(Date, WeekDay) :-
    atom_date(Date, date(Year, Month, Day)),
    weekday(date(Year, Month, Day), WeekDay),
    !.

% подготовка SQL-строки
prepare_sql(InSQL, [], InSQL) :-
    !.
prepare_sql(InSQL,[Key-Value|Pairs], OutSQL) :-
    replace_all(InSQL, Key, Value, InSQL1),
    !,
    prepare_sql(InSQL1, Pairs, OutSQL).

% exist_in(+Search, +In)
exist_in(Search, In) :-
    text_list([Search, In], [SearchCodes, InCodes]),
    append(_, MiddleCodes, InCodes),
    append(SearchCodes, _, MiddleCodes),
    !.

% replace_all(+In, +Search, +Replace, -Out)
replace_all(In, Search, Replace, Out) :-
    replace(In, Search, Replace, In1),
    \+ In = In1,
    !,
    replace_all(In1, Search, Replace, Out).
replace_all(In, _, _, In).

% replace(+In, +Search, +Replace, -Out)
replace(In, Search, Replace, Out) :-
    text_list([In, Search, Replace], [InCodes, SearchCodes, ReplaceCodes]),
    replace_list(InCodes, SearchCodes, ReplaceCodes, OutCodes),
    text_in_out(In, OutCodes, Out),
    !.
replace(In, _, _, In).

% replace_list(+In, +Search, +Replace, -Out)
replace_list(In, Search, Replace, Out) :-
    append(Part1, Middle, In),
    append(Search, Part2, Middle),
    append([Part1, Replace, Part2], Out),
    !.

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
    !.

%
integer_list([]) :-
    !.
integer_list([Head|Tail]) :-
    integer(Head),
    !,
    integer_list(Tail).

%
member_list([], _) :-
    !.
member_list([Head|Tail], List) :-
    memberchk(Head, List),
    !,
    member_list(Tail, List).

%
