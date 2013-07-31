%

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
    odbc_query(Connection,
           SQL,
           Rec
          ).

get_record(Connection, Query, Rec, ParameterValues) :-
    get_sql(Connection, Query, SQL, Parameters),
    odbc_prepare(Connection, SQL, Parameters, Statement),
    odbc_execute(Statement, ParameterValues, Rec).

assert_record(Connection, Query, Rec) :-
    Rec =.. [row|Recs],
    Term =.. [Query, Connection | Recs],
    assertz(Term).

:- multifile
    get_sql/3,
    get_sql/4.

get_sql(-, -,'').

get_sql(-, -,'',[]).

%