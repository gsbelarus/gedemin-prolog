Option Explicit
'#include pl_GetScriptIDByName
'#include wg_GetConstByIDAndDate

Function wg_AvgSalaryStrGenerate_Sick_pl(ByRef gdcObject, ByRef gdcSalary)
'
  Dim T, T1, T2
  '
  Dim Creator
  '
  Dim PL, Ret, Pred, Tv, Append
  Dim PredFile, Scope
  'avg_wage
  Dim P_main, Tv_main, Q_main
  'avg_wage_sick_in
  Dim P_in, Tv_in, Q_in
  Dim EmplKey, FirstMoveKey, DateCalc, IsAvgWageDoc
  'avg_wage_run, avg_wage_sql
  Dim P_run, Tv_run, Q_run, P_sql, Tv_sql, Q_sql, P_kb
  Dim DateCalcFrom, DateCalcTo
  Dim PredicateName, Arity, SQL
  'avg_wage_out, avg_wage_sick_det
  Dim P_out, Tv_out, Q_out, P_det, Tv_det, Q_det
  Dim AvgWage, AvgWageRule
  Dim Period, PeriodRule, MonthDays, ExclDays, CalcDays, IsFullMonth, Wage
  Dim TabDays, TabHoures, NormDays, NormHoures

  T1 = Timer
  wg_AvgSalaryStrGenerate_Sick_pl = False

  'init
  Set Creator = New TCreator
  Set PL = Creator.GetObject(nil, "TgsPLClient", "")
  Ret = PL.Initialise("")
  If Not Ret Then
    Exit Function
  End If
  'debug
  PL.Debug = True
  'load
  Ret = PL.LoadScript(pl_GetScriptIDByName("twg_avg_wage"))
  If Not Ret Then
    Exit Function
  End If
  Scope = "wg_avg_wage_sick"
  
  'params
  EmplKey = gdcObject.FieldByName("usr$emplkey").AsInteger
  FirstMoveKey = gdcObject.FieldByName("usr$firstmovekey").AsInteger
  DateCalc = gdcObject.FieldByName("usr$from").AsDateTime
  IsAvgWageDoc = gdcObject.FieldByName("USR$REFERENCE").AsInteger

  'clean
  gdcSalary.First
  While Not gdcSalary.EOF
    gdcSalary.Delete
  Wend
  '
  gdcSalary.OwnerForm.Repaint

  'avg_wage_sick_in(EmplKey, FirstMoveKey, DateCalc, IsAvgWageDoc)
  P_in = "avg_wage_sick_in"
  Set Tv_in = Creator.GetObject(4, "TgsPLTermv", "")
  Set Q_in = Creator.GetObject(nil, "TgsPLQuery", "")
  Tv_in.PutInteger 0, EmplKey
  Tv_in.PutInteger 1, FirstMoveKey
  Tv_in.PutDate 2, DateCalc
  Tv_in.PutInteger 3, IsAvgWageDoc
  '
  Q_in.PredicateName = P_in
  Q_in.Termv = Tv_in
  '
  Q_in.OpenQuery
  If Q_in.EOF Then
    Exit Function
  End If
  Q_in.Close

  'avg_wage(Scope) - prepare data
  P_main = "avg_wage"
  Set Tv_main = Creator.GetObject(1, "TgsPLTermv", "")
  Set Q_main = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_main.PredicateName = P_main
  Q_main.Termv = Tv_main
  '
  Tv_main.PutAtom 0, Scope
  '
  Q_main.OpenQuery
  If Q_main.EOF Then
    Exit Function
  End If
  Q_main.Close

  'save param_list
  If PL.Debug Then
    Pred = "param_list"
    PredFile = "param_list"
    Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, PredFile
  End If

  'avg_wage_run(Scope, EmplKey, FirstMoveKey, DateCalcFrom, DateCalcTo)
  P_run = "avg_wage_run"
  Set Tv_run = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_run = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_run.PredicateName = P_run
  Q_run.Termv = Tv_run
  'avg_wage_sql(Scope, EmplKey, FirstMoveKey, PredicateName, Arity, SQL)
  P_sql = "avg_wage_sql"
  P_kb = "avg_wage_kb"
  Set Tv_sql = Creator.GetObject(6, "TgsPLTermv", "")
  Set Q_sql = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_sql.PredicateName = P_sql
  Q_sql.Termv = Tv_sql
  '
  Tv_run.PutAtom 0, Scope
  '
  Q_run.OpenQuery
  If Q_run.EOF Then
    Exit Function
  End If
  '
  Append = False
  '
  Do Until Q_run.EOF
    EmplKey = Tv_run.ReadInteger(1)
    FirstMoveKey = Tv_run.ReadInteger(2)
    DateCalcFrom = Tv_run.ReadDate(3)
    DateCalcTo = Tv_run.ReadDate(4)
    '
    Tv_sql.Reset
    Tv_sql.PutAtom 0, Scope
    Tv_sql.PutInteger 1, EmplKey
    Tv_sql.PutInteger 2, FirstMoveKey
    Q_sql.OpenQuery
    '
    Do Until Q_sql.EOF
      PredicateName = Tv_sql.ReadAtom(3)
      Arity = Tv_sql.ReadInteger(4)
      SQL = Tv_sql.ReadString(5)
      '
      Ret =  PL.MakePredicatesOfSQLSelect _
                (SQL, _
                gdcBaseManager.ReadTransaction, _
                PredicateName, PredicateName, Append)
      If Ret >= 0 Then
         Ret = PL.Call(P_kb, Tv_sql)
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

  'save param_list
  If PL.Debug Then
    Pred = "param_list"
    PredFile = "param_list"
    Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, PredFile
  End If

  'avg_wage(Scope) - calc result
  Q_main.OpenQuery
  If Q_main.EOF Then
    Exit Function
  End If
  Q_main.Close

  'avg_wage_out(Scope, EmplKey, FirstMoveKey, AvgWage, AvgWageVariant)
  P_out = "avg_wage_out"
  Set Tv_out = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_out = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_out.PredicateName = P_out
  Q_out.Termv = Tv_out
  'avg_wage_sick_det(EmplKey, FirstMoveKey,
  '                  Period, Rule,
  '                  MonthDays, ExclDays, CalcDays, IsFullMonth,
  '                  Wage,
  '                  TabDays, NormDays, TabHoures, NormHoures) :-
  P_det = "avg_wage_sick_det"
  Set Tv_det = Creator.GetObject(13, "TgsPLTermv", "")
  Set Q_det = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_det.PredicateName = P_det
  Q_det.Termv = Tv_det
  '
  Tv_out.PutAtom 0, Scope
  '
  Q_out.OpenQuery
  If Q_out.EOF Then
    Exit Function
  End If
  '
  Do Until Q_out.EOF
    EmplKey = Tv_out.ReadInteger(1)
    FirstMoveKey = Tv_out.ReadInteger(2)
    AvgWage = Tv_out.ReadFloat(3)
    AvgWageRule = Tv_out.ReadAtom(4)
    '
    Tv_det.Reset
    Tv_det.PutInteger 0, EmplKey
    Tv_det.PutInteger 1, FirstMoveKey
    Q_det.OpenQuery
    '
    Do Until Q_det.EOF
      Period = Tv_det.ReadDate(2)
      PeriodRule = Tv_det.ReadAtom(3)
      '
      Select Case AvgWageRule
        Case "by_calc_days", "by_calc_days_doc"
          Select Case PeriodRule
            Case "by_cal_flex"
              PeriodRule = "по табелю мастера"
            Case "by_cal"
              PeriodRule = "по табелю"
            Case "by_orders"
              PeriodRule = "по приказам"
            Case Else
              PeriodRule = ""
          End Select
        Case "by_budget"
          PeriodRule = "от Ѕѕћ"
        Case "by_avg_wage"
          PeriodRule = "по среднему заработку"
        Case "by_rate"
          PeriodRule = "от ставки"
        Case "by_not_full"
          PeriodRule = "по не полным мес€цам"
        Case Else
          PeriodRule = ""
      End Select
      '
      MonthDays = Tv_det.ReadInteger(4)
      ExclDays= Tv_det.ReadInteger(5)
      CalcDays = Tv_det.ReadInteger(6)
      IsFullMonth = Tv_det.ReadInteger(7)
      Wage = Tv_det.ReadFloat(8)
      TabDays = Tv_det.ReadFloat(9)
      NormDays = Tv_det.ReadFloat(10)
      TabHoures = Tv_det.ReadFloat(11)
      NormHoures = Tv_det.ReadFloat(12)
      '
      gdcSalary.Append
      gdcSalary.FieldByName("USR$ISFULL").AsVariant = IsFullMonth
      gdcSalary.FieldByName("USR$DATE").AsVariant = Period
      gdcSalary.FieldByName("USR$CALCDAYS").AsVariant = CalcDays
      gdcSalary.FieldByName("USR$SALARY").AsVariant = Wage
      gdcSalary.FieldByName("USR$DOW").AsVariant = TabDays
      gdcSalary.FieldByName("USR$SCHEDULERDOW").AsVariant = NormDays
      gdcSalary.FieldByName("USR$HOW").AsVariant = TabHoures
      gdcSalary.FieldByName("USR$SCHEDULERHOW").AsVariant = NormHoures
      gdcSalary.FieldByName("USR$DESCRIPTION").AsVariant = PeriodRule
      gdcSalary.Post
      '
      Q_det.NextSolution
    Loop
    Q_det.Close
    '
    Q_out.NextSolution
  Loop
  Q_out.Close
  '

  gdcSalary.First

  If AvgWage > 0 then
    gdcObject.FieldByName("USR$AVGSUMMA").AsCurrency = AvgWage
  End If
  '
  Select Case AvgWageRule
    Case "by_budget"
      gdcObject.FieldByName("USR$CALCBYBUDGET").AsInteger = 1
    Case "by_rate"
      gdcObject.FieldByName("USR$THIRDMETHOD").AsInteger = 1
    Case "by_avg_wage"
      gdcObject.FieldByName("USR$AVERAGE").AsInteger = 1
  End select
  '
  gdcObject.Post

  wg_AvgSalaryStrGenerate_Sick_pl = True
  
  T2 = Timer
  T = T2 - T1
'
End function
