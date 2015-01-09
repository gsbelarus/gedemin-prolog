'#include wg_GetAlimonySum
'#include wg_CalcTransferSum
'#include wg_RoundSum
'#include wg_EmplMoveList
'#include wg_GetAccountKey
'<pl>
'#include wg_FeeAlimonyCalc_pl
'</pl>
function wg_FeeFineCalc(ByRef wg_EmployeeCharge, ByVal TotalDocKey, ByVal FeeTypeKey, ByRef obj_FeeData)
'Расчет штрафов и расходов на их пересылку
  wg_FeeFineCalc = 0

  Dim wg_FeeType_TransferDed_ID, wg_FeeType_AlimonyDebt_ID
  Dim AccountKey, AccountKeyDebt, AccountKeyTransf

  wg_FeeType_TransferDed_ID = gdcBaseManager.GetIDByRUIDString(wg_FeeType_TransferDed_RUID)
  wg_FeeType_AlimonyDebt_ID = gdcBaseManager.GetIDByRUIDString("147049310_1011422021")

  AccountKey = wg_GetAccountKey(FeeTypeKey, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.EndDate)
  AccountKeyDebt = wg_GetAccountKey(wg_FeeType_AlimonyDebt_ID, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.EndDate)
  AccountKeyTransf = wg_GetAccountKey(wg_FeeType_TransferDed_ID, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.EndDate)

  '<pl>
  Dim AccountKeyArr
  '
  AccountKeyArr = Array(AccountKey, AccountKeyDebt, AccountKeyTransf)

  Dim frmAlimony, dlgAlimony
  Dim Prolog_Alimony
  Dim Scope
  Scope = "wg_fee_fine"
  '
  Set frmAlimony = _
    Application.FindComponent("gdc_frmUserComplexDocument147567052_119619099")
    '
  If Assigned(frmAlimony) Then
    Set dlgAlimony = _
      Application.FindComponent("gdc_dlgUserSimpleDocument147050774_1011422021")
  End If
  '
  If Assigned(dlgAlimony) Then
    Set Prolog_Alimony = dlgAlimony.FindComponent("usrg_Prolog_Alimony")
    If Assigned(Prolog_Alimony) Then
      If Prolog_Alimony.Checked = True Then
        'Расчет через Пролог-скрипт
        wg_FeeFineCalc = _
          wg_FeeAlimonyCalc_pl(wg_EmployeeCharge, TotalDocKey, FeeTypeKey, AccountKeyArr, Scope)
        Exit Function
      End If
    End If
  Else
    'Расчет через Пролог-скрипт
    wg_FeeFineCalc = _
      wg_FeeAlimonyCalc_pl(wg_EmployeeCharge, TotalDocKey, FeeTypeKey, AccountKeyArr, Scope)
    Exit Function
  End If
  '</pl>

  dim Creator
  set Creator = New TCreator

  set MoveCard = wg_EmplMoveList.MoveCardList(wg_EmployeeCharge.EmployeeKey, null)._
    MoveCardByDate(wg_EmployeeCharge.EndDate)
    
  if Assigned(MoveCard) then
    wg_FeeType_TransferDed_ID = gdcBaseManager.GetIDByRUIDString(wg_FeeType_TransferDed_RUID)

    set wg_Alimony = New Twg_Alimony

    wg_EmployeeCharge.FirstMoveKey = MoveCard.FirstMoveKey
    'Класс для расчета формул
    set wg_FoCal = New Twg_FoCal
    set wg_FoCal.ReadTransaction = wg_EmployeeCharge.ReadTransaction
    wg_FoCal.EmplKey   = wg_EmployeeCharge.Employeekey
    wg_FoCal.DateBegin = wg_EmployeeCharge.BeginDate
    wg_FoCal.DateEnd   = wg_EmployeeCharge.EndDate

    set IBSQL = Creator.GetObject(nil, "TIBSQL", "")
    IBSQL.Transaction = wg_EmployeeCharge.ReadTransaction
    'Выбираем документы о назначении штрафа
    IBSQL.SQL.Text = " SELECT calc.* " & _
      " FROM GD_DOCUMENT d " & _
      " LEFT JOIN usr$wg_alimony calc ON calc.DOCUMENTKEY = d.ID " & _
      " WHERE d.DOCUMENTTYPEKEY = :doctype AND " & _
      "   calc.usr$emplkey = :emplkey AND " & _
      "   calc.usr$datebegin <= :dateend AND " & _
      "   (calc.usr$dateend >= :datebegin or calc.usr$dateend is NULL) " & _
      " ORDER BY calc.usr$datebegin "
    IBSQL.ParamByName("DateBegin").AsDateTime = wg_EmployeeCharge.BeginDate
    IBSQL.ParamByName("DateEnd").AsDateTime =  wg_EmployeeCharge.EndDate
    IBSQL.ParamByName("emplkey").AsInteger = wg_EmployeeCharge.Employeekey
    IBSQL.ParamByName("doctype").AsInteger = gdcBaseManager.GetIdByRuidString("147050774_1011422021")
    IBSQL.ExecQuery

    'Оставшееся деньги
    RestSum = wg_EmployeeCharge.Debit - wg_EmployeeCharge.Credit + wg_EmployeeCharge.PayedOut

   'Добавление алиментов в объект класса wg_Alimony
    FineReservAll = 0
    while not IBSQL.Eof

        Sum = wg_GetAlimonySum(wg_FoCal, IBSQL.FieldByName("usr$formula").AsString, _
              IBSQL.FieldByName("usr$datebegin").AsDateTime, wg_EmployeeCharge.BeginDate)
       'Округление
        Sum = wg_RoundSum(FeeTypeKey, Sum)
        'Суммы для резерва денег по штрафам и суммы для их перевода
        if not IBSQL.FieldByName("usr$transfertypekey").isNull then
          ReservTransferSum = wg_RoundSum(wg_FeeType_TransferDed_ID, Sum * _
            wg_TransferDed.Types(IBSQL.FieldByName("usr$transfertypekey").AsInteger).GetPercent(wg_EmployeeCharge.EndDate, Sum) / 100)
        else
          ReservTransferSum = 0
        end if
        'Если резервировать некуда, то ...
        if FineReservAll + Sum + ReservTransferSum > RestSum then
          SumTmp = RestSum - FineReservAll            'Резервируем все деньги, которые остаются
        else
          SumTmp = Sum + ReservTransferSum
        end if
        if SumTmp < 0 then
          SumTmp = 0
        end if
        'Добавление данных в экземпляр класса  ?
        call wg_Alimony.Add(IBSQL.FieldByName("documentkey").AsInteger, Sum, _
                       IBSQL.FieldByName("usr$restpercent").AsCurrency, _
                       IBSQL.FieldByName("usr$transfertypekey").Value, SumTmp)
                       'Sum + ReservTransferSum)
        FineReservAll =  FineReservAll + SumTmp
        'Sum + ReservTransferSum
      'end if
      IBSQL.Next
    wend
    IBSQL.Close

    FineDebtAllSum = 0
    FineAllSum = 0
    TransferAllSum = 0
    OverReservedSum = 0
    
    'dim AccountKey, AccountKeyTransf
    'AccountKey = wg_GetAccountKey(FeeTypeKey, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.EndDate)
    'AccountKeyTransf = wg_GetAccountKey(wg_FeeType_TransferDed_ID, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.BeginDate)

    
'    set gdcAlimonyDebt = Nothing
   'Цикл по штрафам
    for i = 0 to wg_Alimony.Count - 1
    'Определим сумму за перевод и сумму, которую может выплатить сотрудник (с учетом расходов за перевод)
      'Процент остатка. Т.е. процент, который нужно оставить сотруднику
      RestPercentSum = wg_Alimony.Item(i).RestPercent * _
                      (wg_EmployeeCharge.Debit - wg_EmployeeCharge.Credit + wg_EmployeeCharge.PayedOut) / 100

      'Сумма для резерва сумм других выплат. Т.е. сначала нужно выплатить деньги по , а потом по их долгам
      'Из общей резервной суммы нужно исключить текущие штрафы и те, которые уже расчитали
      FineReservAll = FineReservAll - wg_Alimony.Item(i).ReservedSum

'      if AlimonyReservedSum > RestSum then
'      end if
      OutArray = wg_CalcTransferSum(wg_Alimony.Item(i).MustPaySum, wg_Alimony.Item(i).TransferTypeKey, _
        wg_EmployeeCharge.BeginDate, RestSum - RestPercentSum - FineReservAll)
      CanPaySum = OutArray(0)
      TransferSum = OutArray(1)
      'Занести сумму за пересылку штрафов в начисления по табелю
      if TransferSum > 0 then
        call wg_EmployeeCharge.AddCharge(0, TransferSum, Null, TotalDocKey, wg_FeeType_TransferDed_ID,_
             wg_Alimony.Item(i).ID, wg_EmployeeCharge.BeginDate, 0, 0)
             
        call wg_EmployeeCharge.AddChargeRegNew(0, TransferSum, TotalDocKey, _
             wg_FeeType_TransferDed_ID, AccountKeyTransf, Null, wg_Alimony.Item(i).ID)

      end if

   ''   'Определение по каким документам возможны выплаты

      if wg_Alimony.Item(i).Sum > CanPaySum then

        FineSum = CanPaySum
      else
        FineSum = wg_Alimony.Item(i).Sum
      end if
      'Занести сумму выплаченных алиментов в начисления по табелю
      if FineSum > 0 then
        call wg_EmployeeCharge.AddCharge(0, FineSum, Null, TotalDocKey, FeeTypeKey,_
          wg_Alimony.Item(i).ID, wg_EmployeeCharge.BeginDate, 0, 0)
        call wg_EmployeeCharge.AddChargeRegNew(0, FineSum, TotalDocKey, _
             FeeTypeKey, AccountKey, Null, wg_Alimony.Item(i).ID)
      end if

     'Гашение долгов в суммах
      TmpSum = CanPaySum - FineSum

      FineAllSum = FineAllSum + FineSum
      TransferAllSum = TransferAllSum + TransferSum
      RestSum = RestSum - FineSum  - TransferSum
    next

'  'Добавление сумм в журнал начислений
'    'штрафы
'    if FineAllSum > 0 then
'      AccountKey = wg_GetAccountKey(FeeTypeKey, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.EndDate)
'      call wg_EmployeeCharge.AddChargeReg(0, FineAllSum, TotalDocKey, FeeTypeKey, AccountKey, Null)
'    end if
'
'    'За почтовый перевод
'    if TransferAllSum <> 0 then
'      AccountKey = wg_GetAccountKey(wg_FeeType_TransferDed_ID, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.BeginDate)
'      call wg_EmployeeCharge.AddChargeReg(0, TransferAllSum, TotalDocKey, wg_FeeType_TransferDed_ID, AccountKey, Null)
'    end if

    wg_FeeFineCalc = FineAllSum + TransferAllSum
    wg_EmployeeCharge.FirstMoveKey = Null
  end if
end function


