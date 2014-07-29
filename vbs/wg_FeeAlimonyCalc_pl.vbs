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
  Dim SQLUpdate
  'fee_calc
  Dim P_main, Tv_main, Q_main
  'fee_calc_out, fee_calc_charge
  Dim P_out, Tv_out, Q_out, P_charge, Tv_charge, Q_charge
  Dim Result, ChargeSum, FeeTypeKey, DocKey, AccountKeyIndex
  'fee_calc_debt
  Dim P_debt, Tv_debt, Q_debt
  Dim AlimonyKey, DebtSum
  Dim gdcAlimonyDebt

  T1 = Timer

  Result = 0
  wg_FeeAlimonyCalc_pl = Result
    
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
  '
  Tv_run.PutAtom 0, Scope
  '
  Q_run.OpenQuery
  If Q_run.EOF Then
    Exit Function
  End If

  'fee_calc_sql(Scope, EmplKey, PredicateName, Arity, SQL)
  P_sql = "fee_calc_sql"
  Set Tv_sql = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_sql = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_sql.PredicateName = P_sql
  Q_sql.Termv = Tv_sql
  'fee_calc_cmd(Scope, EmplKey, PredicateName, Arity, SQL)
  P_cmd = "fee_calc_cmd"
  Set Tv_cmd = Creator.GetObject(5, "TgsPLTermv", "")
  Set Q_cmd = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_cmd.PredicateName = P_cmd
  Q_cmd.Termv = Tv_cmd
  '
  Set SQLUpdate = Creator.GetObject(nil, "TIBSQL", "")
  Set SQLUpdate.Transaction = wg_EmployeeCharge.Transaction

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
    Tv_cmd.Reset
    Tv_cmd.PutAtom 0, Scope
    Tv_cmd.PutInteger 1, EmplKey
    Q_cmd.OpenQuery
    '
    Do Until Q_cmd.EOF
      PredicateName = Tv_cmd.ReadAtom(2)
      Arity = Tv_cmd.ReadInteger(3)
      SQL = Tv_cmd.ReadString(4)
      '
      SQLUpdate.SQL.Text = SQL
      SQLUpdate.ExecQuery
      SQLUpdate.Close
      '
      Q_cmd.NextSolution
    Loop
    Q_cmd.Close
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

  'fee_calc_out(Scope, EmplKey, Result)
  P_out = "fee_calc_out"
  Set Tv_out = Creator.GetObject(3, "TgsPLTermv", "")
  Set Q_out = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_out.PredicateName = P_out
  Q_out.Termv = Tv_out
  '
  Tv_out.PutAtom 0, Scope
  '
  Q_out.OpenQuery
  If Q_out.EOF Then
    Exit Function
  End If

  'fee_calc_charge(Scope, EmplKey, ChargeSum, FeeTypeKey, DocKey, AccountKeyIndex)
  P_charge = "fee_calc_charge"
  Set Tv_charge = Creator.GetObject(6, "TgsPLTermv", "")
  Set Q_charge = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_charge.PredicateName = P_charge
  Q_charge.Termv = Tv_charge

  'fee_calc_debt(Scope, EmplKey, AlimonyKey, DebtSum)
  P_debt = "fee_calc_debt"
  Set Tv_debt = Creator.GetObject(4, "TgsPLTermv", "")
  Set Q_debt = Creator.GetObject(nil, "TgsPLQuery", "")
  Q_debt.PredicateName = P_debt
  Q_debt.Termv = Tv_debt
  'Журнал долгов по алиментам
  Set gdcAlimonyDebt = Creator.GetObject(nil, "TgdcUserDocument", "")
  gdcAlimonyDebt.SubType = "147072391_453357870"
  gdcAlimonyDebt.Transaction = wg_EmployeeCharge.Transaction
  gdcAlimonyDebt.Open
    
  Do Until Q_out.EOF
    EmplKey = Tv_out.ReadInteger(1)
    Result = Tv_out.ReadFloat(2)
    '
    Tv_charge.Reset
    Tv_charge.PutAtom 0, Scope
    Tv_charge.PutInteger 1, EmplKey
    Q_charge.OpenQuery
    '
    Do Until Q_charge.EOF
      ChargeSum = Tv_charge.ReadFloat(2)
      FeeTypeKey = Tv_charge.ReadInteger(3)
      DocKey = Tv_charge.ReadInteger(4)
      AccountKeyIndex = Tv_charge.ReadInteger(5)
      '
      Call wg_EmployeeCharge.AddCharge(0, ChargeSum, Null, TotalDocKey, FeeTypeKey, _
          DocKey, wg_EmployeeCharge.BeginDate, 0, 0)
      Call wg_EmployeeCharge.AddChargeRegNew(0, ChargeSum, TotalDocKey, FeeTypeKey, _
          AccountKeyArr(AccountKeyIndex), wg_EmployeeCharge.BeginDate, DocKey)
      '
      Q_charge.NextSolution
    Loop
    Q_charge.Close
    '
    Tv_debt.Reset
    Tv_debt.PutAtom 0, Scope
    Tv_debt.PutInteger 1, EmplKey
    Q_debt.OpenQuery
    '
    Do Until Q_debt.EOF
      AlimonyKey = Tv_debt.ReadInteger(2)
      DebtSum = Tv_debt.ReadFloat(3)
      '
      gdcAlimonyDebt.Insert
      gdcAlimonyDebt.FieldByName("usr$totaldockey").AsInteger = TotalDocKey
      gdcAlimonyDebt.FieldByName("usr$alimonykey").AsInteger = AlimonyKey
      gdcAlimonyDebt.FieldByName("usr$debtsum").AsCurrency = DebtSum
      gdcAlimonyDebt.FieldByName("usr$debtmonth").AsInteger = 0
      gdcAlimonyDebt.Post
      '
      Q_debt.NextSolution
    Loop
    Q_debt.Close
    '
    Q_out.NextSolution
  Loop
  Q_out.Close

  gdcAlimonyDebt.Close

  'save param_list
  If PL.Debug Then
    Pred = "param_list"
    PredFile = "param_list"
    Set Tv = Creator.GetObject(3, "TgsPLTermv", "")
    PL.SavePredicatesToFile Pred, Tv, PredFile
  End If

  wg_FeeAlimonyCalc_pl = Result

  T2 = Timer
  T = T2 - T1
'
End Function
