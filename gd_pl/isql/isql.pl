% isql
%   isql.exe
%   fbclient.dll

:- module( isql, [isql_thread/2] ).

%%
%
:- set_prolog_flag(double_quotes, string).

:- style_check(-atom).

:- dynamic([user:isql_proc/2, user:isql_line/4, user:isql_filter/1]).

isql_exe_args(Exe, Args) :-
    current_prolog_flag(executable, AppPath),
    prolog_to_os_filename(PrologPath, AppPath),
    file_directory_name(PrologPath, Directory),
    atom_concat(Directory, '/isql.exe', Exe),
    Args = [
            '-q', '-s', '3', '-pag', '0', '-e', %'-nod', '-now',
            '-u', 'sysdba', '-p', 'masterkey'
           ],
    !.

isql_thread(DB, QueryList) :-
    thread_self(Id),
    isql_exe_args(Exe, Args),
    Options = [
                stdin(pipe(SIn)), stdout(pipe(SOut)),
                process(PID), window(false)
              ],
    process_create(Exe, Args, Options),
    retractall( isql_proc(thread(Id), process(PID)) ),
    assertz( user:isql_proc(thread(Id), process(PID)) ),
    %
    phrase(isql_connect(DB), ConnectCodes),
    string_codes(Connect, ConnectCodes),
    write(SIn, Connect),
    %
    forall( ( member(DS-SQL, QueryList),
              string_codes(DS, DS_codes),
              atom_codes(DS_atom, DS_codes),
              term_to_atom(DS_term, DS_atom),
              DS_term =.. DS_list,
              append(DS_list, [_], DS_list1),
              DS_term1 =.. DS_list1,
              catch( user:DS_term1, _, fail),
              phrase(isql_query(DS-SQL), QueryCodes)
            ),
            ( string_codes(Query, QueryCodes),
              write(SIn, Query)
            )
    ),
    %
    write(SIn, "exit;"), nl(SIn),
    flush_output(SIn),
    %
    isql_kb(SOut, Id, PID),
    !.

isql_kb(SOut, _, _) :-
    at_end_of_stream(SOut),
    !.
isql_kb(SOut, Id, PID) :-
    isql_get_out(SOut, Out),
    isql_kb_ds(Out, [], SOut, Id, PID),
    !,
    isql_kb(SOut, Id, PID).
isql_kb(SOut, Id, PID) :-
    !,
    isql_kb(SOut, Id, PID).

isql_get_out(SOut, "") :-
    at_end_of_stream(SOut),
    !.
isql_get_out(SOut, Out) :-
    read_line_to_codes(SOut, OutCodes),
    phrase(isql(Out), OutCodes),
    ( isql_filter(Filter) -> memberchk(Out, Filter) ; true ),
    !.
isql_get_out(SOut, Out) :-
    !,
    isql_get_out(SOut, Out).

isql_store_out(Out, SOut, Id, PID) :-
    isql_store_out(Out, SOut, Id, PID, -1),
    !.
isql_store_out(Out, SOut, Id, PID, Offset) :-
    line_count(SOut, Count),
    plus(Count, Offset, Num),
    assertz( user:isql_line(thread(Id), process(PID), id(Num), Out) ),
    !.

isql_kb_ds(_, _, SOut, _, _) :-
    at_end_of_stream(SOut),
    !.
isql_kb_ds(Out, Lines, SOut, Id, PID) :-
    Lines = [],
    Out = ret(gd_pl_ds),
    Out_kb_ds = kb_ds(begin),
    isql_store_out(Out_kb_ds, SOut, Id, PID),
    isql_get_out(SOut, Out1),
    !,
    isql_kb_ds(Out1, [Out_kb_ds|Lines], SOut, Id, PID).
isql_kb_ds(Out, Lines, SOut, Id, PID) :-
    Lines = [kb_ds(begin)|_],
    Out = ret(shape(_)),
    Out_kb_ds = kb_ds(shape),
    isql_store_out(Out_kb_ds, SOut, Id, PID),
    isql_get_out(SOut, Out1),
    !,
    isql_kb_ds(Out1, [Out_kb_ds|Lines], SOut, Id, PID).
isql_kb_ds(Out, Lines, SOut, Id, PID) :-
    Lines = [kb_ds(shape)|_],
    Out = ret(data(DS_str)),
    normalize_space(atom(DS_atom), DS_str),
    term_to_atom(DS_term, DS_atom),
    DS_term =.. DS_list,
    append(DS_list, [_], DS_list1),
    DS_term1 =.. DS_list1,
    catch( user:DS_term1, _, fail),
    Out_kb_ds = kb_ds(term(DS_term1)),
    isql_store_out(Out_kb_ds, SOut, Id, PID),
    isql_get_out(SOut, Out1),
    !,
    isql_kb_ds(Out1, [Out_kb_ds|Lines], SOut, Id, PID).
isql_kb_ds(Out, Lines, SOut, Id, PID) :-
    Lines = [kb_ds(term(_))|_],
    \+ Out = ret(rec(1)),
    isql_store_out(Out, SOut, Id, PID),
    isql_get_out(SOut, Out1),
    !,
    isql_kb_ds(Out1, Lines, SOut, Id, PID).
isql_kb_ds(Out, Lines, SOut, Id, PID) :-
    Lines = [kb_ds(term(_))|_],
    Out = ret(rec(1)),
    Out_kb_ds = kb_ds(query),
    isql_store_out(Out_kb_ds, SOut, Id, PID),
    isql_get_out(SOut, Out1),
    !,
    isql_kb_ds(Out1, [Out_kb_ds|Lines], SOut, Id, PID).
isql_kb_ds(Out, Lines, SOut, Id, PID) :-
    Lines = [kb_ds(query)|_],
    isql_make_predicates(Out, Lines, SOut, Id, PID),
    !.
isql_kb_ds(Out, _, SOut, Id, PID) :-
    isql_store_out(Out, SOut, Id, PID),
    !.

isql_make_predicates(_, _, SOut, _, _) :-
    at_end_of_stream(SOut),
    !.
isql_make_predicates(Out, _, SOut, Id, PID) :-
    Out = ret(rec(Rec)),
    Out_kb_ds = kb_ds(end(rec(Rec))),
    isql_store_out(Out_kb_ds, SOut, Id, PID),
    !.
isql_make_predicates(Out, Lines, SOut, Id, PID) :-
    Lines = [kb_ds(query)|_],
    \+ memberchk(Out, [ret(data(_)), ret(shape(_))]),
    isql_store_out(Out, SOut, Id, PID),
    isql_get_out(SOut, Out1),
    !,
    isql_make_predicates(Out1, Lines, SOut, Id, PID).
isql_make_predicates(Out, Lines, SOut, Id, PID) :-
    Lines = [kb_ds(query)|_],
    Out = ret(data(Data)),
    Out_kb_ds = kb_ds(header(Data)),
    isql_get_out(SOut, Out1),
    !,
    isql_make_predicates(Out1, [Out_kb_ds|Lines], SOut, Id, PID).
isql_make_predicates(Out, Lines, SOut, Id, PID) :-
    Lines = [kb_ds(header(Data))|Tail],
    Out = ret(shape(Shape)),
    Out_kb_ds1 = kb_ds(shape(Shape)),
    string_codes(Data, DataCodes),
    memberchk(kb_ds(term(DS_term)), Lines),
    DS_term = gd_pl_ds(_, _, _, _, Pairs),
    isql_get_fields(Shape, Pairs, DataCodes, Fields),
    Out_kb_ds2 = kb_ds(fields(Fields)),
    isql_store_out(Out_kb_ds2, SOut, Id, PID, -2),
    isql_store_out(Out_kb_ds1, SOut, Id, PID),
    isql_get_out(SOut, Out1),
    !,
    isql_make_predicates(Out1, [Out_kb_ds1, Out_kb_ds2|Tail], SOut, Id, PID).
isql_make_predicates(Out, Lines, SOut, Id, PID) :-
    Lines = [kb_ds(shape(Shape))|_],
    Out = ret(data(Data)),
    string_codes(Data, DataCodes),
    memberchk(kb_ds(term(DS_term)), Lines),
    DS_term = gd_pl_ds(_, _, PredName, _, Pairs),
    isql_form_args(Shape, Pairs, DataCodes, Args),
    Pred =.. [PredName|Args],
    assertz(user:Pred),
    isql_get_out(SOut, Out1),
    !,
    isql_make_predicates(Out1, Lines, SOut, Id, PID).
isql_make_predicates(Out, Lines, SOut, Id, PID) :-
    isql_store_out(Out, SOut, Id, PID),
    isql_get_out(SOut, Out1),
    !,
    isql_make_predicates(Out1, Lines, SOut, Id, PID).

isql_get_fields([], [], _, []).
isql_get_fields([Head|Teil], [_-DataSpec|Pairs], DataCodes, [Field|Fields]) :-
    ( DataSpec = _/Len
    ; string_codes(Head, Codes),
      length(Codes, Len)
    ),
    length(FieldCodes, Len),
    append(FieldCodes, DataCodes1, DataCodes),
    string_codes(Field0, FieldCodes),
    normalize_space(string(Field), Field0),
    !,
    isql_get_fields(Teil, Pairs, DataCodes1, Fields).

isql_form_args([], [], [], []).
isql_form_args([Head|Teil], [_-DataSpec|Pairs], DataCodes, [Arg|Args]) :-
    ( DataSpec = DataType/Len
    ; DataSpec = DataType,
      string_codes(Head, Codes),
      length(Codes, Len)
    ),
    length(FieldCodes, Len),
    append(FieldCodes, DataCodes1, DataCodes),
    string_codes(Field0, FieldCodes),
    normalize_space(codes(ArgCodes), Field0),
    isql_get_arg(DataType, ArgCodes, Arg),
    !,
    isql_form_args(Teil, Pairs, DataCodes1, Args).

isql_get_arg(DataType, ArgCodes, Arg) :-
    memberchk(DataType-NullValue, [integer-0, float-0.0]),
    atom_codes(Arg01, ArgCodes),
    ( atom_number(Arg01, Arg02),
      Arg is Arg02 + NullValue
    ; memberchk(Arg01, ['<null>', '']),
      Arg = NullValue
    ),
    !.
isql_get_arg(DataType, ArgCodes, Arg) :-
    DataType = boolean, NullValue = 0,
    atom_codes(Arg01, ArgCodes),
    ( atom_number(Arg01, Arg02),
      memberchk(Arg02, [0, 1]),
      Arg is Arg02 + NullValue
    ; memberchk(Arg01, ['<null>', '']),
      Arg = NullValue
    ),
    !.
isql_get_arg(DataType, ArgCodes, Arg) :-
    DataType = string,
    string_codes(Arg0, ArgCodes),
    ( Arg0 = "<null>", Arg = "" ; Arg = Arg0 ),
    !.
isql_get_arg(_, ArgCodes, Arg) :-
    atom_codes(Arg0, ArgCodes),
    ( Arg0 = '<null>', Arg = '' ; Arg = Arg0 ),
    !.

%
:- set_prolog_flag(double_quotes, codes).

%
cr -->
    [13].

lf -->
    [10].

crlf -->
    cr, lf.

%
isql_connect(DB) -->
    "set heading on;", crlf,
    "set count on;", crlf,
    "set stats on;", crlf,
    "connect '",
    { string_codes(DB, DBCodes) }, DBCodes,
    "';", crlf.

isql_query(DS-SQL) -->
    "SET TERM ^;", crlf,
    "EXECUTE BLOCK",
    " RETURNS (gd_pl_ds VARCHAR(100))",
    " AS BEGIN gd_pl_ds = ",
    "'", { string_codes(DS, DSCodes) }, DSCodes, "';",
    " SUSPEND; END ^", crlf,
    "SET TERM ;^", crlf,
    { string_codes(SQL, SQLCodes) }, SQLCodes, ";", crlf.

%
isql(Out) -->
    isql_node(Out),
    !.

isql_node(sql(blank)) -->
    "SQL>", sp, at_end.
isql_node(sql(Parse)) -->
    "SQL>", sp,
    isql_parse(Parse), ";".
isql_node(sql(set(term, State))) -->
    "SQL>", sp,
    "SET TERM", sp,
    ( "^;", {State = on}
    ; ";^", {State = off}
    ).
isql_node(con(Parse)) -->
    "CON>", sp,
    isql_parse(Parse), ";".
isql_node(sql(Parse)) -->
    "SQL>",
    anything(ParseCodes), at_end,
    { string_codes(Parse, ParseCodes) }.
isql_node(con(Parse)) -->
    "CON>",
    anything(ParseCodes), at_end,
    { string_codes(Parse, ParseCodes) }.
isql_node(ret(Parse)) -->
    isql_parse(Parse).

isql_parse(exit) -->
    "exit".
isql_parse(set(Name, State)) -->
    "set", sp,
    isql_set_name(Name), sp,
    isql_set_state(State).
isql_parse(connect(ConnectString)) -->
    "connect", sp,
    anything(ConnectCodes),
    { string_codes(ConnectString, ConnectCodes) }.
isql_parse(db(DB, UserName)) -->
    "Database", ":", sp,
    anything(DBCodes),
    ",", sp,
    "User", ":", sp,
    anything(UserNameCodes), at_end,
    {
    string_codes(DB, DBCodes),
    string_codes(UserName, UserNameCodes)
    }.
isql_parse(rec(Records)) -->
    "Records affected", ":", sp,
    anything(RecordsCodes), at_end,
    { number_codes(Records, RecordsCodes) }.
isql_parse(stat(Name, Value)) -->
    ( "Current memory", {Name = 'Current memory'}
    ; "Delta memory", {Name = 'Delta memory'}
    ; "Max memory", {Name = 'Max memory'}
    ; "Elapsed time", {Name = 'Elapsed time'}
    ; "Buffers", {Name = 'Buffers'}
    ; "Reads", {Name = 'Reads'}
    ; "Writes", {Name = 'Writes'}
    ; "Fetches", {Name = 'Fetches'}
    ),
    sp, ("=" ; ""), sp,
    anything(ValueCodes), (sp, "sec"; at_end),
    { number_codes(Value, ValueCodes) }.
isql_parse(blank) -->
    sp, at_end.
isql_parse(shape(Shape)) -->
    isql_shape(Shape).
isql_parse(gd_pl_ds) -->
    "GD_PL_DS",
    sp, at_end.
isql_parse(data(Data)) -->
    anything(DataCodes), at_end,
    { string_codes(Data, DataCodes) }.

isql_shape([]) -->
    at_end.
isql_shape([Form|Teil]) -->
    isql_col(FormCodes),
    { string_codes(Form, FormCodes) },
    isql_shape(Teil).

isql_col([H|T]) -->
    "=",
    { [H] = "=" },
    !,
    isql_col(T).
isql_col([H]) -->
    " ",
    { [H] = " " }.

isql_set_name(heading) -->
    "heading".
isql_set_name(count) -->
    "count".
isql_set_name(stats) -->
    "stats".

isql_set_state(on) -->
    "on".
isql_set_state(off) -->
    "off".

%
anything([]) -->
    [].
anything([H|T]) -->
    [H],
    anything(T).

sp -->
    " ", !, sp.
sp -->
    [].

at_end -->
    \+ [_].

:- set_prolog_flag(double_quotes, string).
 %
%%
