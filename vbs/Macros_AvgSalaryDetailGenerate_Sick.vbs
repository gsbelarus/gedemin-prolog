Option Explicit
'#include wg_AvgSalaryDetailGenerate_Sick_pl

Sub Macros_AvgSalaryDetailGenerate_Sick(OwnerForm)
'
  Dim gdcObject, gdcDetail, Ret

  If Not OwnerForm.gdcObject.VariableExists("DontRecalcLine") Then
    OwnerForm.gdcObject.AddVariableItem("DontRecalcLine")
  End If
  OwnerForm.gdcObject.Variables("DontRecalcLine") = True
  'Сбрасываем кэш для Переменных
  set wg_Variable_ = Nothing

  OwnerForm.GetComponent("actApply").Execute

  Set gdcObject = OwnerForm.gdcObject
  Set gdcDetail = OwnerForm.gdcDetailObject
  
  Ret = wg_AvgSalaryDetailGenerate_Sick_pl(gdcObject, gdcDetail)
  
  OwnerForm.gdcObject.Variables("DontRecalcLine") = False
'
End Sub
