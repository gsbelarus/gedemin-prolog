Option Explicit
'#include pl_GetScriptIDByName

Function wg_AvgSalaryDetailGenerate_Sick_pl(ByRef gdcObject, ByRef gdcDetail)
'
  Dim Creator
  '
  Dim PL, Ret, Pred, Tv, Append
  Dim PredFile
  'struct_sick_sql
  Dim P_sql, Tv_sql, Q_sql
  Dim EmplKey, FirstMoveKey, DateBegin, DateEnd, PredicateName, Arity, SQL
  'struct_sick_in
  Dim P_in, Tv_in, Q_in
  Dim DateCalc, AvgWage, CalcType, BudgetOption
  'struct_sick_out
  Dim P_out, Tv_out, Q_out
  Dim AccDate, IncludeDate, Percent, DOI, HOI, Summa

  wg_AvgSalaryDetailGenerate_Sick_pl = False

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
  Ret = PL.LoadScript(pl_GetScriptIDByName("twg_struct"))
  If Not Ret Then
    Exit Function
  End If

  'params
  EmplKey = gdcObject.FieldByName("USR$EMPLKEY").AsInteger
  FirstMoveKey = gdcObject.FieldByName("USR$FIRSTMOVEKEY").AsInteger
  DateBegin = gdcObject.FieldByName("USR$DATEBEGIN").AsDateTime
  DateEnd = gdcObject.FieldByName("USR$DATEEND").AsDateTime
  AvgWage = gdcObject.FieldByName("USR$AVGSUMMA").AsCurrency
  BudgetOption = gdcObject.FieldByName("USR$CALCBYBUDGET").AsInteger

  Dim IBSQL
  '
  Set IBSQL = Creator.GetObject(nil, "TIBSQL", "")
  IBSQL.Transaction = gdcBaseManager.ReadTransaction
  IBSQL.SQL.Text = _
      "SELECT " & _
      "  t.USR$DATEBEGIN " & _
      "FROM " & _
      "  USR$WG_TOTAL t " & _
      "WHERE " & _
      "  t.DOCUMENTKEY = :TDK "
  IBSQL.ParamByName("TDK").asInteger = gdcObject.FieldByName("USR$TOTALDOCKEY").AsInteger
  IBSQL.ExecQuery
  '
  DateCalc = IBSQL.FieldByName("USR$DATEBEGIN").AsDateTime

  IBSQL.SQL.Text = _
      "SELECT " & _
      "  it.USR$CALCTYPE " & _
      "FROM " & _
      "  USR$WG_ILLTYPE it " & _
      "WHERE " & _
      "  it.ID = :ID "
  IBSQL.ParamByName("ID").asInteger = gdcObject.FieldByName("USR$ILLTYPEKEY").AsInteger
  IBSQL.ExecQuery
  CalcType = IBSQL.FieldByName("USR$CALCTYPE").AsInteger

  'clean
  gdcDetail.First
  While Not gdcDetail.EOF
    gdcDetail.Delete
  Wend

  'struct_sick_sql(EmplKey, FirstMoveKey, DateBegin, DateEnd, PredicateName, Arity, SQL)
  P_sql = "struct_sick_sql"
  Set Tv_sql = Creator.GetObject(7, "TgsPLTermv", "")
  Set Q_sql = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_sql.PredicateName = P_sql
  Q_sql.Termv = Tv_sql
  '
  Append = False
  '
  Tv_sql.PutInteger 0, EmplKey
  Tv_sql.PutInteger 1, FirstMoveKey
  Tv_sql.PutDate 2, DateBegin
  Tv_sql.PutDate 3, DateEnd
  '
  Q_sql.OpenQuery
  Do Until Q_sql.EOF
    PredicateName = Tv_sql.ReadAtom(4)
    Arity = Tv_sql.ReadInteger(5)
    SQL = Tv_sql.ReadString(6)
    '
    Ret =  PL.MakePredicatesOfSQLSelect _
              (SQL, _
              gdcBaseManager.ReadTransaction, _
              PredicateName, PredicateName, Append)
    '
    Q_sql.NextSolution
  Loop
  Q_sql.Close
  
  'save param_list
  If PL.Debug Then
    Pred = "param_list"
    PredFile = "param_list"
    Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, PredFile
  End If

  'struct_sick_in(DateCalc, DateBegin, DateEnd, AvgWage, CalcType, BudgetOption)
  P_in = "struct_sick_in"
  Set Tv_in = Creator.GetObject(6, "TgsPLTermv", "")
  Set Q_in = Creator.GetObject(nil, "TgsPLQuery", "")
  Tv_in.PutDate 0, DateCalc
  Tv_in.PutDate 1, DateBegin
  Tv_in.PutDate 2, DateEnd
  Tv_in.PutFloat 3, AvgWage
  Tv_in.PutInteger 4, CalcType
  Tv_in.PutInteger 5, BudgetOption
  '
  Q_in.PredicateName = P_in
  Q_in.Termv = Tv_in
  '
  Q_in.OpenQuery
  If Q_in.EOF Then
    Exit Function
  End If
  Q_in.Close

  'struct_sick_out(AccDate, IncludeDate, Percent, DOI, HOI, Summa, DateBegin, DateEnd)
  P_out = "struct_sick_out"
  Set Tv_out = Creator.GetObject(8, "TgsPLTermv", "")
  Set Q_out = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_out.PredicateName = P_out
  Q_out.Termv = Tv_out
  Q_out.OpenQuery
  If Q_out.EOF Then
    Exit Function
  End If
  '
  Do Until Q_out.EOF
    '
    AccDate = Tv_out.ReadDate(0)
    IncludeDate = Tv_out.ReadDate(1)
    Percent = Tv_out.ReadFloat(2)
    DOI = Tv_out.ReadFloat(3)
    HOI = Tv_out.ReadFloat(4)
    Summa = Tv_out.ReadFloat(5)
    DateBegin = Tv_out.ReadDate(6)
    DateEnd = Tv_out.ReadDate(7)
    '
    gdcDetail.Append
    gdcDetail.FieldByName("USR$ACCDATE").AsVariant = AccDate
    gdcDetail.FieldByName("USR$INCLUDEDATE").AsVariant = IncludeDate
    gdcDetail.FieldByName("USR$PERCENT").AsVariant = Percent
    gdcDetail.FieldByName("USR$DOI").AsVariant = DOI
    gdcDetail.FieldByName("USR$HOI").AsVariant = HOI
    gdcDetail.FieldByName("USR$SUMMA").AsVariant = Summa
    gdcDetail.FieldByName("USR$DATEBEGIN").AsVariant = DateBegin
    gdcDetail.FieldByName("USR$DATEEND").AsVariant = DateEnd
    gdcDetail.Post
    '
    Q_out.NextSolution
  Loop
  Q_out.Close
  '
  gdcDetail.First

  wg_AvgSalaryDetailGenerate_Sick_pl = True
'
End function
