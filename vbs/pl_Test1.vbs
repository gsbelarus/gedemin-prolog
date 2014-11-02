Option Explicit
'#include pl_GetScriptIDByName

Sub pl_Test1()
'
  Dim T, T1, T2
  '
  Dim Creator, IsDebug
  IsDebug = True
  '
  Dim PL, Ret, Pred, Tv, Q
  Dim PredFile, Append
  Dim ScriptName
  Dim PredicateName, SQL
  Dim GroupBy, TotalDebit, TotalCredit

  'init
  Set Creator = New TCreator
  Set PL = Creator.GetObject(nil, "TgsPLClient", "")
  Ret = PL.Initialise("")
  If Not Ret Then
    Exit Sub
  End If
  'debug
  PL.Debug = (False And IsDebug And plGlobalDebug)
  'load
  ScriptName = "swi_test1"
  Ret = PL.LoadScript(pl_GetScriptIDByName(ScriptName))
  If Not Ret Then
    Exit Sub
  End If
  'debug
  PL.Debug = (False And IsDebug And plGlobalDebug)

  SQL = _
"SELECT " & _
"  tch.ID, " & _
"  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS TotalYear, " & _
"  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS TotalMonth, " & _
"  tch.USR$FEETYPEKEY, " & _
"  tch.USR$EMPLKEY, " & _
"  tch.USR$DEBIT, " & _
"  tch.USR$CREDIT " & _
"FROM " & _
"  USR$WG_TBLCHARGE tch " & _
"JOIN " & _
"  USR$WG_TOTAL t " & _
"    ON t.DOCUMENTKEY = tch.USR$TOTALDOCKEY " & _
"WHERE " & _
"  t.USR$DATEBEGIN >= '2014-07-01' " & _
"  AND " & _
"  t.USR$DATEBEGIN < '2014-10-01' "

  Append = False
  PredicateName = "tch"
  '
  T1 = Timer
  '
  Ret =  PL.MakePredicatesOfSQLSelect _
           (SQL, _
           gdcBaseManager.ReadTransaction, _
           PredicateName, PredicateName, Append)
  '
  T2 = Timer
  T = T2 - T1
  
  Pred = "test11"
  Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
  Set Q = Creator.GetObject(nil, "TgsPLQuery", "")
  Q.PredicateName = Pred
  Q.Termv = Tv
  '
  T1 = Timer
  '
  Q.OpenQuery
  If Q.EOF Then
    Exit Sub
  End If
  '
  GroupBy = Tv.ToString(0)
  TotalDebit = Tv.ReadFloat(1)
  TotalCredit = Tv.ReadFloat(2)
  Q.Close
  '
  T2 = Timer
  T = T2 - T1
  
  'debug
  PL.Debug = (True And IsDebug And plGlobalDebug)
  'save
  If PL.Debug Then
    PredFile = Pred
    PL.SavePredicatesToFile Pred, Tv, PredFile
  End If

'
End Sub
