Option Explicit
'
'#include pl_GetScriptIDByName

Function wg_pu_pl(ByVal Scope, ByVal InEmplKey, ByVal DateBegin, ByVal DateEnd, _
                  ByVal EDocType, ByVal TabOption, ByVal UNPF, ByVal PhoneNum, _
                  ByRef PL)
'
  Dim T, T1, T2
  '
  Dim Creator, IsDebug, Result
  IsDebug = True
  Result = ""
  wg_pu_pl = Result
  '
  'Dim PL
  Dim Ret, Pred, Tv, PredFile, Append
  Dim ScriptName', Scope
  'pu_calc_in, pu_calc_prep
  Dim P_in, Tv_in, Q_in, P_prep, Tv_prep, Q_prep
  Dim EmplKey
  EmplKey = InEmplKey
  'Dim DateBegin, DateEnd, EDocType, TabOption, UNPF, PhoneNum
  'pu_calc_sql
  Dim P_sql, Tv_sql, Q_sql
  Dim PredicateName, Arity, SQL
  'pu_calc
  Dim P_main, Tv_main, Q_main
  'pu_calc_out
  Dim P_out, Tv_out, Q_out
  'pu_clean
  Dim P_cl, Tv_cl, Q_cl

  T1 = Timer

  'init
  Set Creator = New TCreator
  'Set PL = Creator.GetObject(nil, "TgsPLClient", "")
  'Ret = PL.Initialise("")
  'If Not Ret Then
  '  Exit Function
  'End If
  'debug
  'PL.Debug = (False And IsDebug And plGlobalDebug)
  'load
  'ScriptName = "twg_pu"
  'Ret = PL.LoadScript(pl_GetScriptIDByName(ScriptName))
  'If Not Ret Then
  '  Exit Function
  'End If
  'Scope = "wg_pu_3"
  'debug
  PL.Debug = (True And IsDebug And plGlobalDebug)

  'pu_calc_in(Scope, EmplKey, DateBegin, DateEnd, EDocType, TabOption, UNPF, PhoneNum)
  P_in = "pu_calc_in"
  Set Tv_in = Creator.GetObject(8, "TgsPLTermv", "")
  Set Q_in = Creator.GetObject(nil, "TgsPLQuery", "")
  '
  Tv_in.PutAtom 0, Scope
  Tv_in.PutInteger 1, EmplKey
  Tv_in.PutDate 2, DateBegin
  Tv_in.PutDate 3, DateEnd
  Tv_in.PutInteger 4, EDocType
  Tv_in.PutInteger 5, TabOption
  Tv_in.PutString 6, UNPF
  Tv_in.PutString 7, PhoneNum
  
  '
  Q_in.PredicateName = P_in
  Q_in.Termv = Tv_in
  '
  Q_in.OpenQuery
  If Q_in.EOF Then
    Exit Function
  End If
  Q_in.Close

  'pu_calc_prep(Scope)
  P_prep = "pu_calc_prep"
  Set Tv_prep = Creator.GetObject(1, "TgsPLTermv", "")
  Set Q_prep = Creator.GetObject(nil, "TgsPLQuery", "")
  '
  Tv_prep.PutAtom 0, Scope
  '
  Q_prep.PredicateName = P_prep
  Q_prep.Termv = Tv_prep
  '
  Q_prep.OpenQuery
  If Q_prep.EOF Then
    Exit Function
  End If
  Q_prep.Close

  'pu_calc_sql(Scope, EmplKey, PredicateName, Arity, SQL)
  P_sql = "pu_calc_sql"
  Set Tv_sql = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_sql = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_sql.PredicateName = P_sql
  Q_sql.Termv = Tv_sql

  Append = False
  '
  Tv_sql.PutAtom 0, Scope
  Tv_sql.PutInteger 1, EmplKey
  Q_sql.OpenQuery
  '
  Do Until Q_sql.EOF
    PredicateName = Tv_sql.ReadAtom(2)
    Arity = Tv_sql.ReadInteger(3)
    SQL = Tv_sql.ReadString(4)
    '
    Ret =  PL.MakePredicatesOfSQLSelect _
              (SQL, _
              gdcBaseManager.ReadTransaction, _
              PredicateName, PredicateName, Append)
    '
    Q_sql.NextSolution
  Loop
  Q_sql.Close

  'save param_list
  If PL.Debug Then
    Pred = "param_list"
    PredFile = "param_list"
    Set Tv = Designer.CreateObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, PredFile
    Tv.DestroyObject
  End If

  'pu_calc(Scope, EmplKey)
  P_main = "pu_calc"
  Set Tv_main = Creator.GetObject(2, "TgsPLTermv", "")
  Set Q_main = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_main.PredicateName = P_main
  Q_main.Termv = Tv_main
  '
  Tv_main.PutAtom 0, Scope
  Tv_main.PutInteger 1, EmplKey
  '
  Q_main.OpenQuery
  If Q_main.EOF Then
    Exit Function
  End If
  Q_main.Close

  'save param_list
  If PL.Debug Then
    Pred = "param_list"
    PredFile = "param_list"
    Set Tv = Designer.CreateObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, PredFile
    Tv.DestroyObject
  End If

  'pu_calc_out(Scope, EmplKey, Result)
  P_out = "pu_calc_out"
  Set Tv_out = Creator.GetObject(3, "TgsPLTermv", "")
  Set Q_out = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_out.PredicateName = P_out
  Q_out.Termv = Tv_out
  '
  Tv_out.PutAtom 0, Scope
  Tv_out.PutInteger 1, EmplKey
  '
  Q_out.OpenQuery
  If Q_out.EOF Then
    Exit Function
  End If

  Do Until Q_out.EOF
    Result = Result & _
             Tv_out.ReadString(2)
    '
    Q_out.NextSolution
  Loop
  Q_out.Close

  'pu_clean(Scope, EmplKey)
  P_cl = "pu_clean"
  Set Tv_cl = Creator.GetObject(2, "TgsPLTermv", "")
  Set Q_cl = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_cl.PredicateName = P_cl
  Q_cl.Termv = Tv_cl
  '
  Tv_cl.PutAtom 0, Scope
  Tv_cl.PutInteger 1, EmplKey
  '
  Q_cl.OpenQuery
  If Q_cl.EOF Then
    'Exit Function
  End If
  Q_cl.Close

  wg_pu_pl = Result

  T2 = Timer
  T = T2 - T1
'
End Function
