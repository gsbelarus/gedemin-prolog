Option Explicit
'#include pl_GetScriptIDByName

Function pl_twg_avg_wage()
'
  Dim Creator, PL, Ret
  Dim Pred, Tv
  'avg_wage_in
  Dim P_in, Tv_in
  Dim EmplKey, DateCalc
  'avg_wage_run, avg_wage_sql
  Dim Tv_run, Q_run, Tv_sql, Q_sql
  Dim DateCalcFrom, DateCalcTo
  Dim Connection, PredicateName, Arity, SQL
  'avg_wage_out, avg_wage_det
  Dim Tv_out, Q_out, Tv_det, Q_det
  Dim AvgWage, AvgWageRule
  Dim Period, PeriodRule, Wage, ModernWage, ModernCoef
  Dim TabDays, TabHoures, NormDays, NormHoures

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

  'avg_wage_in(EmplKey, DateCalc)
  P_in = "avg_wage_in"
  Set Tv_in = Creator.GetObject(2, "TgsPLTermv", "")
  '
  Tv_in.PutInteger 0, 150921260
  Tv_in.PutAtom 1, "2013-06-01"
  Ret = PL.Call(P_in, Tv_in)
  '
  Tv_in.PutInteger 0, 148441437
  Tv_in.PutAtom 1, "2013-07-15"
  Ret = PL.Call(P_in, Tv_in)

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
      If Ret > 0 Then
         Ret = PL.Call("avg_wage_kb", Tv_sql)
      End If
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

  'avg_wage_out(EmplKey, AvgWage, AvgWageVariant)
  Set Tv_out = Creator.GetObject(3, "TgsPLTermv", "")
  Set Q_out = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_out.PredicateName = "avg_wage_out"
  Q_out.Termv = Tv_out
  'avg_wage_det(EmplKey, Period, PeriodRule, Wage, ModernWage, ModernCoef, TabDays, TabHoures, NormDays, NormHoures)
  Set Tv_det = Creator.GetObject(10, "TgsPLTermv", "")
  Set Q_det = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_det.PredicateName = "avg_wage_det"
  Q_det.Termv = Tv_det
  '
  Q_out.OpenQuery
  pl_twg_avg_wage = (Q_out.EOF = False)
  '
  Do Until Q_out.EOF
    EmplKey = Q_out.Termv.ReadInteger(0)
    AvgWage = Q_out.Termv.ReadFloat(1)
    AvgWageRule = Q_out.Termv.ReadAtom(2)
    '
    Tv_det.Reset
    Tv_det.PutInteger 0, EmplKey
    Q_det.OpenQuery
    '
    Do Until Q_det.EOF
      Period = Q_det.Termv.ReadDate(1)
      PeriodRule = Q_det.Termv.ReadAtom(2)
      Wage = Q_det.Termv.ReadFloat(3)
      ModernWage = Q_det.Termv.ReadFloat(4)
      ModernCoef = Q_det.Termv.ReadFloat(5)
      TabDays = Q_det.Termv.ReadFloat(6)
      TabHoures = Q_det.Termv.ReadFloat(7)
      NormDays = Q_det.Termv.ReadFloat(8)
      NormHoures = Q_det.Termv.ReadFloat(9)
      '
      Q_det.NextSolution
    Loop
    Q_det.Close
    '
    Q_out.NextSolution
  Loop
  Q_out.Close
  '
  If PL.Debug Then
    Pred = "param_list"
    Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, Pred
  End If
'
End Function

