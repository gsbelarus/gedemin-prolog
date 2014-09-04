Option Explicit
Function rp_FeeCalc_Prot(OwnerForm)
  BaseQueryList.Clear

  Dim qProt
  Dim gdcObject, EmplKey, TotalDocKey, FeeTypeKey

  Set gdcObject = OwnerForm.gdcObject
  EmplKey = gdcObject.FieldByName("USR$EMPLKEY").AsInteger
  TotalDocKey = gdcObject.FieldByName("USR$TOTALDOCKEY").AsInteger
  FeeTypeKey = gdcObject.FieldByName("USR$FEETYPEKEY").AsInteger
  
  BaseQueryList.Clear
  Set qProt = BaseQueryList.Query(BaseQueryList.Add("Prot", 0))
  qProt.SQL = _
    " SELECT * FROM USR$WG_TBLCHARGE_PROT" & _
    " WHERE" & _
    "       USR$EMPLKEY = " & EmplKey & _
    "   AND USR$TOTALDOCKEY = " & TotalDocKey & _
    "   AND USR$FEETYPEKEY = " & FeeTypeKey
  qProt.Open

  Set rp_FeeCalc_Prot = BaseQueryList
End Function
