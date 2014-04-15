Option Explicit
'#include wg_AvgSalaryStrGenerate_Sick_pl
'#include wg_Prolog

Sub usrg_actAvgGenerateOnExecute(ByVal Sender)
'
  Dim gdcObject, gdcSalary, Ret

  Sender.OwnerForm.GetComponent("actApply").Execute

  Call wg_Prolog.SyncField(Sender.OwnerForm.gdcObject, True)

  Set gdcObject = Sender.OwnerForm.gdcObject
  '
  gdcObject.FieldByName("USR$AVGSUMMA").Clear
  gdcObject.FieldByName("USR$THIRDMETHOD").AsInteger = 0
  gdcObject.FieldByName("USR$CALCBYBUDGET").AsInteger = 0

  Set gdcSalary = Sender.OwnerForm.GetComponent("usrg_gdcAvgSalaryStr")

  Ret = wg_AvgSalaryStrGenerate_Sick_pl(gdcObject, gdcSalary)

  Call wg_Prolog.SyncField(Sender.OwnerForm.gdcObject, False)
'
End Sub



