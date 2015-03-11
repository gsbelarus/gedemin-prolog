'#include PL_GETSCRIPTIDBYNAME
'#include WG_PU_CHECKFORMAT
Option Explicit
'#include wg_pu_pl

Function wg_pu3_Create_pl(ByRef f)
'
  Dim Creator
  Set Creator = New TCreator
  
  Dim DateBegin, DateEnd
  ' Получение параметров из установок формы
  DateBegin = f.GetComponent("usrg_PeriodPU3").Date
  DateEnd = f.GetComponent("usrg_PeriodPU3").EndDate

  ' Список всех сотрудников, работающих в выбранном интервале
  Dim Checked, EmplList, gdcEmployee, SubSet, i, Id
  Set Checked = f.FindComponent("usrg_RadioGroup3")
  EmplList = ""
  '
  If Assigned(Checked) Then
    Set gdcEmployee = Creator.GetObject(nil, "TgdcEmployee", "")
    SubSet = "ByPeriod"
    wage_EmplDateBegin = DateBegin
    wage_EmplDateEnd = DateEnd
    gdcEmployee.Open
    ' выводим список сотрудников
    If gdcEmployee.ChooseItemsSelf(False, "", SubSet) Then
      ' заносим выбранных сотрудников
      For i = 0 to gdcEmployee.SelectedId.Count - 1
        Id = gdcEmployee.SelectedId(i)
        If EmplList = "" Then
          EmplList = EmplList & Id
        Else
          EmplList = EmplList & "," & Id
        End If
      Next
    End If
  End If

  Dim frm, pr
  Set frm = Creator.GetObject(nil, "usrf_bn_info", "")
  frm.GetComponent("usrg_memo1").Lines.Text = "Сбор данных..."
  '
  Set pr = frm.GetComponent("usrg_ProgressBar1")
  pr.Min = 0
  pr.Max = 1
  pr.Step = 1
  pr.Position = 0
  frm.Show
  '
  frm.Repaint
  frm.BringToFront

  Dim Empl, SQLText, RecCount
  Set Empl = Creator.GetObject(null,"TIBDataset","")
  Empl.Transaction = gdcBaseManager.ReadTransaction
  '
  SQLText = _
    " SELECT " & _
    "   tch.USR$EMPLKEY AS EmplKey, " & vbCrlf & _
    "   SUM(USR$DEBIT) AS S1, " & vbCrlf & _
    "   0 AS S2, " & vbCrlf & _
    "   COALESCE(c.name, '') AS Name " & vbCrlf & _
    " FROM USR$WG_TBLCHARGE tch " & vbCrlf & _
    " JOIN USR$CROSS179_256548741 ft_gr ON ft_gr.USR$WG_FEETYPEKEY = tch.USR$FEETYPEKEY " & vbCrlf & _
    " LEFT JOIN gd_contact c ON c.ID = tch.USR$EMPLKEY " & vbCrlf & _
    " WHERE " & vbCrlf & _
    "   ft_gr.USR$WG_FEEGROUPKEY = (SELECT id FROM GD_P_GETID(147021001,274788016))" & vbCrlf & _
    "   AND tch.USR$DATEBEGIN >= :datebegin AND tch.USR$DATEBEGIN <= :dateend " & vbCrlf
  '
  If EmplList <> "" Then
    SQLText = SQLText & " AND tch.USR$EMPLKEY IN (" & EmplList & ") " & vbCrlf
  End If
  '
  SQLText = SQLText & _
    " GROUP BY 1, 3, 4 " & vbCrlf
  '
  SQLText = SQLText & _
    " UNION " & vbCrlf & _
    " SELECT " & vbCrlf & _
    "   tch.USR$EMPLKEY AS EmplKey, " & vbCrlf & _
    "   0 AS S1, " & vbCrlf & _
    "   SUM(USR$DEBIT) AS S2, " & vbCrlf & _
    "   COALESCE(c.name, '') AS Name " & vbCrlf & _
    " FROM USR$WG_TBLCHARGE tch " & vbCrlf & _
    " JOIN USR$WG_FEETYPE ft ON ft.ID = tch.USR$FEETYPEKEY " & vbCrlf & _
    " LEFT JOIN gd_contact c ON c.id = tch.USR$EMPLKEY " & vbCrlf & _
    " WHERE " & vbCrlf & _
    "   ft.PARENT = (SELECT id FROM GD_P_GETID(147025974,403876601))" & vbCrlf & _
    "   AND tch.USR$DATEBEGIN >= :datebegin AND tch.USR$DATEBEGIN <= :dateend " & vbCrlf
  '
  If EmplList <> "" Then
    SQLText = SQLText & " AND tch.USR$EMPLKEY IN (" & EmplList & ") " & vbCrlf
  End If
  '
  SQLText = SQLText & _
    " GROUP BY 1, 2, 4 " & vbCrlf
  '
  SQLText = SQLText & _
    " UNION " & vbCrlf & _
    " SELECT " & vbCrlf & _
    "   ld.USR$EMPLKEY AS EmplKey, " & vbCrlf & _
    "   0 AS S1, " & vbCrlf & _
    "   0 AS S2, " & vbCrlf & _
    "   COALESCE(c.name, '') AS Name " & vbCrlf & _
    " FROM USR$WG_LEAVEDOCLINE ld " & vbCrlf & _
    " LEFT JOIN gd_contact c ON c.id = ld.USR$EMPLKEY " & vbCrlf & _
    " WHERE ld.USR$DATEBEGIN <= :dateend " & vbCrlf & _
    "   AND COALESCE(ld.USR$DATEEND, :dateend) >= :datebegin " & vbCrlf
  '
  If EmplList <> "" Then
    SQLText = SQLText & " AND ld.USR$EMPLKEY IN (" & EmplList & ") " & vbCrlf
  End If
  '
  SQLText = _
    " SELECT EmplKey, SUM(S1) AS FeeAmount, SUM(S2) AS SickAmount, Name " & vbCrlf & _
    " FROM ( " & vbCrlf  & _
    SQLText & " ) " & vbCrlf & _
    " GROUP BY 1, 4 ORDER BY 4 " & vbCrlf
  '
  Empl.SelectSQL.Text = SQLText
  Empl.ParamByName("datebegin").AsDateTime = DateBegin
  Empl.ParamByName("dateend").ASDateTime = DateEnd
  Empl.Open
  Empl.Last
  Empl.First
  RecCount = Empl.RecordCount
  
  pr.StepIt
  frm.Repaint
  frm.BringToFront
  '
  frm.GetComponent("usrg_memo1").Lines.Text = "Идёт формирование файла..."
  pr.Min = 0
  pr.Max = RecCount
  pr.Step = 1
  pr.Position = 0
  frm.Show
  
  Dim EDoc, EDocRet, LogMsg, EDocCount
  EDocCount = 0
  Dim FeeTotal, SickTotal
  FeeTotal = 0 : SickTotal = 0
  Dim EDocFeeTotal, EDocSickTotal
  EDocFeeTotal = 0 : EDocSickTotal = 0
  EDoc = ""
  EDocCount = 0
  'init
  Dim PL, Ret, ScriptName
  Set PL = Designer.CreateObject(nil, "TgsPLClient", "")
  Ret = PL.Initialise("")
  'load
  If PL.IsInitialised Then
    ScriptName = "twg_pu"
    Ret = PL.LoadScript(pl_GetScriptIDByName(ScriptName))
  End If
  Dim Scope, EmplKey, TabOption, EmplCount
  Dim EDocType, UNPF, PhoneNum
  Scope = "wg_pu_3"
  EmplKey = 0
  EmplCount = 1
  EDocType = f.GetComponent("usrg_RadioGroup3").ItemIndex
  TabOption = Abs(f.GetComponent("usrg_useTBL").Checked)
  UNPF = Trim(f.GetComponent("usrg_UNPF").Text)
  PhoneNum = Trim(f.GetComponent("usrg_edPhone").Text)

  Dim fldr, fso, tf , n
  fldr = "c:\WagePU\"
  Set fso = CreateObject("Scripting.FileSystemObject")
  If Not (fso.FolderExists(fldr)) Then
    fso.CreateFolder(fldr)
  End If
  n = fldr & f.GetComponent("usrg_NumberOFpackage").Value & "_Log.txt"
  Set tf = fso.CreateTextFile(n, True)

  While Not Empl.Eof
    If EmplCount = 10 Then
      EmplCount = 0
      PL.DestroyObject
      'init
      Set PL = Designer.CreateObject(nil, "TgsPLClient", "")
      Ret = PL.Initialise("")
      'load
      If PL.IsInitialised Then
        ScriptName = "twg_pu"
        Ret = PL.LoadScript(pl_GetScriptIDByName(ScriptName))
      End If
    End If
    '
    If Not EmplKey = Empl.FieldByName("EmplKey").AsInteger Then
      EmplKey = Empl.FieldByName("EmplKey").AsInteger
      EmplCount = EmplCount + 1
      '
      If Ret Then
        If PL.IsInitialised Then
          EDocRet = wg_pu_pl(Scope, EmplKey, DateBegin, DateEnd, _
                             EDocType, TabOption, UNPF, PhoneNum, _
                             PL)
          '
          FeeTotal = FeeTotal + Empl.FieldByName("FeeAmount").AsCurrency
          SickTotal = SickTotal + Empl.FieldByName("SickAmount").AsCurrency
          '
          If EDocRet = "" Then
            LogMsg = _
                     "<ЭД-ПУСТО=" & Empl.FieldByName("EmplKey").AsInteger & _
                     "=" & Empl.FieldByName("Name").AsString & _
                     "=" & Empl.FieldByName("FeeAmount").AsCurrency & _
                     "=" & Empl.FieldByName("SickAmount").AsCurrency & ">"
            tf.WriteLine(LogMsg)
            EDocCount = EDocCount + 1
          Else
            '
            Dim EDocArr, k, EDocSub
            Dim EDocFeeAmount, EDocSickAmount, EOD
            '
            EDocArr = Split(EDocRet, "<ПУ-3=")
            For k = LBound(EDocArr)+1 To UBound(EDocArr)
              EDocSub = EDocArr(k)
              '
              If InStr(EDocSub, "СТАЖ") > 0 Then
                EOD = "СТАЖ"
              Else
                EOD = ">"
              End If
              '
              EDocFeeAmount = 0 : EDocSickAmount = 0
              If InStr(EDocSub, EOD) > 0 And InStr(EDocSub, "НЧСЛ") > 0 Then
                Dim AmountStr, AmountArr, EDocMonth
                AmountStr = Mid( EDocSub, _
                                 InStr(EDocSub, "НЧСЛ"), _
                                 InStr(EDocSub, EOD) - InStr(EDocSub, "НЧСЛ") - 1 _
                               )
                AmountArr = Split(AmountStr, "НЧСЛ")
                '
                For i = LBound(AmountArr)+1 To UBound(AmountArr)
                  EDocMonth = Split(AmountArr(i), "=")
                  EDocFeeAmount = EDocFeeAmount + CCur(EDocMonth(2))
                  EDocSickAmount = EDocSickAmount + CCur(EDocMonth(3))
                Next
              End If
              '
              EDocFeeTotal = EDocFeeTotal + EDocFeeAmount
              EDocSickTotal = EDocSickTotal + EDocSickAmount
              '
              Dim FeeDiff, SickDiff
              FeeDiff = Empl.FieldByName("FeeAmount").AsCurrency - EDocFeeAmount
              SickDiff = Empl.FieldByName("SickAmount").AsCurrency - EDocSickAmount
              '
              LogMsg = _
                     "<ЭД"
              '
              If FeeDiff <> 0 Or SickDiff <> 0 Then
                LogMsg = LogMsg & "-РАЗН"
              End If
              '
              If EOD = ">" Then
                LogMsg = LogMsg & "-СТАЖ"
              End If
              '
              LogMsg = LogMsg & _
                       "=" & Empl.FieldByName("EmplKey").AsInteger & _
                       "=" & Empl.FieldByName("Name").AsString & _
                       "=" & Empl.FieldByName("FeeAmount").AsCurrency & _
                       "=" & Empl.FieldByName("SickAmount").AsCurrency & _
                       "=" & EDocFeeAmount & _
                       "=" & EDocSickAmount & _
                       "=" & FeeDiff & _
                       "=" & SickDiff & _
                       ">"
              tf.WriteLine(LogMsg)
              EDocCount = EDocCount + 1
            Next
            '
          End If
          EDoc = EDoc & EDocRet
          '
        End If
      Else
        Exit Function
      End If
    End If

    pr.StepIt
    frm.Repaint
    frm.BringToFront

    Empl.Next
  Wend

  LogMsg = _
           "<ИТОГО=" & EDocCount & _
           "=" & " " & _
           "=" & FeeTotal & _
           "=" & SickTotal & _
           "=" & EDocFeeTotal & _
           "=" & EDocSickTotal & _
           "=" & FeeTotal - EDocFeeTotal & _
           "=" & SickTotal - EDocSickTotal & _
           ">"
  tf.WriteLine(LogMsg)
  '
  PL.DestroyObject

  Dim FileName, file
  FileName = fldr & f.GetComponent("usrg_NumberOFpackage").Value & ".txt"
  Set file =  fso.CreateTextFile(FileName, True)
  ' Запись в файл заголовка пачки
  file.WriteLine("ЗГЛВ=1.5=")
  ' Запись в файл Записи о пачке
  dim q, TaxID, phone, LegalNumber, CompanyName, NumberOfPackage
  '
  Set q = Creator.GetObject(nil,"TIBSQL","")
  q.Transaction = gdcBaseManager.ReadTransaction
  q.SQL.Text =  _
    " select " & _
    " con.name as CompanyName, " & _
    " con.phone as phone, " & _
    " code.Taxid as TaxID, " & _
    " code.legalnumber as LegalNumber" & _
    " from gd_contact con " & _
    " left join gd_company company on company.contactkey = con.id " & _
    " left join gd_companycode code on code.companykey = company.contactkey " & _
    " where con.id = <COMPANYKEY/>"
  q.ExecQuery

  TaxID = wg_pu_CheckFormat(q.FieldByNAme("TaxID").ASString, 0)
  LegalNumber =  wg_pu_CheckFormat(Q.FieldByName("LegalNumber").AsString, 0)
  CompanyName =  wg_pu_CheckFormat(Q.FieldByName("CompanyName").AsString, 1)
  NumberOfPackage = wg_pu_CheckFormat(f.GetComponent("usrg_NumberOfPackage").Value, 0)

  EDocRet = _
    "<ПАЧК=" & TaxID & "=" & UNPF & "=" & CompanyName & "=" & NumberOfPackage & _
    "= = =" & "1" & "="
  file.WriteLine(EDocRet)
  '
  EDocRet = _
    "ТИПД=ПУ-3=" & 1 & "=" & 0 & "=" & 0 & "=" & 0 & "=" & "0" & "=>"
  file.WriteLine(EDocRet)
  '
  file.write(EDoc)

  Call Application.MessageBox("Создан файл " & fldr & FileName, "Внимание", vbOkOnly + vbApplicationModal)
'
End Function
