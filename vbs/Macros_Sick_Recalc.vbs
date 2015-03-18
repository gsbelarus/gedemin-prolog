Option Explicit
'#include wg_AvgSalaryStrGenerate_Sick_pl
'#include wg_Prolog
'#include wg_AvgSalaryDetailGenerate_Sick_pl

Sub Macros_Sick_Recalc(OwnerForm)
'
  Dim gdcObject, gdcDetail, gdcAvgStr, Creator, inID, Ret
  Set gdcObject = OwnerForm.gdcObject
  Set gdcDetail = OwnerForm.gdcDetailObject

  Call wg_Prolog.SyncField(OwnerForm.gdcObject, True)

  If Not OwnerForm.gdcObject.VariableExists("DontRecalcLine") Then
    OwnerForm.gdcObject.AddVariableItem("DontRecalcLine")
  End If
  '
  OwnerForm.gdcObject.Variables("DontRecalcLine") = True

  gdcObject.First
  inID = ""
  '
  While Not gdcObject.eof
    If inID = "" Then
      inID = gdcObject.ID
    Else
      inID = inID & ", " & gdcObject.ID
    End If
    '
    gdcObject.Next
  Wend
  '
  inID = "(" & inID & ")"
  gdcObject.ExtraConditions.Add(" z.id in " & inID )

  Set Creator = New TCreator
  Set gdcAvgStr = Creator.GetObject(OwnerForm, "TgdcAttrUserDefined", "")
  gdcAvgStr.SubType = "USR$WG_AVGSALARYSTR"
  gdcAvgStr.Transaction = gdcObject.Transaction
  gdcAvgStr.ReadTransaction = gdcObject.ReadTransaction
  gdcAvgStr.SubSet = "ByParent"
  gdcAvgStr.MasterSource = OwnerForm.GetComponent("dsMain")
  gdcAvgStr.MasterField = "ID"
  gdcAvgStr.DetailField = "PARENT"
  gdcAvgStr.Open

  gdcObject.First
  '
  While Not gdcObject.EOF
    gdcObject.Edit
    gdcObject.FieldByName("USR$AVGSUMMA").Clear
    gdcObject.FieldByName("USR$THIRDMETHOD").AsInteger = 0
    gdcObject.FieldByName("USR$CALCBYBUDGET").AsInteger = 0
    gdcObject.FieldByName("USR$AVERAGE").AsInteger = 0

    Ret = wg_AvgSalaryStrGenerate_Sick_pl(gdcObject, gdcAvgStr)
    Ret = wg_AvgSalaryDetailGenerate_Sick_pl(gdcObject, gdcDetail)
    '
    gdcObject.Next
  Wend

  OwnerForm.gdcObject.Variables("DontRecalcLine") = False
  Call wg_Prolog.SyncField(OwnerForm.gdcObject, False)
  gdcObject.ExtraConditions.Clear
'
End Sub
