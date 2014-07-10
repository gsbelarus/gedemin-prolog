Option Explicit
'#include wg_WageSettings
'
'#include pl_GetScriptIDByName

Function wg_FeeAlimonyCalc_pl(ByRef wg_EmployeeCharge, ByVal TotalDocKey, ByVal AccountKeyArr)
'
  Dim T, T1, T2
  '
  Dim Creator
  '
  Dim PL, Ret, Pred, Tv, PredFile, Append
  Dim ScriptName, Scope
  'fee_calc_in, fee_calc_prep
  Dim P_in, Tv_in, Q_in, P_prep, Tv_prep, Q_prep
  Dim EmplKey, DateBegin, RoundType, RoundValue
  'fee_calc_run
  Dim P_run, Tv_run, Q_run
  'fee_calc_sql, fee_calc_cmd
  Dim P_sql, Tv_sql, Q_sql, P_cmd, Tv_cmd, Q_cmd
  Dim PredicateName, Arity, SQL
  'fee_calc
  Dim P_main, Tv_main, Q_main
  'fee_calc_out, fee_calc_charge
  Dim P_out, Tv_out, Q_out, P_charge, Tv_charge, Q_charge
  Dim Result, ChargeSum, FeeTypeKey, DocKey, AccountKeyIndex
  'fee_calc_debt
  Dim P_debt, Tv_debt, Q_debt
  Dim AlimonyKey, DebtSum

  T1 = Timer
  wg_FeeAlimonyCalc_pl = 0
    
  'init
  Set Creator = New TCreator
  Set PL = Creator.GetObject(nil, "TgsPLClient", "")
  Ret = PL.Initialise("")
  If Not Ret Then
    Exit Function
  End If
  'debug
  PL.Debug = False
  'load
  ScriptName = "twg_fee"
  Ret = PL.LoadScript(pl_GetScriptIDByName(ScriptName))
  If Not Ret Then
    Exit Function
  End If
  Scope = "wg_fee_alimony"
  'debug
  PL.Debug = True

  'params
  EmplKey = wg_EmployeeCharge.EmployeeKey
  DateBegin = wg_EmployeeCharge.BeginDate
  '
  RoundType = wg_WageSettings.Wage.RoundType
  RoundValue = wg_WageSettings.Wage.RoundValue

  'fee_calc_in(Scope, EmplKey, DateBegin, TotalDocKey, FeeTypeKey, RoundType, RoundValue)
  P_in = "fee_calc_in"
  Set Tv_in = Creator.GetObject(7, "TgsPLTermv", "")
  Set Q_in = Creator.GetObject(nil, "TgsPLQuery", "")
  '
  Tv_in.PutAtom 0, Scope
  Tv_in.PutInteger 1, EmplKey
  Tv_in.PutDate 2, DateBegin
  Tv_in.PutInteger 3, TotalDocKey
  Tv_in.PutInteger 4, FeeTypeKey
  Tv_in.PutInteger 5, RoundType
  Tv_in.PutFloat 6, RoundValue
  '
  Q_in.PredicateName = P_in
  Q_in.Termv = Tv_in
  '
  Q_in.OpenQuery
  If Q_in.EOF Then
    Exit Function
  End If
  Q_in.Close

  'fee_calc_prep(Scope)
  P_prep = "fee_calc_prep"
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

  'save param_list
  If PL.Debug Then
    Pred = "param_list"
    PredFile = "param_list"
    Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, PredFile
  End If

  'fee_calc_run(Scope, EmplKey)
  P_run = "fee_calc_run"
  Set Tv_run = Creator.GetObject(2, "TgsPLTermv", "")
  Set Q_run = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_run.PredicateName = P_run
  Q_run.Termv = Tv_run
  'fee_calc_sql(Scope, EmplKey, PredicateName, Arity, SQL)
  P_sql = "fee_calc_sql"
  Set Tv_sql = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_sql = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_sql.PredicateName = P_sql
  Q_sql.Termv = Tv_sql
  '
  Tv_run.PutAtom 0, Scope
  '
  Q_run.OpenQuery
  If Q_run.EOF Then
    Exit Function
  End If
  '
  Append = False
  '
  Do Until Q_run.EOF
    EmplKey = Tv_run.ReadInteger(1)
    '
    Tv_sql.Reset
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
    '
    Append = True
    '
    Q_run.NextSolution
  Loop
  Q_run.Close

  'save param_list
  If PL.Debug Then
    Pred = "param_list"
    PredFile = "param_list"
    Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, PredFile
  End If

  'fee_calc(Scope)
  P_main = "fee_calc"
  Set Tv_main = Creator.GetObject(1, "TgsPLTermv", "")
  Set Q_main = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_main.PredicateName = P_main
  Q_main.Termv = Tv_main
  '
  Tv_main.PutAtom 0, Scope
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
    Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, PredFile
  End If

  '  todo:

  'fee_calc_out(Scope, EmplKey, Result)
  
  '  wg_FeeAlimonyCalc_pl = Result

  'fee_calc_charge(Scope, EmplKey, ChargeSum, FeeTypeKey, DocKey, AccountKeyIndex)
  
  'fee_calc_debt(Scope, EmplKey, AlimonyKey, DebtSum)


  'save param_list
  If PL.Debug Then
    Pred = "param_list"
    PredFile = "param_list"
    Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, PredFile
  End If

  T2 = Timer
  T = T2 - T1
'
End Function
