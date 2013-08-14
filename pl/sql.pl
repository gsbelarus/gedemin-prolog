:- ensure_loaded(odbc).

:- multifile
    get_odbc_driver_string/2,
    get_sql/3,
    get_sql/4.

get_odbc_driver_string(bogem,
'\c
Driver=Firebird/InterBase(r) driver; \c
DBNAME=D:\\latunov\\devel_portable\\Gedemin\\Database\\BOGEM_2013_07_15.FDB; \c
UID=SYSDBA; \c
PWD=masterkey; \c
client=D:\\latunov\\devel_portable\\Gedemin\\fbembed.dll \c
'
    ).

get_sql(bogem, twg_AvgWage,
        'SELECT Atom FROM Facts WHERE Name = \'twg_AvgWage\'',
        [default]
    ).

get_sql(bogem, usr_wg_MovementLine0,
        'SELECT * FROM USR$WG_MOVEMENTLINE_P (?)',
        [default]
    ).

get_sql(bogem, usr_wg_MovementLine1,
        'SELECT * FROM USR$WG_MOVEMENTLINE WHERE USR$EMPLKEY = ?',
        [default]
    ).
    
get_sql(bogem, usr_wg_TblCalDay,
        'SELECT * FROM USR$WG_TBLCALDAY_P (?, ?, ?)',
        [default, atom > date, atom > date]
    ).

get_sql(bogem, usr_wg_TblCalLine,
        'SELECT * FROM USR$WG_TBLCALLINE_P (?, ?, ?)',
        [default, atom > date, atom > date]
    ).
    
