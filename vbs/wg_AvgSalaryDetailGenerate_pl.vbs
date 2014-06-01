Option Explicit
'#include pl_GetScriptIDByName

Function wg_AvgSalaryDetailGenerate_pl(ByRef Sender)
'
  Dim Creator, gdcObject, gdcDetail
  '
  Dim PL, Ret, Pred, Tv, Append
  'struct_vacation_sql
  Dim P_sql, Tv_sql, Q_sql
  Dim DocKey, DateBegin, DateEnd, PredicateName, Arity, SQL
  'struct_vacation_in
  Dim P_in, Tv_in, Q_in
  Dim DateCalc, AvgWage, SliceOption
  'struct_vacation_out
  Dim P_out, Tv_out, Q_out
  Dim AccDate, IncludeDate, Duration, Summa, VcType

  wg_AvgSalaryDetailGenerate_pl = False
  Set Creator = New TCreator

  Sender.GetComponent("actApply").Execute

  Set gdcObject = Sender.gdcObject
  '
  DocKey = gdcObject.FieldByName("DOCUMENTKEY").AsInteger
  DateBegin = gdcObject.FieldByName("USR$DATEBEGIN").AsDateTime
  DateEnd = gdcObject.FieldByName("USR$DATEEND").AsDateTime
  AvgWage = gdcObject.FieldByName("USR$AVGSUMMA").AsCurrency
  SliceOption = 0
  '
  Dim IBSQL
  Set IBSQL = Creator.GetObject(nil, "TIBSQL", "")
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
  '

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

  Set gdcDetail = Sender.gdcDetailObject
  '
  gdcDetail.First
  While Not gdcDetail.EOF
    gdcDetail.Delete
  Wend
  '
  Sender.Repaint

  'struct_vacation_sql(DocKey, DateBegin, DateEnd, PredicateName, Arity, SQL)
  P_sql = "struct_vacation_sql"
  Set Tv_sql = Creator.GetObject(6, "TgsPLTermv", "")
  Set Q_sql = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_sql.PredicateName = P_sql
  Q_sql.Termv = Tv_sql
  '
  Append = False
  '
  Tv_sql.PutInteger 0, DocKey
  Tv_sql.PutDate 1, DateBegin
  Tv_sql.PutDate 2, DateEnd
  '
  Q_sql.OpenQuery
  If Q_sql.EOF Then
    Exit Function
  End If
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
    '
    Q_sql.NextSolution
  Loop
  Q_sql.Close
  '

  'struct_vacation_in(DateCalc, DateBegin, DateEnd, AvgWage, SliceOption)
  P_in = "struct_vacation_in"
  Set Tv_in = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_in = Creator.GetObject(nil, "TgsPLQuery", "")
  Tv_in.PutDate 0, DateCalc
  Tv_in.PutDate 1, DateBegin
  Tv_in.PutDate 2, DateEnd
  Tv_in.PutFloat 3, AvgWage
  Tv_in.PutInteger 4, SliceOption
  '
  Q_in.PredicateName = P_in
  Q_in.Termv = Tv_in
  '
  Q_in.OpenQuery
  If Q_in.EOF Then
    Exit Function
  End If
  Q_in.Close

  'struct_vacation_out(AccDate, IncludeDate, Duration, Summa, DateBegin, DateEnd, VcType)
  P_out = "struct_vacation_out"
  Set Tv_out = Creator.GetObject(7, "TgsPLTermv", "")
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
    Duration = Tv_out.ReadFloat(2)
    Summa = Tv_out.ReadFloat(3)
    DateBegin = Tv_out.ReadDate(4)
    DateEnd = Tv_out.ReadDate(5)
    VcType = Tv_out.ReadInteger(6)
    '
    gdcDetail.Append
    gdcDetail.FieldByName("USR$ACCDATE").AsVariant = AccDate
    gdcDetail.FieldByName("USR$INCLUDEDATE").AsVariant = IncludeDate
    gdcDetail.FieldByName("USR$DURATION").AsVariant = Duration
    gdcDetail.FieldByName("USR$SUMMA").AsVariant = Summa
    gdcDetail.FieldByName("USR$DATEBEGIN").AsVariant = DateBegin
    gdcDetail.FieldByName("USR$DATEEND").AsVariant = DateEnd
    'gdcDetail.FieldByName("USR$VCTYPE").AsVariant = VcType
    gdcDetail.Post
    '
    Q_out.NextSolution
  Loop
  Q_out.Close
  '
  gdcDetail.First

  wg_AvgSalaryDetailGenerate_pl = True
'
End function
