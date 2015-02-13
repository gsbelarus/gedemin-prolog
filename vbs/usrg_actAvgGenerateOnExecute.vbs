'#include wg_CalcAvgAddPay_pl
Option Explicit

Sub usrg_actAvgGenerateOnExecute(ByVal Sender)
'
  Dim gdcObject, gdcDetailObject, gdcSalary, Ret

  Sender.OwnerForm.GetComponent("actApply").Execute

  Set gdcObject = Sender.OwnerForm.gdcObject
  Set gdcDetailObject = Sender.OwnerForm.gdcDetailObject
  Set gdcSalary = Sender.OwnerForm.GetComponent("usrg_gdcAvgSalaryStr")

  Dim MonthBefore, MonthOffset
  'init
  Dim PL
  Set PL = Designer.CreateObject(nil, "TgsPLClient", "")
  Ret = PL.Initialise("")
  If Not Ret Then
    PL.DestroyObject
    PL = Empty
    Exit Sub
  End If
  'debug
  PL.Debug = True
  'load
  Ret = PL.LoadScript(pl_GetScriptIDByName("twg_avg_wage"))
  If Not Ret Then
    Exit Sub
  End If
  '
  MonthBefore = 0
  MonthOffset = 0
  Do
    Ret = wg_CalcAvgAddPay_pl(gdcObject, gdcDetailObject, gdcSalary, MonthBefore, MonthOffset, PL)
    Select Case Ret
      Case "need_more"
        MonthBefore = MonthBefore + 1
      Case "by_current_month"
        '
        If Not MonthOffset < 0 Then
          '
          Dim Msg
          Msg = "Сотрудник: " & _
                gdcDetailObject.FieldByName("U_USR$EMPLKEY_NAME").AsString & _
                vbCrLf & _
                "Требуется итоговый расчет для текущего месяца." & _
                vbCrLf & _
                "Продолжить?"
          '
          If MsgBox(Msg, vbExclamation + vbYesNoCancel, "Предупреждение") = vbYes Then
            MonthBefore = 0
            MonthOffset = -1
          Else
            Exit Do
          End If
          '
        Else
          Exit Do
        End If
        '
      Case Else
        Exit Do
    End Select
  Loop
  '
  PL.DestroyObject
  PL = Empty
'
End Sub


