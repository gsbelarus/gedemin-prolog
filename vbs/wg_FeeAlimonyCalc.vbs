'#include wg_MonthHour
'#include wg_GetAlimonySum
'#include wg_CalcTransferSum
'#include wg_RoundSum
'#include wg_EmplMoveList
'#include wg_TblCal
'#include wg_WageSettings
'#include wg_GetAccountKey
'<pl>
'#include wg_FeeAlimonyCalc_pl
'</pl>
function wg_FeeAlimonyCalc(ByRef wg_EmployeeCharge, ByVal TotalDocKey, ByVal FeeTypeKey, ByRef obj_FeeData)
'Расчет алиментов, долга по алиментам и расходов на их пересылку
  wg_FeeAlimonyCalc = 0

  Dim wg_FeeType_TransferDed_ID, wg_FeeType_AlimonyDebt_ID
  Dim AccountKey, AccountKeyDebt, AccountKeyTransf

  wg_FeeType_TransferDed_ID = gdcBaseManager.GetIDByRUIDString(wg_FeeType_TransferDed_RUID)
  wg_FeeType_AlimonyDebt_ID = gdcBaseManager.GetIDByRUIDString(wg_FeeType_AlimonyDebt_RUID)

  AccountKey = wg_GetAccountKey(FeeTypeKey, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.EndDate)
  AccountKeyDebt = wg_GetAccountKey(wg_FeeType_AlimonyDebt_ID, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.BeginDate)
  AccountKeyTransf = wg_GetAccountKey(wg_FeeType_TransferDed_ID, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.BeginDate)

  '<pl>
  Dim AccountKeyArr
  '
  AccountKeyArr = Array(AccountKey, AccountKeyDebt, AccountKeyTransf)

  Dim frmAlimony, dlgAlimony
  Dim Prolog_Alimony
  '
  Set frmAlimony = _
    Application.FindComponent("gdc_frmUserComplexDocument147567052_119619099")
  '
  If Assigned(frmAlimony) Then
    Set dlgAlimony = _
      frmAlimony.FindComponent("gdc_dlgUserComplexDocument147567052_119619099")
  End If
  '
  If Assigned(dlgAlimony) Then
    Set Prolog_Alimony = dlgAlimony.FindComponent("usrg_Prolog_Alimony")
    If Assigned(Prolog_Alimony) Then
      If Prolog_Alimony.Checked = True Then
        'Расчет через Пролог-скрипт
        wg_FeeAlimonyCalc = _
          wg_FeeAlimonyCalc_pl(wg_EmployeeCharge, TotalDocKey, FeeTypeKey, AccountKeyArr)
        Exit Function
      End If
    End If
  Else
    'Расчет через Пролог-скрипт
    wg_FeeAlimonyCalc = _
      wg_FeeAlimonyCalc_pl(wg_EmployeeCharge, TotalDocKey, FeeTypeKey, AccountKeyArr)
  End If
  '</pl>

'Удаление результатов прошлого расчета
  set Creator = New TCreator
  set SQLUpdate = Creator.GetObject(nil, "TIBSQL", "")
  set SQLUpdate.Transaction = wg_EmployeeCharge.Transaction
  'Удаление результатов прошлого расчета из журнала долга
  SQLUpdate.SQL.Text = "DELETE " & _
    "FROM usr$wg_alimonydebt aldebt " & _
    "WHERE " & _
    "    usr$totaldockey = :totaldockey " & _
    "  AND aldebt.usr$alimonykey IN " & _
    " (SELECT al.documentkey " & _
    "  FROM usr$wg_alimony al " & _
    "  WHERE al.usr$emplkey = :emplkey) "

  SQLUpdate.ParamByName("totaldockey").AsInteger = TotalDocKey
  SQLUpdate.ParamByName("emplkey").AsInteger = wg_EmployeeCharge.EmployeeKey
  SQLUpdate.ExecQuery
  SQLUpdate.Close
  'Удаление результатов прошлого расчета из журнала погашенных месяцев
  SQLUpdate.SQL.Text = "DELETE " & _
    "FROM usr$wg_alimonypayedmonth " & _
    "WHERE " & _
    "  usr$totaldockey = :totaldockey " & _
    "  AND usr$alimonydebtkey IN ( " & _
    "    SELECT aldebt.documentkey " & _
    "    FROM usr$wg_alimonydebt aldebt " & _
    "      JOIN usr$wg_alimony al ON aldebt.usr$alimonykey = al.documentkey AND al.usr$emplkey = :emplkey) "

  SQLUpdate.ParamByName("totaldockey").AsInteger = TotalDocKey
  SQLUpdate.ParamByName("emplkey").AsInteger = wg_EmployeeCharge.EmployeeKey
  SQLUpdate.ExecQuery
  SQLUpdate.Close

  set MoveCard = wg_EmplMoveList.MoveCardList(wg_EmployeeCharge.EmployeeKey, null)._
    MoveCardByDate(wg_EmployeeCharge.EndDate)
  if Assigned(MoveCard) then

    'Журнал долгов по алиментам
    Set gdcAlimonyDebt = Creator.GetObject(nil, "TgdcUserDocument", "")
    gdcAlimonyDebt.SubType = "147072391_453357870"
    gdcAlimonyDebt.Transaction = wg_EmployeeCharge.Transaction
    gdcAlimonyDebt.Open

    'Определим кол-во отработанных часов (для определения текущего долга по алиментам в месяцах)
    if wg_WageSettings.Wage.Alimonymonthdebt then
'      set Tbl = wg_TblCal.EmplTblCal(wg_EmployeeCharge.Employeekey, MoveCard.FirstMoveKey)
'      AddDebtMontFlg = (Tbl.WorkDuration = 0)
      AddDebtMontFlg = False
    else
      AddDebtMontFlg = False
    end if

    'Класс для работы с алиментами
    set wg_Alimony = New Twg_Alimony

    wg_EmployeeCharge.FirstMoveKey = MoveCard.FirstMoveKey
    'Класс для расчета формул
    set wg_FoCal = New Twg_FoCal
    set wg_FoCal.ReadTransaction = wg_EmployeeCharge.ReadTransaction
    wg_FoCal.EmplKey   = wg_EmployeeCharge.Employeekey
    wg_FoCal.DateBegin = wg_EmployeeCharge.BeginDate
    wg_FoCal.DateEnd   = wg_EmployeeCharge.EndDate
    'Запрос для добавления погашенных месяцев в отдельный журнал
    SQLUpdate.SQL.Text = " INSERT INTO usr$wg_alimonypayedmonth " & _
      " (usr$totaldockey, usr$alimonydebtkey, usr$payedmonth) " & _
      " VALUES (:totaldockey, :alimonydebtkey, :payedmonth) "

    set IBSQL = Creator.GetObject(nil, "TIBSQL", "")
    IBSQL.Transaction = wg_EmployeeCharge.ReadTransaction
    'Выбираем документы о назначении алиментов
    IBSQL.SQL.Text = " SELECT calc.* " & _
      " FROM usr$wg_alimony calc " & _
      " LEFT JOIN GD_DOCUMENT d ON calc.DOCUMENTKEY = d.ID " & _
      " WHERE d.COMPANYKEY = <COMPANYKEY/> AND " & _
      "   calc.usr$emplkey = :emplkey AND " & _
      "   calc.usr$datebegin <= :dateend AND " & _
      "   (calc.usr$dateend >= :datebegin or calc.usr$dateend is NULL) " & _
      "   AND d.documenttypekey = :doctype " & _
      " ORDER BY calc.usr$datebegin "
    IBSQL.ParamByName("DateBegin").AsDateTime = wg_EmployeeCharge.BeginDate
    IBSQL.ParamByName("DateEnd").AsDateTime =  wg_EmployeeCharge.EndDate
    IBSQL.ParamByName("emplkey").AsInteger = wg_EmployeeCharge.Employeekey
    IBSQL.ParamByName("doctype").AsInteger = gdcBaseManager.GetIdByRuidString("147067079_453357870")
    IBSQL.ExecQuery

    'Оставшееся деньги
    RestSum = wg_EmployeeCharge.Debit - wg_EmployeeCharge.Credit + wg_EmployeeCharge.PayedOut

   'Добавление алиментов в объект класса wg_Alimony
    AlimonyReservAll = 0
    while not IBSQL.Eof
      if AddDebtMontFlg then
      'Накопление долга по алиментам в месяцах, если сотрудник не проработал ни одного часа
        gdcAlimonyDebt.Insert
        gdcAlimonyDebt.FieldByName("usr$totaldockey").AsInteger = TotalDocKey
        gdcAlimonyDebt.FieldByName("usr$alimonykey").AsInteger = IBSQL.FieldByName("documentkey").AsInteger
        gdcAlimonyDebt.FieldByName("usr$debtsum").AsCurrency = 0
        gdcAlimonyDebt.FieldByName("usr$debtmonth").AsInteger = 1
        gdcAlimonyDebt.Post
      else
        FormulaStr = Replace(Replace(IBSQL.FieldByName("usr$formula").AsString, ".", Application.DecimalSeparatorSys), ",", Application.DecimalSeparatorSys)

        Sum = wg_GetAlimonySum(wg_FoCal, FormulaStr, _
              IBSQL.FieldByName("usr$datebegin").AsDateTime, wg_EmployeeCharge.BeginDate)
        'Проверка на бюджет прожиточного минимума
        if wg_EmployeeCharge.BeginDate >= DateSerial(2009, 5, 1) then
          LivingWage = wg_MonthHour.LivingWage(wg_EmployeeCharge.BeginDate)
          Count = IBSQL.FieldByName("USR$CHILDCOUNT").AsInteger
          
          if IBSQL.FieldByName("USR$LIVINGWAGEPERC").AsCurrency <= 0 then
            if Count = 1 then
              LivingWage = LivingWage / 2
            elseif Count = 2 then
              LivingWage = LivingWage * 75 / 100
            elseif Count >= 3 then

            end if
          else
            LivingWage = LivingWage *  IBSQL.FieldByName("USR$LIVINGWAGEPERC").AsCurrency / 100
          end if
          if Sum < LivingWage then
            Sum = LivingWage
          end if
        end if
       'Округление
        Sum = wg_RoundSum(FeeTypeKey, Sum)
        'Суммы для резерва денег по алименты и суммы для их перевода
        if not IBSQL.FieldByName("usr$transfertypekey").isNull then
          ReservTransferSum = wg_RoundSum(wg_FeeType_TransferDed_ID, Sum * _
            wg_TransferDed.Types(IBSQL.FieldByName("usr$transfertypekey").AsInteger).GetPercent(wg_EmployeeCharge.EndDate, Sum) / 100)
        else
          ReservTransferSum = 0
        end if
        'Если резервировать некуда, то ...
        if AlimonyReservAll + Sum + ReservTransferSum > RestSum then
          SumTmp = RestSum - AlimonyReservAll            'Резервируем все деньги, которые остаются
        else
          SumTmp = Sum + ReservTransferSum
        end if
        if SumTmp < 0 then
          SumTmp = 0
        end if
        'Добавление данных по алиментам в экземпляр класса
        call wg_Alimony.Add(IBSQL.FieldByName("documentkey").AsInteger, Sum, _
                       IBSQL.FieldByName("usr$restpercent").AsCurrency, _
                       IBSQL.FieldByName("usr$transfertypekey").Value, SumTmp) 'Sum + ReservTransferSum)
        AlimonyReservAll = AlimonyReservAll + SumTmp 'Sum + ReservTransferSum
      end if
      IBSQL.Next
    wend
    IBSQL.Close
    'Если по сотруднику было накапливание долга по месяцам, то расчет можно завершать
    if AddDebtMontFlg then
      gdcAlimonyDebt.Close
      wg_EmployeeCharge.FirstMoveKey = Null
      exit function
    end if
    'Выборка долгов по алиментам. Сортировка: по долгам в суммах, по дате начала долга
    IBSQL.SQL.Text = "SELECT line.documentkey, IIF(line.usr$debtsum > 0 and line.usr$debtsum > alrest.credit, 0, 1) AS debttype,  " & _
      "  total.usr$datebegin AS thedate, al.documentkey AS alimonykey,  " & _
      "  line.usr$debtsum, alrest.credit, line.usr$debtmonth, pmonth.mcount,  " & _
      "  al.usr$restpercent, al.usr$datebegin, al.usr$transfertypekey, al.usr$formula, al.usr$percent  " & _
      " FROM GD_DOCUMENT d " & _
      " LEFT JOIN usr$wg_alimony al ON al.DOCUMENTKEY = d.ID " & _
      "  LEFT JOIN usr$wg_alimonydebt line ON al.documentkey = line.usr$alimonykey " & _
      "  LEFT JOIN usr$wg_total total ON total.documentkey = line.usr$totaldockey  " & _
      "  LEFT JOIN USR$WG_P_TBLCHARGEBYDOC(al.usr$emplkey, :feetypekey, line.documentkey) alrest ON 1=1  " & _
      "  LEFT JOIN USR$WG_P_ALIMONYPAYEDMONTH(line.documentkey) pmonth ON 1=1  " & _
      "WHERE  " & _
      "  al.usr$emplkey = :emplkey  " & _
      "  AND (alrest.credit < line.usr$debtsum OR line.usr$debtmonth > pmonth.mcount)  " & _
      "  AND d.DOCUMENTTYPEKEY = :ruid  " & _
      "  AND total.USR$DATEBEGIN <= :DB  " & _
      "ORDER BY 2, 3 "
    IBSQL.ParamByName("feetypekey").AsInteger = wg_FeeType_AlimonyDebt_ID
    IBSQL.ParamByName("DB").AsDateTime = wg_EmployeeCharge.BeginDate
    IBSQL.ParamByName("emplkey").AsInteger = wg_EmployeeCharge.Employeekey
    IBSQL.ParamByName("ruid").AsInteger = gdcBaseManager.GetIdByRuidString("147067079_453357870")
    IBSQL.ExecQuery
'    while not (IBSQL.Eof or RestSum <= MustPaySum)
    'Добавление долгов по алиментам в объект класса wg_Alimony
    while not IBSQL.Eof

      if (IBSQL.FieldByName("usr$percent").AsCurrency > 0) and _
         (IBSQL.FieldByName("usr$percent").AsCurrency < 100) then
        'sum = (RestSum - AlimonyReservAll) * IBSQL.FieldByName("usr$percent").AsCurrency / 100
        sum = (RestSum) * IBSQL.FieldByName("usr$percent").AsCurrency / 100
        if sum > (IBSQL.FieldByName("usr$debtsum").AsCurrency - IBSQL.FieldByName("credit").AsCurrency) then _
          sum = IBSQL.FieldByName("usr$debtsum").AsCurrency  - IBSQL.FieldByName("credit").AsCurrency
        sum = wg_RoundSum(wg_FeeType_AlimonyDebt_ID, Sum)
      else
        sum = IBSQL.FieldByName("usr$debtsum").AsCurrency - IBSQL.FieldByName("credit").AsCurrency
      end if
      if sum < 0 then sum = 0
      'Если алиментов, по которым есть долг, нет в списке алиментов, то добавим алименты в список
      if not wg_Alimony.Exists(IBSQL.FieldByName("alimonykey").AsInteger) then
        call wg_Alimony.Add(IBSQL.FieldByName("alimonykey").AsInteger, 0, _
                     IBSQL.FieldByName("usr$restpercent").AsCurrency, _
                     IBSQL.FieldByName("usr$transfertypekey").Value, 0)
      end if
      AlimonyKey = IBSQL.FieldByName("alimonykey").AsInteger
      'Долг в месяцах
      DebtMonthCount = IBSQL.FieldByName("usr$debtmonth").AsInteger - IBSQL.FieldByName("mcount").AsInteger

      call wg_Alimony.ItemByID(AlimonyKey).Add(_
        IBSQL.FieldByName("documentkey").AsInteger, Sum, DebtMonthCount)

      if DebtMonthCount > 0 then
        if wg_Alimony.ItemByID(AlimonyKey).ForDebtMonthSum = 0 then
          DebtMontSum = wg_GetAlimonySum(wg_FoCal, IBSQL.FieldByName("usr$formula").AsString, _
                IBSQL.FieldByName("usr$datebegin").AsDateTime, wg_EmployeeCharge.BeginDate)
         'Округление
          DebtMontSum = wg_RoundSum(FeeTypeKey, DebtMontSum)
          wg_Alimony.ItemByID(AlimonyKey).ForDebtMonthSum = DebtMontSum
          DebtAllMontSum = DebtMontSum * DebtMonthCount
        else
          DebtAllMontSum = wg_Alimony.ItemByID(AlimonyKey).ForDebtMonthSum * DebtMonthCount
        end if
      else
        DebtAllMontSum = 0
      end if
      wg_Alimony.ItemByID(AlimonyKey).MustPaySum = _
        wg_Alimony.ItemByID(AlimonyKey).MustPaySum + Sum + DebtAllMontSum
      IBSQL.Next
    wend
    IBSQL.Close

    AlimonyDebtAllSum = 0
    AlimonyAllSum = 0
    TransferAllSum = 0
    OverReservedSum = 0
    
'    set gdcAlimonyDebt = Nothing
   'Цикл по алиментам
    for i = 0 to wg_Alimony.Count - 1
    'Определим сумму за перевод и сумму, которую может выплатить сотрудник (с учетом расходов за перевод)
      'Процент остатка. Т.е. процент, который нужно оставить сотруднику
      RestPercentSum = wg_Alimony.Item(i).RestPercent * _
                      (wg_EmployeeCharge.Debit - wg_EmployeeCharge.Credit + wg_EmployeeCharge.PayedOut) / 100

      'Сумма для резерва сумм других алиментов. Т.е. сначала нужно выплатить деньги по алиментам, а потом по их долгам
      'Из общей резервной суммы нужно исключить текущие алименты и те, которые уже расчитали
      AlimonyReservAll = AlimonyReservAll - wg_Alimony.Item(i).ReservedSum

'      if AlimonyReservedSum > RestSum then
'      end if
      OutArray = wg_CalcTransferSum(wg_Alimony.Item(i).MustPaySum, wg_Alimony.Item(i).TransferTypeKey, _
        wg_EmployeeCharge.BeginDate, RestSum - RestPercentSum - AlimonyReservAll)
      CanPaySum = OutArray(0)
      TransferSum = OutArray(1)
      'Занести сумму за пересылку алиментов в начисления по табелю
      if TransferSum > 0 then
        call wg_EmployeeCharge.AddCharge(0, TransferSum, Null, TotalDocKey, wg_FeeType_TransferDed_ID,_
             wg_Alimony.Item(i).ID, wg_EmployeeCharge.BeginDate, 0, 0)
             
        call wg_EmployeeCharge.AddChargeRegNew(0, TransferSum, TotalDocKey, wg_FeeType_TransferDed_ID, _
             AccountKeyTransf, wg_EmployeeCharge.BeginDate, wg_Alimony.Item(i).ID)

      end if

      'Определение по каким документам возможны выплаты
      'Текущий долг по алиментам
      if wg_Alimony.Item(i).Sum > CanPaySum then
      'Добавление текущего долга в журнал долга по алиментам
'        if not Assigned(gdcAlimonyDebt) then
'          set gdcAlimonyDebt = Creator.GetObject(nil, "TgdcUserDocument", "")
'          gdcAlimonyDebt.SubType = "147072391_453357870"
'          gdcAlimonyDebt.Transaction = wg_EmployeeCharge.Transaction
'          gdcAlimonyDebt.Open
'        end if
        gdcAlimonyDebt.Insert
        gdcAlimonyDebt.FieldByName("usr$totaldockey").AsInteger = TotalDocKey
        gdcAlimonyDebt.FieldByName("usr$alimonykey").AsInteger = wg_Alimony.Item(i).ID
        gdcAlimonyDebt.FieldByName("usr$debtsum").AsCurrency = wg_Alimony.Item(i).Sum - CanPaySum
        gdcAlimonyDebt.FieldByName("usr$debtmonth").AsInteger = 0
        gdcAlimonyDebt.Post

        AlimonyDebt = wg_Alimony.Item(i).Sum - CanPaySum
        AlimonySum = CanPaySum
      else
        AlimonySum = wg_Alimony.Item(i).Sum
      end if
      'Занести сумму выплаченных алиментов в начисления по табелю
      if AlimonySum > 0 then
        call wg_EmployeeCharge.AddCharge(0, AlimonySum, Null, TotalDocKey, FeeTypeKey,_
          wg_Alimony.Item(i).ID, wg_EmployeeCharge.BeginDate, 0, 0)
        call wg_EmployeeCharge.AddChargeRegNew(0, AlimonySum, TotalDocKey, FeeTypeKey, _
          AccountKey, wg_EmployeeCharge.BeginDate, wg_Alimony.Item(i).ID)
      end if

     'Гашение долгов в суммах
      TmpSum = CanPaySum - AlimonySum
      for j = 0 to wg_Alimony.Item(i).Count - 1
        if TmpSum > 0 then
          if wg_Alimony.Item(i).Item(j).Sum > 0 then
            if wg_Alimony.Item(i).Item(j).Sum <= TmpSum then
              AlimonyDebtSum = wg_Alimony.Item(i).Item(j).Sum
            else
              AlimonyDebtSum = TmpSum
            end if
            'Занести сумму выплаченного долга в начисления по табелю
            call wg_EmployeeCharge.AddCharge(0, AlimonyDebtSum, Null, TotalDocKey, wg_FeeType_AlimonyDebt_ID,_
              wg_Alimony.Item(i).Item(j).ID, wg_EmployeeCharge.BeginDate, 0, 0)
              
            call wg_EmployeeCharge.AddChargeRegNew(0, AlimonyDebtSum, TotalDocKey, _
              wg_FeeType_AlimonyDebt_ID, AccountKeyDebt, wg_EmployeeCharge.BeginDate, wg_Alimony.Item(i).Item(j).ID)


            AlimonyDebtAllSum = AlimonyDebtAllSum + AlimonyDebtSum
            TmpSum = TmpSum - AlimonyDebtSum 'wg_Alimony.Item(i).Item(j).Sum
            end if
        else
          exit for
        end if
      next
     'Гашение долгов в месяцах
      TmpSum = CanPaySum - AlimonySum - AlimonyDebtSum
      for j = 0 to wg_Alimony.Item(i).Count - 1
        if TmpSum > 0 then
          if wg_Alimony.Item(i).Item(j).DebtMonth > 0 then
            'Сумма за все месяцы
            DebtAllMontSum = wg_Alimony.Item(i).ForDebtMonthSum * wg_Alimony.Item(i).Item(j).DebtMonth

            if DebtAllMontSum <= TmpSum then
              AlimonyMonthDebtSum = DebtAllMontSum
              PayedMonthCount = wg_Alimony.Item(i).Item(j).DebtMonth
            else
              AlimonyMonthDebtSum = TmpSum
'              PayedMonthCount = Int(DebtAllMontSum / wg_Alimony.Item(i).ForDebtMonthSum) + 1
              PayedMonthCount = Int(AlimonyMonthDebtSum / wg_Alimony.Item(i).ForDebtMonthSum)

              if AlimonyMonthDebtSum / wg_Alimony.Item(i).ForDebtMonthSum - PayedMonthCount > 0 then
                PayedMonthCount = PayedMonthCount + 1
              end if


            end if
            'Добавим сумму, которую должны выплатить по погашенным месяцам в журнал долгов,
            ' иначе получится отрицательный кредит по долгу.
            'TODO: это можно сделать в классе
            gdcAlimonyDebt.Insert
            gdcAlimonyDebt.FieldByName("usr$totaldockey").AsInteger = TotalDocKey
            gdcAlimonyDebt.FieldByName("usr$alimonykey").AsInteger = wg_Alimony.Item(i).ID
            gdcAlimonyDebt.FieldByName("usr$debtmonth").AsInteger = 0
            gdcAlimonyDebt.FieldByName("usr$debtsum").AsCurrency = PayedMonthCount * wg_Alimony.Item(i).ForDebtMonthSum
            gdcAlimonyDebt.Post
            'Занести сумму выплаченного долга в начисления по табелю на добавленный выше документ
            call wg_EmployeeCharge.AddCharge(0, AlimonyMonthDebtSum, Null, TotalDocKey, wg_FeeType_AlimonyDebt_ID,_
              gdcAlimonyDebt.ID, wg_EmployeeCharge.BeginDate, 0, 0)
              
            call wg_EmployeeCharge.AddChargeRegNew(0, AlimonyMonthDebtSum, TotalDocKey, _
              wg_FeeType_AlimonyDebt_ID, AccountKeyDebt, wg_EmployeeCharge.BeginDate, gdcAlimonyDebt.ID)

            'Занести погашенные месяцы в журнал
            SQLUpdate.ParamByName("totaldockey").AsInteger = TotalDocKey
            SQLUpdate.ParamByName("alimonydebtkey").AsInteger = wg_Alimony.Item(i).Item(j).ID
            SQLUpdate.ParamByName("payedmonth").AsInteger = PayedMonthCount
            SQLUpdate.ExecQuery
            SQLUpdate.Close

            AlimonyDebtAllSum = AlimonyDebtAllSum + AlimonyMonthDebtSum
            TmpSum = TmpSum - AlimonyMonthDebtSum
          end if
        else
          exit for
        end if
      next

      AlimonyAllSum = AlimonyAllSum + AlimonySum
      TransferAllSum = TransferAllSum + TransferSum
      RestSum = RestSum - AlimonySum - AlimonyDebtSum - TransferSum
    next

'  'Добавление сумм в журнал начислений
'    'Алименты
'    if AlimonyAllSum > 0 then
'      AccountKey = wg_GetAccountKey(FeeTypeKey, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.EndDate)
'      call wg_EmployeeCharge.AddChargeReg(0, AlimonyAllSum, TotalDocKey, FeeTypeKey, AccountKey, Null)
'    end if
'    'Выплаты долга по алиментам
'    if AlimonyDebtAllSum > 0 then               'Сумма выплаты по долгу за алименты
'      AccountKey = wg_GetAccountKey(wg_FeeType_AlimonyDebt_ID, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.BeginDate)
'      call wg_EmployeeCharge.AddChargeReg(0, AlimonyDebtAllSum, TotalDocKey, wg_FeeType_AlimonyDebt_ID, AccountKey, Null)
'    end if
'    'За почтовый перевод
'    if TransferAllSum <> 0 then
'      AccountKey = wg_GetAccountKey(wg_FeeType_TransferDed_ID, wg_EmployeeCharge.EmployeeKey, wg_EmployeeCharge.FirstMoveKey, wg_EmployeeCharge.BeginDate)
'      call wg_EmployeeCharge.AddChargeReg(0, TransferAllSum, TotalDocKey, wg_FeeType_TransferDed_ID, AccountKey, Null)
'    end if

    gdcAlimonyDebt.Close

    wg_FeeAlimonyCalc = AlimonyAllSum + AlimonyDebtAllSum + TransferAllSum
    wg_EmployeeCharge.FirstMoveKey = Null
  end if
end function

