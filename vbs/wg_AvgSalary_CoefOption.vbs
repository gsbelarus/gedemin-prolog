Option Explicit
'#include wg_WageSettings

Sub wg_AvgSalary_CoefOption(ByRef Sender)
'
  Dim InflType, InflFCType
  Dim rbFCRate, rbRateInf, rbMovementRate, rbSalaryInf
  
  InflType = wg_WageSettings.Inflation.InflType
  InflFCType = wg_WageSettings.Inflation.InflFCType
  '
  'От оклада
  Set rbSalaryInf = Sender.GetComponent("usrg_rbSalaryInf")
  rbSalaryInf.Checked = False
  'От ставки 1-го разряда
  Set rbRateInf = Sender.FindComponent("usrg_rbRateInf")
  rbRateInf.Checked = False
  '  справочника
  Set rbFCRate = Sender.FindComponent("usrg_rbFCRate")
  rbFCRate.Checked = False
  '  кадрового движения
  Set rbMovementRate = Sender.FindComponent("usrg_rbMovementRate")
  rbMovementRate.Checked = False
  '
  Select Case InflType
    'usrg_rbSalaryInf - От оклада
    Case 0
      rbSalaryInf.Checked = True
    'usrg_rbRateInf - От ставки 1-го разряда
    Case 1
      rbRateInf.Checked = True
      '
      Select Case InflFCType
        'usrg_rbFCRate - справочника
        Case 0
          rbFCRate.Checked = True
        'usrg_rbMovementRate - кадрового движения
        Case 2
          rbMovementRate.Checked = True
      End Select
      '
  End Select
'
End Sub
