Option Explicit
'#include pl_GetScriptIDByName

Function pl_Family()
'
  Dim Creator, PL, Ret
  Dim Pred, Tv, Q
  '
  Dim SQL_family, SQL_people, SQL_relationship
  
  pl_Family = False
  Set Creator = New TCreator
  
  SQL_family = _
    "SELECT " & _
    "    F.ID, F.USR$FULLNAME, F.USR$EMPLKEY, F.USR$RELATIONSHIP, F.USR$DATEOFBIRTH" & _
    "  FROM " & _
    "    USR$WG_FAMILY F"
  '
  SQL_people = _
    "SELECT DISTINCT" & _
    "    F.USR$EMPLKEY, C.NAME, P.SEX" & _
    "  FROM" & _
    "    USR$WG_FAMILY F" & _
    "  JOIN GD_PEOPLE P ON P.CONTACTKEY = F.USR$EMPLKEY" & _
    "  JOIN GD_CONTACT C ON C.ID = F.USR$EMPLKEY"
  '
  SQL_relationship = _
    "SELECT " & _
    "    R.ID, R.USR$NAME" & _
    "  FROM " & _
    "    USR$WG_RELATIONSHIP R"

  'init
  Set PL = Creator.GetObject(nil, "TgsPLClient", "")
  Ret = PL.Initialise("")
  If Not Ret Then
    Exit Function
  End If
  'debug
  PL.Debug = true
  'load
  Ret = PL.LoadScript(pl_GetScriptIDByName("family"))
  If Not Ret Then
    Exit Function
  End If

  Ret = PL.MakePredicatesOfSQLSelect _
          (SQL_family, _
          gdcBaseManager.ReadTransaction, _
          "gd_family", "gd_family", False)
  '
    Ret = PL.MakePredicatesOfSQLSelect _
          (SQL_people, _
          gdcBaseManager.ReadTransaction, _
          "gd_people", "gd_people", False)
  '
    Ret = PL.MakePredicatesOfSQLSelect _
          (SQL_relationship, _
          gdcBaseManager.ReadTransaction, _
          "gd_relationship", "gd_relationship", False)

  pl_Family = True
'
End function
