Option Explicit
'#include wg_WageSettings
'#include wg_EnableFieldChange
'#include pl_GetScriptIDByName

Function wg_AvgSalaryStrGenerate_pl(ByRef Sender, ByVal CalcType)
'
  Dim T, T1, T2
  
  Dim Creator, gdcObject, gdcSalary
  '
  Dim PL, Ret, Pred, Tv, Append
  'avg_wage
  Dim P_main, Tv_main, Q_main
  'avg_wage_in
  Dim P_in, Tv_in, Q_in
  Dim EmplKey, FirstMoveKey, DateCalc
  Dim InflType, InflFCType
  Dim MonthOffset, CoefOption
  'avg_wage_run, avg_wage_sql
  Dim P_run, Tv_run, Q_run, P_sql, Tv_sql, Q_sql, P_kb
  Dim DateCalcFrom, DateCalcTo
  Dim Connection, PredicateName, Arity, SQL
  'avg_wage_out, avg_wage_det
  Dim P_out, Tv_out, Q_out, P_det, Tv_det, Q_det
  Dim AvgWage, AvgWageRule
  Dim Period, PeriodRule, Wage, ModernWage, ModernCoef
  Dim TabDays, TabHoures, NormDays, NormHoures
  Dim IsFull, IsCheck

  T1 = Timer
  wg_AvgSalaryStrGenerate_pl = False
  Set Creator = New TCreator
  
  Sender.GetComponent("actApply").Execute

  Set gdcObject = Sender.gdcObject
  '
  EmplKey = gdcObject.FieldByName("usr$emplkey").AsInteger
  FirstMoveKey = gdcObject.FieldByName("usr$firstmovekey").AsInteger
  '
  if CalcType = 0 then
    dim IBSQL
    set IBSQL = Creator.GetObject(nil, "TIBSQL", "")
    IBSQL.Transaction = gdcBaseManager.ReadTransaction
    IBSQL.SQL.Text = _
      "select " & _
      "  t.USR$DATEBEGIN " & _
      "from " & _
      "  usr$wg_total t " & _
      "where " & _
      "  t.DOCUMENTKEY = :TDK "
    IBSQL.ParamByName("TDK").asInteger = gdcObject.FieldByName("USR$TOTALDOCKEY").AsInteger
    IBSQL.ExecQuery
    DateCalc = IBSQL.FieldByName("USR$DATEBEGIN").AsDateTime
  else
    DateCalc = gdcObject.FieldByName("usr$from").AsDateTime
  end if
  '
  MonthOffset = 0
  '
  InflType = wg_WageSettings.Inflation.InflType
  InflFCType = wg_WageSettings.Inflation.InflFCType
  'CoefOption: fc_fcratesum ; ml_rate ; ml_msalary
  CoefOption = "fc_fcratesum"
  Select Case InflType
    Case 1
      Select Case InflFCType
        Case 2
          CoefOption = "ml_rate"
      End Select
    Case 0
      CoefOption = "ml_msalary"
  End Select
  '
  CoefOption = "ml_rate" 'только для ММК, иначе эту строку закомментировать

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
  Call wg_DisableFieldChange(gdcSalary, "AVGSALARYCALC")
  '
  gdcSalary.First
  While Not gdcSalary.EOF
    gdcSalary.Delete
  Wend
  '
  gdcObject.FieldByName("USR$AVGSUMMA").AsCurrency = 0
  '
  Sender.Repaint

  'avg_wage_in(EmplKey, FirstMoveKey, DateCalc, MonthOffset, CoefOption)
  P_in = "avg_wage_in"
  Set Tv_in = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_in = Creator.GetObject(nil, "TgsPLQuery", "")
  Tv_in.PutInteger 0, EmplKey
  Tv_in.PutInteger 1, FirstMoveKey
  Tv_in.PutDate 2, DateCalc
  Tv_in.PutInteger 3, MonthOffset
  Tv_in.PutAtom 4, CoefOption
  '
  Q_in.PredicateName = P_in
  Q_in.Termv = Tv_in
  '
  Q_in.OpenQuery
  If Q_in.EOF Then
    Exit Function
  End If
  Q_in.Close

  'avg_wage(_) - prepare data
  P_main = "avg_wage"
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

  'avg_wage_run(EmplKey, FirstMoveKey, DateCalcFrom, DateCalcTo)
  P_run = "avg_wage_run"
  Set Tv_run = Creator.GetObject(4, "TgsPLTermv", "")
  Set Q_run = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_run.PredicateName = P_run
  Q_run.Termv = Tv_run
  'avg_wage_sql(EmplKey, FirstMoveKey, Connection, PredicateName, Arity, SQL)
  P_sql = "avg_wage_sql"
  P_kb = "avg_wage_kb"
  Set Tv_sql = Creator.GetObject(6, "TgsPLTermv", "")
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
      Connection = Tv_sql.ReadAtom(2)
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
    Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, Pred
  End If

  'avg_wage(Variant) - calc result
  Q_main.OpenQuery
  If Q_main.EOF Then
    Exit Function
  End If
  Q_main.Close

  'avg_wage_out(EmplKey, FirstMoveKey, AvgWage, AvgWageVariant)
  P_out = "avg_wage_out"
  Set Tv_out = Creator.GetObject(4, "TgsPLTermv", "")
  Set Q_out = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_out.PredicateName = P_out
  Q_out.Termv = Tv_out
  'avg_wage_det(EmplKey, FirstMoveKey,
  '   Period, PeriodRule, Wage, ModernCoef, ModernWage,
  '   TabDays, NormDays, TabHoures, NormHoures)
  P_det = "avg_wage_det"
  Set Tv_det = Creator.GetObject(11, "TgsPLTermv", "")
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
      IsFull = _
        Abs( PeriodRule = "by_days_houres" _
            Or PeriodRule = "by_houres" _
            Or PeriodRule = "by_days" )
      IsCheck = Abs( Not (PeriodRule = "none") )
      Select Case PeriodRule
        Case "by_days_houres"
          PeriodRule = "табель равен графику по дням и часам"
        Case "by_days"
          PeriodRule = "табель покрывает график по дням"
        Case "by_houres"
          PeriodRule = "табель покрывает график по часам"
        Case "by_month_wage_all"
          PeriodRule = "по размеру заработка (не меньше всех полных)"
        Case "by_month_wage_any"
          PeriodRule = "по размеру заработка (не меньше любого полного)"
        Case "by_month_no_bad_type"
          PeriodRule = "виды начислений и типы часов в норме"
        Case Else
          PeriodRule = ""
      End Select
      Wage = Tv_det.ReadFloat(4)
      ModernCoef = Tv_det.ReadFloat(5)
      ModernWage = Tv_det.ReadFloat(6)
      TabDays = Tv_det.ReadFloat(7)
      NormDays = Tv_det.ReadFloat(8)
      TabHoures = Tv_det.ReadFloat(9)
      NormHoures = Tv_det.ReadFloat(10)
      '
      gdcSalary.Append
      gdcSalary.FieldByName("USR$DATE").AsVariant = Period
      gdcSalary.FieldByName("USR$SALARY").AsVariant = Wage
      gdcSalary.FieldByName("USR$COEFF").AsVariant = ModernCoef
      gdcSalary.FieldByName("USR$MODERNSALARY").AsVariant = ModernWage
      gdcSalary.FieldByName("USR$DOW").AsVariant = TabDays
      gdcSalary.FieldByName("USR$HOW").AsVariant = TabHoures
      gdcSalary.FieldByName("USR$SCHEDULERDOW").AsVariant = NormDays
      gdcSalary.FieldByName("USR$SCHEDULERHOW").AsVariant = NormHoures
      gdcSalary.FieldByName("USR$ISCHECK").AsVariant = IsCheck
      gdcSalary.FieldByName("USR$ISFULL").AsVariant = IsFull
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
  Call wg_EnableFieldChange(gdcSalary, "AVGSALARYCALC")
  '
  gdcObject.FieldByName("USR$AVGSUMMA").AsCurrency = AvgWage
  'gdcObject.Post
  '

  wg_AvgSalaryStrGenerate_pl = True
  
  T2 = Timer
  T = T2 - T1
'
End function
