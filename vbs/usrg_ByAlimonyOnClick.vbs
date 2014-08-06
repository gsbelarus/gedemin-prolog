Option Explicit
' Фильтрация по Алиментам
Sub usrg_ByAlimonyOnClick(ByVal Sender)
'
  Dim gdcObject, gdcDetailObject
  Set gdcObject = Sender.OwnerForm.gdcObject
  Set gdcDetailObject = Sender.OwnerForm.gdcDetailObject
  
  Dim fltByAlimony
  Set fltByAlimony = Sender.OwnerForm.FindComponent("usrg_ByAlimony")

  Dim Creator, SQLAlimony, inID
  Set Creator = New TCreator
  Set SQLAlimony = Creator.GetObject(nil, "TIBSQL", "")
  SQLAlimony.Transaction = gdcBaseManager.ReadTransaction
  SQLAlimony.SQL.Text = _
    " SELECT DISTINCT" & _
    "   tl.DOCUMENTKEY AS ID" & _
    " FROM" & _
    "  USR$WG_TOTAL t" & _
    " JOIN" & _
    "   USR$WG_TOTALLINE tl" & _
    "     ON tl.MASTERKEY = t.DOCUMENTKEY" & _
    " JOIN" & _
    "   USR$WG_ALIMONY al" & _
    "     ON al.USR$EMPLKEY = tl.USR$EMPLKEY" & _
    " WHERE" & _
    "   t.DOCUMENTKEY = :DocKey"
  SQLAlimony.ParamByName("DocKey").AsInteger = gdcObject.FieldByName("DOCUMENTKEY").AsInteger
  SQLAlimony.ExecQuery
  
  While Not SQLAlimony.EOF
    If inID = "" Then
      inID = SQLAlimony.FieldByName("ID").AsInteger
    Else
      inID = inID & ", " & SQLAlimony.FieldByName("ID").AsInteger
    End If
    SQLAlimony.Next
  Wend

  If Assigned(fltByAlimony) Then
    If fltByAlimony.Checked Then
      gdcDetailObject.ExtraConditions.Add(" z.id in (" & inID & ")" )
    Else
      gdcDetailObject.ExtraConditions.Clear
    End If
  End If
'
End Sub
