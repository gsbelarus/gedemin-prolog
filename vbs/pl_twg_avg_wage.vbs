Option Explicit
'#include pl_GetScriptIDByName

Function pl_twg_avg_wage()
'
  Dim Creator, PL, Ret
  'avg_wage_run, avg_wage_sql, avg_wage_out
  Dim Tv_run, Tv_sql, Tv_out
  Dim Q_run, Q_sql, Q_out
  Dim EmplKey, DateCalcFrom, DateCalcTo
  Dim Connection, PredicateName, Arity, SQL
  Dim AvgWage

  pl_twg_avg_wage = False
  Set Creator = New TCreator
  
  'init
  Set PL = Creator.GetObject(nil, "TgsPLClient", "")
  Ret = PL.Initialise("")
  If Not Ret Then
    Exit Function
  End If
  'debug
  PL.Debug = False
  'load
  Ret = PL.LoadScript(pl_GetScriptIDByName("twg_avg_wage"))
  If Not Ret Then
    Exit Function
  End If

  'avg_wage (prepare data)
  Ret = PL.Call2("avg_wage")

  'avg_wage_run(EmplKey, DateCalcFrom, DateCalcTo)
  Set Tv_run = Creator.GetObject(3, "TgsPLTermv", "")
  Set Q_run = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_run.PredicateName = "avg_wage_run"
  Q_run.Termv = Tv_run
  'avg_wage_sql(EmplKey, Connection, PredicateName, Arity, SQL)
  Set Tv_sql = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_sql = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_sql.PredicateName = "avg_wage_sql"
  Q_sql.Termv = Tv_sql
  '
  Q_run.OpenQuery
  '
  Do Until Q_run.EOF
    EmplKey = Q_run.Termv.ReadInteger(0)
    DateCalcFrom = Q_run.Termv.ReadDate(1)
    DateCalcTo = Q_run.Termv.ReadDate(2)
    '
    Tv_sql.Reset
    Tv_sql.PutInteger 0, EmplKey
    Q_sql.OpenQuery
    '
    Do Until Q_sql.EOF
      Connection = Q_sql.Termv.ReadAtom(1)
      PredicateName = Q_sql.Termv.ReadAtom(2)
      Arity = Q_sql.Termv.ReadInteger(3)
      SQL = Q_sql.Termv.ReadAtom(4)
      '
      Ret =  PL.MakePredicatesOfSQLSelect _
                (SQL, _
                gdcBaseManager.ReadTransaction, _
                PredicateName, PredicateName)
      Ret = PL.Call("avg_wage_kb", Tv_sql)
      '
      Q_sql.NextSolution
    Loop
    Q_sql.Close
    '
    Q_run.NextSolution
  Loop
  Q_run.Close

  'avg_wage (calc result)
  Ret = PL.Call2("avg_wage")

  'avg_wage_out(EmplKey, AvgWage)
  Set Tv_out = Creator.GetObject(2, "TgsPLTermv", "")
  Set Q_out = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_out.PredicateName = "avg_wage_out"
  Q_out.Termv = Tv_out
  '
  Q_out.OpenQuery
  '
  Do Until Q_out.EOF
    EmplKey = Q_out.Termv.ReadInteger(0)
    AvgWage = Q_out.Termv.ReadFloat(1)
    '
    Q_out.NextSolution
  Loop
  Q_out.Close
  
  pl_twg_avg_wage = True
'
  Exit Function
  
  '''
  
  'Ret = PL.Call2("avg_wage_out")

  'Ret = PL.Call2("assert(usr_wg_FeeType(148586355,147060452,147060446))")
  'Dim Tv_a, Tv_c
  'Set Tv_a = Creator.GetObject(1, "TgsPLTermv", "")
  'Set Tv_c = Creator.GetObject(3, "TgsPLTermv", "")
  'Tv_c.PutInteger 0, 148586355
  'Tv_c.PutInteger 1, 147060452
  'Tv_c.PutInteger 2, 147060446
  'Call PL.Compound(Tv_a.Term(0), "usr_wg_FeeType", Tv_c)
  'Ret = PL.Call("assert", Tv_a)

  'param_list
  Dim Tv_p, Q_p, Scope, PType, Pairs
 'param_list(Scope, PType, Pairs)
  Set Tv_p = Creator.GetObject(3, "TgsPLTermv", "")
  Set Q_p = Creator.GetObject(nil, "TgsPLQuery", "")
  'Q_p.PredicateName = "param_list"
  Q_p.PredicateName = "usr_wg_FeeType"
  Q_p.Termv = Tv_p
  '
  Tv_p.Reset
  'Tv_p.PutAtom 1, "debug"
  Q_p.OpenQuery
  '
  Do Until Q_p.EOF
    Scope = Q_p.Termv.ToString(0)
    PType = Q_p.Termv.ToString(1)
    Pairs = Q_p.Termv.ToString(2)
    '
    Q_p.NextSolution
  Loop
  Q_p.Close

  pl_twg_avg_wage = True
'
End Function
