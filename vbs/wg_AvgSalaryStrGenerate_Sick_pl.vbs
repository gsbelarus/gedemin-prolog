Option Explicit
'#include pl_GetScriptIDByName
'#include wg_GetConstByIDAndDate
'#include wg_Const
'#include wg_Prolog

Function wg_AvgSalaryStrGenerate_Sick_pl(ByRef Sender)
'
  Dim T, T1, T2
  
  Dim Creator, gdcObject, gdcSalary
  '
  Dim PL, Ret, Pred, Tv, Append
  Dim PredFile
  'avg_wage_sick
  Dim P_main, Tv_main, Q_main
  'avg_wage_sick_in
  Dim P_in, Tv_in, Q_in
  Dim EmplKey, FirstMoveKey, DateCalc, IsAvgWageDoc, IsPregnancy
  'avg_wage_run, avg_wage_sql
  Dim P_run, Tv_run, Q_run, P_sql, Tv_sql, Q_sql, P_kb
  Dim DateCalcFrom, DateCalcTo
  Dim PredicateName, Arity, SQL
  '
  'avg_wage_out, avg_wage_det
  Dim P_out, Tv_out, Q_out, P_det, Tv_det, Q_det
  Dim AvgWage, AvgWageRule
  Dim Period, PeriodRule, MonthDays, ExclDays, CalcDays, IsFullMonth, Wage
  Dim TabDays, TabHoures, NormDays, NormHoures

  T1 = Timer
  wg_AvgSalaryStrGenerate_Sick_pl = False
  Set Creator = New TCreator

  Sender.GetComponent("actApply").Execute

  Set gdcObject = Sender.gdcObject
  Call wg_Prolog.SyncField(gdcObject, True)
  '
  EmplKey = gdcObject.FieldByName("usr$emplkey").AsInteger
  FirstMoveKey = gdcObject.FieldByName("usr$firstmovekey").AsInteger
  DateCalc = gdcObject.FieldByName("usr$from").AsDateTime
  IsAvgWageDoc = gdcObject.FieldByName("USR$REFERENCE").AsInteger
  IsPregnancy = abs(gdcObject.FieldByName("USR$ILLTYPEKEY").AsInteger = _
         gdcBaseManager.GetIDByRUIDString(wg_SickType_Pregnancy_RUID))

  'init
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

  Set gdcSalary = Sender.GetComponent("usrg_gdcAvgSalaryStr")
  '
  gdcSalary.First
  While Not gdcSalary.EOF
    gdcSalary.Delete
  Wend
  '
  gdcObject.FieldByName("USR$AVGSUMMA").Clear
  gdcObject.FieldByName("USR$THIRDMETHOD").AsInteger = 0
  gdcObject.FieldByName("USR$CALCBYBUDGET").AsInteger = 0
  '
  Sender.Repaint

  'avg_wage_sick_in(EmplKey, FirstMoveKey, DateCalc, IsAvgWageDoc, IsPregnancy)
  P_in = "avg_wage_sick_in"
  Set Tv_in = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_in = Creator.GetObject(nil, "TgsPLQuery", "")
  Tv_in.PutInteger 0, EmplKey
  Tv_in.PutInteger 1, FirstMoveKey
  Tv_in.PutDate 2, DateCalc
  Tv_in.PutInteger 3, IsAvgWageDoc
  Tv_in.PutInteger 4, IsPregnancy
  '
  Q_in.PredicateName = P_in
  Q_in.Termv = Tv_in
  '
  Q_in.OpenQuery
  If Q_in.EOF Then
    Exit Function
  End If
  Q_in.Close

  'avg_wage_sick(_) - prepare data
  P_main = "avg_wage_sick"
  Set Tv_main = Creator.GetObject(1, "TgsPLTermv", "")
  Set Q_main = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_main.PredicateName = P_main
  Q_main.Termv = Tv_main
  '
  Q_main.OpenQuery
  If Q_main.EOF Then
    Exit Function
  End If
  Q_main.Close
  
  'avg_wage_sick_run(EmplKey, FirstMoveKey, DateCalcFrom, DateCalcTo)
  P_run = "avg_wage_sick_run"
  Set Tv_run = Creator.GetObject(4, "TgsPLTermv", "")
  Set Q_run = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_run.PredicateName = P_run
  Q_run.Termv = Tv_run
  'avg_wage_sick_sql(EmplKey, FirstMoveKey, PredicateName, Arity, SQL)
  P_sql = "avg_wage_sick_sql"
  P_kb = "avg_wage_sick_kb"
  Set Tv_sql = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_sql = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_sql.PredicateName = P_sql
  Q_sql.Termv = Tv_sql
  '
  Q_run.OpenQuery
  If Q_run.EOF Then
    Exit Function
  End If
  '
  Append = False
  '
  Do Until Q_run.EOF
    EmplKey = Tv_run.ReadInteger(0)
    FirstMoveKey = Tv_run.ReadInteger(1)
    DateCalcFrom = Tv_run.ReadDate(2)
    DateCalcTo = Tv_run.ReadDate(3)
    '
    Tv_sql.Reset
    Tv_sql.PutInteger 0, EmplKey
    Tv_sql.PutInteger 1, FirstMoveKey
    Q_sql.OpenQuery
    '
    Do Until Q_sql.EOF
      PredicateName = Tv_sql.ReadAtom(2)
      Arity = Tv_sql.ReadInteger(3)
      SQL = Tv_sql.ReadString(4)
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

  'avg_wage_sick(Variant) - calc result
  Q_main.OpenQuery
  If Q_main.EOF Then
    Exit Function
  End If
  Q_main.Close

  'avg_wage_sick_out(EmplKey, FirstMoveKey, AvgWage, AvgWageVariant)
  P_out = "avg_wage_sick_out"
  Set Tv_out = Creator.GetObject(4, "TgsPLTermv", "")
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
  Q_out.OpenQuery
  If Q_out.EOF Then
    Exit Function
  End If
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
      Period = Tv_det.ReadDate(2)
      PeriodRule = Tv_det.ReadAtom(3)
      '
      Select Case AvgWageRule
        Case "by_calc_days", "by_calc_days_doc"
          Select Case PeriodRule
            Case "by_cal_flex"
              PeriodRule = "�� ������ �������"
            Case "by_cal"
              PeriodRule = "�� ������"
            Case "by_orders"
              PeriodRule = "�� ��������"
            Case Else
              PeriodRule = ""
          End Select
        Case "by_budget"
          PeriodRule = "�� ���"
        Case "by_rate"
          PeriodRule = "�� ������"
        Case "by_not_full"
          PeriodRule = "�� �� ������ �������"
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
  '
  If AvgWage > 0 then
    gdcObject.FieldByName("USR$AVGSUMMA").AsCurrency = AvgWage
  End If
  '
  Select Case AvgWageRule
    Case "by_budget"
      gdcObject.FieldByName("USR$CALCBYBUDGET").AsInteger = 1
    Case "by_rate"
      gdcObject.FieldByName("USR$THIRDMETHOD").AsInteger = 1
  End select
  '
  gdcObject.Post
  '
  Call wg_Prolog.SyncField(gdcObject, False)
  
  wg_AvgSalaryStrGenerate_Sick_pl = True
  
  T2 = Timer
  T = T2 - T1
'
End function
