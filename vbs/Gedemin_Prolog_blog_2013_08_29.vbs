Option Explicit

'subject close to the
'http://gedemin.blogspot.com/2013/08/embedded-swi-prolog.html

Sub Gedemin_Prolog_blog_2013_08_29()
  Dim Creator, PL, Termv, Ret
  Dim SQL_contact, SQL_place
  Dim Pred, City, CDS, I
  
  SQL_contact = _
      "SELECT ID, PlaceKey, Name FROM gd_contact"
  SQL_place = _
      "SELECT ID, Name FROM gd_place"
  Pred = _
      "bycity(City, Name) :- " + _
      "  gd_place(CityID, City), " + _
      "  gd_contact(_, CityID, Name). "
      
  Set Creator = New TCreator

  Set PL = Creator.GetObject(nil, "TgsPLClient", "")
  Ret = PL.Initialise("")
  If Not Ret Then Exit Sub
  
  Call PL.MakePredicatesOfSQLSelect( _
       SQL_contact, _
       gdcBaseManager.ReadTransaction, _
       "gd_contact", "contact")

  Call PL.MakePredicatesOfSQLSelect( _
       SQL_place, _
       gdcBaseManager.ReadTransaction, _
       "gd_place", "place")

  Set Termv = Creator.GetObject(2, "TgsPLTermv", "")
  Termv.PutString 0, "pred"
  Termv.PutString 1, Pred
  Ret = PL.Call("load_atom", Termv)
  If Not Ret Then Exit Sub

  City = InputBox("Введите город", "Место", "Минск")
  Termv.Reset
  Termv.PutString 0, City
  Ret = PL.Call("bycity", Termv)
  If Not Ret Then Exit Sub

  Ret = Termv.ReadString(1)
  MsgBox Ret, , "Call: Первый контакт"
  
  Set CDS = Creator.GetObject(nil, "TClientDataset", "")
  CDS.FieldDefs.Add "City", ftString, 60, True
  CDS.FieldDefs.Add "Name", ftString, 60, True
  CDS.CreateDataSet
  CDS.Open

  Termv.Reset
  Termv.PutString 0, City
  PL.ExtractData CDS, "bycity", Termv
  If CDS.RecordCount = 0 Then Exit Sub
  
  Ret = "" : I = 0
  CDS.First
  Do Until CDS.Eof Or I = 10
     Ret = Ret + CDS.FieldByName("Name").AsString + VBCrLf
     I = I + 1
     CDS.Next
  Loop
  MsgBox Ret, , "MakePredicatesOfSQLSelect: Первые 10 контактов"

  I = 0
  CDS.First
  Do Until CDS.Eof Or I = 5
     CDS.Delete
     I = I + 1
  Loop

  Call PL.MakePredicatesOfDataSet( _
       CDS, _
       "City,Name", _
       "gd_bycity", "bycity")

  Ret = PL.Call2("dynamic(gd_bycity/2)")
  Termv.Reset
  Ret = PL.Call("gd_bycity", Termv)
  
  If Ret Then
    Ret = Termv.ReadString(1) + " (" + Termv.ReadString(0) + ")"
  Else
    Ret = "Было найдено меньше 6 контактов"
  End If
  MsgBox Ret, , "MakePredicatesOfDataSet: Контакт 6"

  Call PL.MakePredicatesOfObject( _
       "TgdcCurr", "", "ByID", Array(200010, 200020), nil, _
       "ID,Name", _
       gdcBaseManager.ReadTransaction, _
       "gd_curr", "curr")

  Termv.Reset
  Termv.PutInteger 0, 200020
  Ret = PL.Call("gd_curr", Termv)
  If Not Ret Then Exit Sub
  
  Ret = CStr(Termv.ReadInteger(0)) + ": " + Termv.ReadString(1)
  MsgBox Ret, , "MakePredicatesOfObject: Валюта"
End Sub

