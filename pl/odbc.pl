%
:- ensure_loaded(lib).
/* replace_all */

open_connection(Connection) :-
    catch(
        odbc_connect(
            Connection, _,
            [user('SYSDBA'),
              password(masterkey),
              alias(Connection)
            ]),
        _,
        fail).

open_connection(Connection, DriverString) :-
    catch(
        odbc_driver_connect(
            Connection, _,
            [ driver_string(DriverString),
              alias(Connection)
            ]),
        _,
        fail).

close_connection(Connection) :-
    catch( odbc_current_connection(Connection, _), _, fail ),
    odbc_disconnect(Connection).

close_connection(_).

close_all_connections :-
    close_connection(_),
    fail.

close_all_connections.

set_connection(Connection) :-
    close_connection(Connection),
    open_connection(Connection),
    !.

set_connection(Connection, DriverString) :-
    close_connection(Connection),
    open_connection(Connection, DriverString),
    !.

get_record(Connection, Query, Rec) :-
    get_sql(Connection, Query, SQL),
    odbc_query(Connection, SQL, Rec).

get_record(Connection, Query, Rec, []) :-
    get_record(Connection, Query, Rec).

get_record(Connection, Query, Rec, [Key-Value|Pairs]) :-
    get_sql(Connection, Query, SQL, [Key-Value|Pairs]),
    prepare_sql(SQL, [Key-Value|Pairs], PrepSQL),
    odbc_query(Connection, PrepSQL, Rec).

get_record(_, _, _, [_-_|_]) :-
    !,
    fail.

get_record(Connection, Query, Rec, ParameterValues) :-
    get_sql(Connection, Query, SQL, Parameters),
    odbc_prepare(Connection, SQL, Parameters, Statement),
    odbc_execute(Statement, ParameterValues, Rec).

prepare_sql(InSQL, [], InSQL).

prepare_sql(InSQL,[Key-Value|Pairs], OutSQL) :-
    replace_all(InSQL, Key, Value, InSQL1),
    prepare_sql(InSQL1, Pairs, OutSQL).

assert_record([Query/_|Attrs], Rec) :-
    Rec =.. [row|Recs],
    append([Query|Attrs], Recs, [Functor|Args]),
    Term =.. [Functor|Args],
    assertz(Term),
    !.
    
assert_record([Query|Attrs], Rec) :-
    Rec =.. [row|Recs],
    append([Query|Attrs], Recs, [Functor|Args]),
    Term =.. [Functor|Args],
    assertz(Term).
    
%