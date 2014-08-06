option explicit
sub gdc_dlgUserComplexDocument147567052_119619099OnClose(ByVal Sender, ByRef Action)
'*** Данный код необходим для вызова встроенного обработчика ***
'*** В случае его удаления возможно нарушение работы системы ***
  Dim ParamArr(1)
  Set   ParamArr(0) = Sender
  ParamArr(1) = Action
  call   Inherited(Sender, "OnClose", ParamArr)
  Action.Value = ParamArr(1)
'*** конец кода поддержки встроенного обработчика            ***
  dim gdcDetail
  set gdcDetail = Sender.OwnerForm.gdcDetailObject
  call gdcDetail.SelectedID.Clear
  gdcDetail.Close
  call gdcDetail.RemoveSubSet("OnlySelected")
  gdcDetail.Open
  
  ' Отменить фильтрацию по Алиментам
  'Sender.OwnerForm.FindComponent("usrg_ByAlimony").Checked = False
  'Call usrg_ByAlimonyOnClick(Sender)
  '
end sub
