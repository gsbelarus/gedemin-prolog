Option Explicit
'#include pl_GetScriptIDByName
'#include pl_TermvToDict
'#include pl_DictToTermv

Function pl_twg_avg_wage()
'
  Dim Creator, PL, Ret
  Dim Pred, Tv, Append
  'avg_wage_in
  Dim P_in, Tv_in
  Dim EmplKey, FirstMoveKey, DateCalc
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

  'avg_wage_in(EmplKey, FirstMoveKey, DateCalc)
  P_in = "avg_wage_in"
  Set Tv_in = Creator.GetObject(3, "TgsPLTermv", "")
  '
  'dict in
  Dim Dict_in
  Set Dict_in = CreateObject("Scripting.Dictionary")
  '
  Dict_in.Add "EmplKey", 150921260
  Dict_in.Add "FirstMoveKey", 150977072
  Dict_in.Add "DateCalc", "2013-06-01"
  pl_DictToTermv _
    Dict_in, Array("i:EmplKey", "i:FirstMoveKey", "d:DateCalc"), Tv_in
  'Tv_in.PutInteger 0, 150921260
  'Tv_in.PutInteger 1, 150977072
  'Tv_in.PutAtom 2, "2013-06-01"
  Ret = PL.Call(P_in, Tv_in)
  '
  Dict_in("EmplKey") = 148441437
  Dict_in("FirstMoveKey") = 148454058
  Dict_in("DateCalc") = "2013-07-15"
  pl_DictToTermv _
    Dict_in, Array("i:EmplKey", "i:FirstMoveKey", "d:DateCalc"), Tv_in
  'Tv_in.PutInteger 0, 148441437
  'Tv_in.PutInteger 1, 148454058
  'Tv_in.PutAtom 2, "2013-07-15"
  Ret = PL.Call(P_in, Tv_in)

  'avg_wage (prepare data)
  Ret = PL.Call2("avg_wage")

  'avg_wage_run(EmplKey, FirstMoveKey, DateCalcFrom, DateCalcTo)
  Set Tv_run = Creator.GetObject(4, "TgsPLTermv", "")
  Set Q_run = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_run.PredicateName = "avg_wage_run"
  Q_run.Termv = Tv_run
  'avg_wage_sql(EmplKey, FirstMoveKey, Connection, PredicateName, Arity, SQL)
  Set Tv_sql = Creator.GetObject(6, "TgsPLTermv", "")
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
    FirstMoveKey = Tv_run.ReadDate(1)
    DateCalcFrom = Tv_run.ReadDate(2)
    DateCalcTo = Tv_run.ReadDate(3)
    '
    Tv_sql.Reset
    Tv_sql.PutInteger 0, EmplKey
    Tv_sql.PutInteger 1, FirstMoveKey
    Q_sql.OpenQuery
    '
    Do Until Q_sql.EOF
      Connection = Tv_sql.ReadAtom(2)
      PredicateName = Tv_sql.ReadAtom(3)
      Arity = Tv_sql.ReadInteger(4)
      SQL = Tv_sql.ReadAtom(5)
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

  'avg_wage_out(EmplKey, FirstMoveKey, AvgWage, AvgWageVariant)
  Set Tv_out = Creator.GetObject(4, "TgsPLTermv", "")
  Set Q_out = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_out.PredicateName = "avg_wage_out"
  Q_out.Termv = Tv_out
  'avg_wage_det(EmplKey, FirstMoveKey,
  '   Period, PeriodRule, Wage, ModernWage, ModernCoef,
  '   TabDays, TabHoures, NormDays, NormHoures)
  Set Tv_det = Creator.GetObject(11, "TgsPLTermv", "")
  Set Q_det = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_det.PredicateName = "avg_wage_det"
  Q_det.Termv = Tv_det
  'dict det
  Dim Dict_det
  Set Dict_det = CreateObject("Scripting.Dictionary")
  '
  Q_out.OpenQuery
  pl_twg_avg_wage = (Q_out.EOF = False)
  '
  Do Until Q_out.EOF
    EmplKey = Tv_out.ReadInteger(0)
    FirstMoveKey = Tv_out.ReadInteger(1)
    AvgWage = Tv_out.ReadFloat(2)
    AvgWageRule = Tv_out.ReadAtom(3)
    '
    Tv_det.Reset
    Tv_det.PutInteger 0, EmplKey
    Tv_det.PutInteger 1, FirstMoveKey
    Q_det.OpenQuery
    '
    Do Until Q_det.EOF
      'dict det
      pl_TermvToDict _
        Tv_det, _
        Array("EmplKey", "FirstMoveKey", _
              "d:Period", "PeriodRule", "Wage", "ModernWage", "ModernCoef", _
              "TabDays", "TabHoures", "NormDays", "NormHoures"), _
        Dict_det
      Dim Keys, Elem, N
      Keys = Dict_det.Keys
      For N = 0 To Dict_det.Count - 1
        Elem = Dict_det.Item(Keys(N))
      Next
      '
      Period = Tv_det.ReadDate(2)
      PeriodRule = Tv_det.ReadAtom(3)
      Wage = Tv_det.ReadFloat(4)
      ModernWage = Tv_det.ReadFloat(5)
      ModernCoef = Tv_det.ReadFloat(6)
      TabDays = Tv_det.ReadFloat(7)
      TabHoures = Tv_det.ReadFloat(8)
      NormDays = Tv_det.ReadFloat(9)
      NormHoures = Tv_det.ReadFloat(10)
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

