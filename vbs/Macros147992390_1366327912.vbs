Option Explicit

Sub Macros147992390_1366327912
  Dim Creator
  Dim OpenDialog, FileName, FilePath
  Dim objConnection, objADOQuery_People, SQL
  Dim Trans, QueryUpd
  
  Set Creator = New TCreator

  Set OpenDialog = Creator.GetObject(nil, "TOpenDialog", "")
  OpenDialog.Filter = "*.dbf|*.dbf"
  If Not OpenDialog.Execute Then
    Exit Sub
  End If
  '
  FileName = mid(OpenDialog.FileName, InStrRev(OpenDialog.FileName, "\") + 1, 255)
  FilePath = mid(OpenDialog.FileName, 1, InStrRev(OpenDialog.FileName, "\") -1)

  Set objConnection = CreateObject("ADODB.Connection")
  objConnection.Provider = "Microsoft.Jet.OLEDB.4.0"
  objConnection.Properties("Data Source") = FilePath
  objConnection.Properties("Jet OLEDB:Engine Type") = 18
  objConnection.Open
  '
  Set objADOQuery_People = CreateObject("ADODB.RecordSet")
  objADOQuery_People.ActiveConnection = objConnection
  SQL = _
" SELECT" & _
"   TAB_NOM AS LN," & _
"   Trim(KART_SCHET) AS A" & _
" FROM " & FileName & _
" WHERE" & _
"   NOT KART_SCHET IS NULL"
  objADOQuery_People.Open SQL, objConnection, 3

  Set Trans = Creator.GetObject(nil, "TIBTransaction", "")
  Trans.DefaultDataBase = gdcBaseManager.Database
  Trans.StartTransaction

  Set QueryUpd = Creator.GetObject(nil, "TIBSQL", "")
  QueryUpd.Transaction = Trans
  QueryUpd.SQL.Text = _
" UPDATE GD_PEOPLE p" & _
" SET p.USR$ACCOUNT = :A" & _
" WHERE p.CONTACTKEY = " & _
"   (SELECT FIRST 1 ID FROM GD_CONTACT con WHERE con.USR$WG_LISTNUM = :LN)"
  
  While Not objADOQuery_People.EOF
    QueryUpd.Close
    QueryUpd.ParamByName("LN").AsInteger = objADOQuery_People.Fields("LN").Value
    QueryUpd.ParamByName("A").AsVariant = objADOQuery_People.Fields("A").Value
    QueryUpd.ExecQuery
    '
    objADOQuery_People.MoveNext
  Wend
  
  Trans.Commit
End Sub
