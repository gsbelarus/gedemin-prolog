Option Explicit

'uses pl_Const
Function pl_GetScriptIDByName(Name)
  Dim Creator, ibsql

  pl_GetScriptIDByName = 0

  Set Creator = New TCreator
  Set ibsql = Creator.GetObject(nil, "TIBSQL", "")

  ibsql.Transaction = gdcBaseManager.ReadTransaction
  ibsql.SQL.TEXT = _
      "SELECT * FROM gd_function" & _
      " WHERE UPPER(name) = UPPER(:name) AND module = :module"
  ibsql.ParamByName("name").AsString = Name
  ibsql.ParamByName("module").AsString = scrPrologModuleName
  ibsql.ExecQuery

  If Not ibsql.EOF Then
     pl_GetScriptIDByName = ibsql.FieldByName("id").AsInteger
  End If
End Function
