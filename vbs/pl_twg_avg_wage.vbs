Option Explicit
'#include pl_GetScriptIDByName
'#include pl_TermvToDict

Function pl_twg_avg_wage()
'
  Dim Creator, PL, Ret
  Dim Pred, Tv, Append
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
  Dim T, T1, T2

  T1 = Timer
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
  Append = False
  '
  Do Until Q_run.EOF
    EmplKey = Tv_run.ReadInteger(0)
    DateCalcFrom = Tv_run.ReadDate(1)
    DateCalcTo = Tv_run.ReadDate(2)
    '
    Tv_sql.Reset
    Tv_sql.PutInteger 0, EmplKey
    Q_sql.OpenQuery
    '
    Do Until Q_sql.EOF
      Connection = Tv_sql.ReadAtom(1)
      PredicateName = Tv_sql.ReadAtom(2)
      Arity = Tv_sql.ReadInteger(3)
      SQL = Tv_sql.ReadAtom(4)
      '
      Ret =  PL.MakePredicatesOfSQLSelect _
                (SQL, _
                gdcBaseManager.ReadTransaction, _
                PredicateName, PredicateName, Append)
      If Ret > 0 Then
         Ret = PL.Call("avg_wage_kb", Tv_sql)
      End If
      '
      Q_sql.NextSolution
    Loop
    Q_sql.Close
    '
    Append = True
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
  'dict
  Dim Dict_det
  Set Dict_det = CreateObject("Scripting.Dictionary")
  '
  Q_out.OpenQuery
  pl_twg_avg_wage = (Q_out.EOF = False)
  '
  Do Until Q_out.EOF
    EmplKey = Tv_out.ReadInteger(0)
    AvgWage = Tv_out.ReadFloat(1)
    AvgWageRule = Tv_out.ReadAtom(2)
    '
    Tv_det.Reset
    Tv_det.PutInteger 0, EmplKey
    Q_det.OpenQuery
    '
    Do Until Q_det.EOF
      'dict
      pl_TermvToDict _
        Tv_det, _
        Array("", "d Period", "PeriodRule", _
              "Wage", "ModernWage", "ModernCoef", _
              "TabDays", "TabHoures", "NormDays", "NormHoures"), _
        Dict_det
      Dim Keys, Elem, N
      Keys = Dict_det.Keys
      For N = 0 To Dict_det.Count - 1
        Elem = Dict_det.Item(Keys(N))
      Next
      '
      Period = Tv_det.ReadDate(1)
      PeriodRule = Tv_det.ReadAtom(2)
      Wage = Tv_det.ReadFloat(3)
      ModernWage = Tv_det.ReadFloat(4)
      ModernCoef = Tv_det.ReadFloat(5)
      TabDays = Tv_det.ReadFloat(6)
      TabHoures = Tv_det.ReadFloat(7)
      NormDays = Tv_det.ReadFloat(8)
      NormHoures = Tv_det.ReadFloat(9)
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
  
  T2 = Timer
  T = T2 - T1
'
End Function

