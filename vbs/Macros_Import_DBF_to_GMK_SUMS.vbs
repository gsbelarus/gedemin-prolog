'#include WG_CHECKTOTALDOC
Option Explicit

Sub Macros_Import_DBF_to_GMK_SUMS(OwnerForm)
  Dim Creator
  Set Creator = new TCreator

  Dim OpenDialog
  Set OpenDialog = Creator.GetObject(nil, "TOpenDialog", "")
  OpenDialog.Filter = "*.dbf|*.dbf"
  OpenDialog.Title = "Укажите файл справочника кодов"
  '
  If Not OpenDialog.Execute Then Exit Sub
  '
  Dim FileNameDict, FilePath
  FileNameDict = mid(OpenDialog.FileName, InStrRev(OpenDialog.FileName, "\") + 1, 255)
  FilePath = mid(OpenDialog.FileName, 1, InStrRev(OpenDialog.FileName, "\") -1)

  OpenDialog.Title = "Укажите файл табеля/начислений"
  '
  If Not OpenDialog.Execute Then Exit Sub
  '
  Dim FileNameData
  FileNameData = mid(OpenDialog.FileName, InStrRev(OpenDialog.FileName, "\") + 1, 255)

  Dim objConnection, objADOQuery_People
  Set objConnection = CreateObject("ADODB.Connection")
  objConnection.Provider = "Microsoft.Jet.OLEDB.4.0"
  objConnection.Properties("Data Source") = FilePath
  objConnection.Properties("Jet OLEDB:Engine Type") = 18
  objConnection.Open

  Dim T1, T2
  T1 = Time

  Dim frm, pr
  Set frm = Creator.GetObject(nil, "usrf_bn_info","")

  Dim SQL, Rec
  SQL = _
  " SELECT " & VBCR & _
  "   z.DatR, z.DatO, a.KOD, z.TNNP, z.DN, z.CL, z.S, a.P15, a.P19, a.P20" & VBCR & _
  " FROM " & FileNameData & " z " & VBCR & _
  " INNER JOIN " & FileNameDict & " a " & VBCR & _
  "   ON CInt(z.KOD) = CInt(a.KOD) " & VBCR & _
  " ORDER BY " & VBCR & _
  "   z.TNNP, z.DatO "
  '
  frm.FindComponent("usrg_memo1").Lines.Text = _
    "Выполняется запрос на формирование данных..."
  frm.Show
  frm.Repaint
  frm.BringToFront
  '
  Set objADOQuery_People = CreateObject("ADODB.RecordSet")
  objADOQuery_People.ActiveConnection = objConnection
  objADOQuery_People.Open SQL, objConnection, 3
  objADOQuery_People.MoveLast
  Rec = objADOQuery_People.RecordCount

  Set pr = frm.GetComponent("usrg_ProgressBar1")
  pr.Min = 0
  pr.Max = Rec
  pr.Step = 1
  pr.Position = 0
  '
  frm.FindComponent("usrg_memo1").Lines.Text = _
  "Сформировано записей: " & Rec & vbCrLf & "Идёт загрузка данных..."  & _
  frm.Repaint
  frm.BringToFront

  Dim qPeople
  Set qPeople = Creator.GetObject(nil, "TIBDataset", "")
  qPeople.Transaction = gdcBaseManager.ReadTransaction
  qPeople.SelectSQL.Text = _
    " SELECT c.ID, CAST(c.USR$WG_LISTNUM AS NUMERIC) AS LISTNUM FROM GD_CONTACT c" & _
    " WHERE c.CONTACTTYPE = 2 AND CAST(c.USR$WG_LISTNUM AS NUMERIC) > 0" & _
    " ORDER BY LISTNUM"
  qPeople.Open
  qPeople.Last
  qPeople.First

  Dim gdcObject
  Set gdcObject = Creator.GetObject(nil, "TgdcAttrUserDefined", "")
  gdcObject.Close
  gdcObject.SubSet = "ByID"
  gdcObject.SubType = OwnerForm.gdcObject.SubType
  gdcObject.Open

  Dim FSO, TF , FN
  Set FSO = CreateObject("Scripting.FileSystemObject")
  FN = FilePath & "\" & FileNameData & "ImportLog.txt"
  Set TF = FSO.CreateTextFile(FN, True, True)

  Dim DocDateT, DocDateI, TotalDocKey, InDocKey, YO, YR
  objADOQuery_People.MoveFirst

  Dim TNNP
  TNNP = ""

  Dim Trans
  Set Trans = Creator.GetObject(nil, "TIBTransaction", "")
  Trans.DefaultDataBase = gdcBaseManager.Database

  While Not objADOQuery_People.EoF
    DocDateT = _
      CDate("01." & Left(objADOQuery_People.Fields("DatR").Value,2) & "." & _
            "20" & Right(objADOQuery_People.Fields("DatR").Value,2))
    DocDateI = _
      CDate("01." & Left(objADOQuery_People.Fields("DatO").Value,2) & "." & _
            "20" & Right(objADOQuery_People.Fields("DatO").Value,2))
    TotalDocKey = wg_CheckTotalDoc(DocDateT, Trans, Trans)
    InDocKey = wg_CheckTotalDoc(DocDateI, Trans, Trans)
    '
    If qPeople.Locate("LISTNUM", objADOQuery_People.Fields("TNNP").Value, "loCaseInsensitive") Then
      If _
        Not IsNull(objADOQuery_People.Fields("P15").Value) Or _
        Not IsNull(objADOQuery_People.Fields("P19").Value) Or _
        Not IsNull(objADOQuery_People.Fields("P20").Value) _
      Then
        gdcObject.Append
        gdcObject.FieldByName("USR$EMPLKEY").AsInteger = qPeople.FieldByName("ID").AsInteger
        gdcObject.FieldByName("USR$LISTNUMBER").AsString = objADOQuery_People.Fields("TNNP").Value
        gdcObject.FieldByName("USR$VO").AsString = objADOQuery_People.Fields("KOD").Value
        gdcObject.FieldByName("USR$TOTALDOCKEY").AsInteger = TotalDocKey
        gdcObject.FieldByName("USR$INDOCKEY").AsInteger = InDocKey
      
        'для отпусков
        If Not IsNull(objADOQuery_People.Fields("P15").Value) Then
          gdcObject.FieldByName("USR$SUM").AsVariant = objADOQuery_People.Fields("S").Value
          '
          Select Case objADOQuery_People.Fields("KOD").Value
            Case 2,4,5,7,8,902,904,905,907,908,79,14,20,21,22,62,46,51,81,82,156,69,220,146,320,321
              gdcObject.FieldByName("USR$DOW").AsVariant = 0
              gdcObject.FieldByName("USR$MID_HOW").AsVariant = 0
            Case Else
              gdcObject.FieldByName("USR$DOW").AsVariant = objADOQuery_People.Fields("DN").Value
              gdcObject.FieldByName("USR$MID_HOW").AsVariant = objADOQuery_People.Fields("CL").Value
          End Select
        End If

        'для больничных
        If Not IsNull(objADOQuery_People.Fields("P19").Value) Or Not IsNull(objADOQuery_People.Fields("P20").Value) Then
          gdcObject.FieldByName("USR$SUMSICK").AsVariant = objADOQuery_People.Fields("S").Value
          gdcObject.FieldByName("USR$HOW").AsVariant = objADOQuery_People.Fields("CL").Value
        Else
          gdcObject.FieldByName("USR$SUMSICK").AsVariant = 0
          gdcObject.FieldByName("USR$HOW").AsVariant = 0
        End If
        '
        If Not IsNull(objADOQuery_People.Fields("P20").Value) Then
          gdcObject.FieldByName("USR$SICK_PROP").AsInteger = 1
        Else
          gdcObject.FieldByName("USR$SICK_PROP").AsInteger = 0
        End If

        gdcObject.Post
      End if
      '
    Else
      If Not TNNP = objADOQuery_People.Fields("TNNP").Value Then
        tf.WriteLine("Табельный номер " & objADOQuery_People.Fields("TNNP").Value & " не найден в базе данных!")
        TNNP = objADOQuery_People.Fields("TNNP").Value
      End If
      '
    End If

    pr.StepIt
    pr.Repaint
    frm.Repaint
    frm.BringToFront

    objADOQuery_People.MoveNext
  Wend

  T2 = time

  Call Application.MessageBox("Импорт завершен", "Внимание", vbSystemModal + mb_IconInformation)
  '
  Call Application.MessageBox("Время: " & Hour(T2-T1) & " ч. " & Minute(T2-T1) & " мин. " & Second(T2-T1) & " сек.", "Внимание", vbSystemModal + mb_IconInformation)

  gdcObject.Close
  tf.Close
  OwnerForm.gdcObject.CloseOpen
end sub

