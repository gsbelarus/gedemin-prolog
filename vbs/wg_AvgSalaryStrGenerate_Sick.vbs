'#include wg_EmplMoveList

function wg_AvgSalaryStrGenerate_Sick(ByRef Sender)
'
'Есть 3 варианта расчета, которые зависят от того в какой момент произошло изменение оклада (ставки):
' 1. Расчет стандартный:
'    - последнее повышение было до периода расчета среднего заработка
' 2. Период расчета: с момента повышения зрп до начала нетрудоспособности
'    - повышение попало с первого числа месяца расчета ср. заработка и до начала нетрудоспособности
' 3. Расчет стандартный, но сумма увеличивается на коэффициент повышения оклада (ставки)
'    - повышение попало на период нетрудоспособности
  Sender.GetComponent("actApply").Execute
  'Сбрасываем кэш для Переменных
  set wg_Variable_ = Nothing

  set gdcObject = Sender.gdcObject
  set gdcAvgStr = Sender.FindComponent("usrg_gdcAvgSalaryStr")
  
  gdcObject.FieldByName("USR$CALCBYBUDGET").AsInteger = 0

  'Выключаем автоперерасчет среднего заработка
  gdcAvgStr.Tag = 1
  'Удалим старые значения
  gdcAvgStr.First
  while not gdcAvgStr.Eof
    gdcAvgStr.Delete
'    gdcAvgStr.Next
  wend
  'Дата начала нетрудоспособности
  DateFrom = gdcObject.FieldByName("usr$from").AsDateTime
  'Первое число месяца больничного
  FirstDateBeginIll = DateSerial(Year(DateFrom), Month(DateFrom), 1)
  DateEnd = gdcObject.FieldByName("usr$dateend").AsDateTime
  AddDuration = DateDiff("m", DateFrom, DateEnd) + 1

  'Расчет по часам
  ByHourFlg = (gdcObject.FieldByName("usr$calcbyhour").AsInteger = 1)

  'Определим по карточке сотрудника (на дату окончания) прослеживать изменения оклада или ставки
  BySalaryFlg = False
  set EmplMoveList = wg_EmplMoveList.MoveCardList(gdcObject.FieldByName("usr$emplkey").AsInteger, Null)
  if Assigned(EmplMoveList) then
    set MoveCard = EmplMoveList.ExistMoveCardByDate(DateEnd)
    if Assigned(MoveCard) then
      BySalaryFlg = MoveCard.PayFormKey = gdcBaseManager.GetIDByRUIDString(wg_PayForm_Salary_RUID)
      if IsNull(BySalaryFlg) then BySalaryFlg = 0
    end if
  end if
  set AvgPeriodsObj = New Twg_AvgPeriods
  AvgPeriodsObj.EmplKey = gdcObject.FieldByName("usr$emplkey").AsInteger
  AvgPeriodsObj.FirstMoveKey = gdcObject.FieldByName("usr$firstmovekey").AsInteger
  Duration = gdcObject.FieldByName("usr$avgperiod").AsInteger
  AvgPeriodsObj.DateBegin = DateAdd("m", - Duration, FirstDateBeginIll)
  AvgPeriodsObj.Duration = Duration '+ AddDuration
  AvgPeriodsObj.FeeGroupKey = gdcObject.FieldByName("usr$feegroupkey").Value
  AvgPeriodsObj.BySalary = BySalaryFlg
  AvgPeriodsObj.ByStaffSalary = (gdcObject.FieldByName("usr$bystaffsalary").AsInteger = 1)
  AvgPeriodsObj.DateFrom = DateFrom
  AvgPeriodsObj.IsPregnancy = _
      (gdcObject.FieldByName("USR$ILLTYPEKEY").AsInteger = _
         gdcBaseManager.GetIDByRUIDString(wg_SickType_Pregnancy_RUID))

  set AvgPeriodItems = AvgPeriodsObj.Items
  AvgPeriodItemsArr = AvgPeriodItems.Items
  'Дата последнего изменения
  LastDateChange = AvgPeriodsObj.LastDateChange

  NoMovingFlg = False
  ChangeOnIllPeriodFlg = False
  if IsNull(LastDateChange) then
    'Движений за период расчета и больничного не было
    LastDateChange = AvgPeriodsObj.DateBegin
    NoMovingFlg = True
  else
    ChangeOnIllPeriodFlg = (LastDateChange >= DateFrom and LastDateChange <= DateEnd)
    if ChangeOnIllPeriodFlg then _
      NoMovingFlg = True
  end if

  Coeff = 1
  NewSalary = 0
  AllSum = 0
  AllWorkDay = 0
  AllWorkHour = 0
  for i = AvgPeriodItems.Count - 1 to 0 step -1
    'Интересуют все месяцы, кроме тех, которые идут после начала больничного без движений
    if AvgPeriodItemsArr(i).DateChange <= FirstDateBeginIll or _
        (AvgPeriodItemsArr(i).DateChange > FirstDateBeginIll and AvgPeriodItemsArr(i).DateChange <= DateEnd and AvgPeriodItemsArr(i).IsChange) then

      'Подсчет коэффициента изменения оклада (ставки)
      if NewSalary > 0 and AvgPeriodItemsArr(i).DateChange < FirstDateBeginIll and Coeff = 1 then
        if AvgPeriodsObj.BySalary then
          Coeff = NewSalary / AvgPeriodItemsArr(i).Salary
        else
          Coeff = NewSalary / AvgPeriodItemsArr(i).FCRate
        end if
      end if

      gdcAvgStr.Insert
'      gdcAvgStr.FieldByName("usr$ischeck").AsInteger = 0
      gdcAvgStr.FieldByName("usr$date").AsDateTime = AvgPeriodItemsArr(i).DateBegin
      gdcAvgStr.FieldByName("usr$salary").AsCurrency = AvgPeriodItemsArr(i).SumByGroup
      gdcAvgStr.FieldByName("usr$oldsalary").AsCurrency = AvgPeriodItemsArr(i).Salary
      gdcAvgStr.FieldByName("usr$newsalary").AsCurrency = AvgPeriodItemsArr(i).FCRate
      gdcAvgStr.FieldByName("usr$dow").AsCurrency = AvgPeriodItemsArr(i).WorkDays
      gdcAvgStr.FieldByName("usr$how").AsCurrency = AvgPeriodItemsArr(i).WorkHours
      gdcAvgStr.FieldByName("usr$schedulerdow").AsCurrency = AvgPeriodItemsArr(i).SchedulerDays
      gdcAvgStr.FieldByName("usr$schedulerhow").AsCurrency = AvgPeriodItemsArr(i).SchedulerHours
      gdcAvgStr.FieldByName("usr$coeff").AsCurrency = Coeff
      gdcAvgStr.FieldByName("usr$description").AsString = AvgPeriodItemsArr(i).Description

      ' added 19.07.13
      ' если декретный или дата > 11.07.13, то признак во всех периодах =1
      if DateFrom >= CDate("11.07.2013") or AvgPeriodsObj.IsPregnancy then
        gdcAvgStr.FieldByName("usr$ischeck").AsInteger = 1
      else
        gdcAvgStr.FieldByName("usr$ischeck").AsInteger = 0
      end if
      ' end added


'      if (NoMovingFlg and AvgPeriodItemsArr(i).DateChange < FirstDateBeginIll) or _
'          (AvgPeriodItemsArr(i).DateChange >= LastDateChange) then
'        gdcAvgStr.FieldByName("usr$ischeck").AsInteger = 1
'      end if

      if AvgPeriodItemsArr(i).DateChange < FirstDateBeginIll then
      'Периоды, до начала месяца болезни
        if AvgPeriodItemsArr(i).DateChange >= LastDateChange or LastDateChange >= DateFrom then
          gdcAvgStr.FieldByName("usr$ischeck").AsInteger = 1
        end if
      else
        if AvgPeriodItemsArr(i).DateChange < DateFrom and AvgPeriodItemsArr(i).DateChange >= LastDateChange and (not NoMovingFlg) then
          gdcAvgStr.FieldByName("usr$ischeck").AsInteger = 1
        end if
      end if

'      IsCheck = AvgPeriodItemsArr(i).DateChange < FirstDateBeginIll

      if ChangeOnIllPeriodFlg and AvgPeriodItemsArr(i).DateChange = LastDateChange then
       'Изменение попадает в период болезни, т.е. сумма будет проиндексирована
        if AvgPeriodsObj.BySalary then
          NewSalary = AvgPeriodItemsArr(i).Salary
        else
          NewSalary = AvgPeriodItemsArr(i).FCRate
        end if
      end if
      if gdcAvgStr.FieldByName("usr$ischeck").AsInteger = 1 then
        AllSum = AllSum + gdcAvgStr.FieldByName("usr$salary").AsCurrency
        AllWorkDay = AllWorkDay + gdcAvgStr.FieldByName("usr$dow").AsCurrency
        AllWorkHour = AllWorkHour + gdcAvgStr.FieldByName("usr$how").AsCurrency
      end if
      gdcAvgStr.Post
    end if
  next
  AvgSum = 0
  if ByHourFlg then
    AllWorkPoint = AllWorkHour
  else
    AllWorkPoint = AllWorkDay
  end if
  if AllWorkPoint > 0 then
    AvgSum = AllSum / AllWorkPoint
  end if
  gdcAvgStr.Tag = 0

  gdcObject.FieldByName("usr$thirdmethod").AsInteger = 0
  if gdcObject.OwnerForm.Name = "gdc_dlgUserComplexDocument147022845_119619099" and (gdcObject.FieldByName("usr$reference").AsInteger = 1 or gdcAvgStr.RecordCount = 6) then
    dim q, Creator
    set Creator = new TCreator
    set q = Creator.GetObject(null, "TIBSQL", "")
    q.Transaction = gdcObject.Transaction
'    q.SQL.Text = _
'    "SELECT * " & _
'    "FROM USR$WG_AVGSALARYSTR " & _
'    "WHERE " & _
'    "  USR$DOCUMENTKEY = :parent " & _
'    " AND " & _
'    "  EXTRACT(DAY FROM DATEADD(DAY, -1, CAST(EXTRACT(YEAR FROM USR$DATE)||'.'||(EXTRACT(MONTH FROM USR$DATE)+1)||'.01' AS DATE))) = USR$DOW "
'    q.ParamByName("parent").AsInteger = gdcObject.ID
'    q.ExecQuery

    q.SQL.Text = _
        "EXECUTE BLOCK( " & _
        "  PARENT INTEGER = :PARENT) " & _
        "RETURNS " & _
        "( " & _
        "  OK INTEGER " & _
        ") " & _
        " AS " & _
        "DECLARE VARIABLE EMPLKEY INTEGER; " & _
        "DECLARE VARIABLE FDATE DATE; " & _
        "DECLARE VARIABLE DOW INTEGER; " & _
        "DECLARE VARIABLE LEAVEDAY INTEGER; " & _
        "DECLARE VARIABLE MONTHDAY INTEGER; " & _
        "DECLARE VARIABLE TempM INTEGER; " & _
        "DECLARE VARIABLE TempY INTEGER; " & _
        "DECLARE VARIABLE TempNextDate DATE; " & _
        "BEGIN " & _
        "  OK = 0; " & _
        "  FOR " & _
        "    SELECT LIST.USR$EMPLKEY, STR.USR$DATE, STR.USR$DOW " & _
        "    FROM USR$WG_AVGSALARYSTR STR " & _
        "    JOIN USR$WG_SICKLIST LIST ON LIST.DOCUMENTKEY = STR.USR$DOCUMENTKEY " & _
        "    WHERE " & _
        "      USR$DOCUMENTKEY = :parent " & _
        "    INTO :EMPLKEY, :FDATE, :DOW " & _
        "  DO " & _
        "  BEGIN " & _
        "   " & _
        "    TempM = EXTRACT(MONTH FROM CAST(:FDATE AS DATE)); " & _
        "    TempY = EXTRACT(YEAR FROM CAST(:FDATE AS DATE)); " & _
        "    TempM = TempM + 1; " & _
        "    IF (TempM = 13) THEN " & _
        "    BEGIN " & _
        "      TempY = TempY + 1; " & _
        "      TempM = 1; " & _
        "    END " & _
        "    TempNextDate = CAST('01.' ||  RIGHT('0' || TempM, 2) || '.' || TempY  AS DATE); " & _
        "    MONTHDAY = EXTRACT(DAY FROM( DATEADD(DAY, -1, TempNextDate))); " & _
        "    SELECT " & _
        "      SUM(CASE " & _
        "      WHEN EXTRACT(MONTH FROM U.USR$DATEBEGIN) = EXTRACT(MONTH FROM U.USR$DATEEND) THEN U.USR$DATEEND - U.USR$DATEBEGIN + 1 " & _
        "      WHEN EXTRACT(MONTH FROM U.USR$DATEBEGIN) < EXTRACT(MONTH FROM U.USR$DATEEND) AND EXTRACT(MONTH FROM U.USR$DATEBEGIN) = EXTRACT(MONTH FROM CAST(:FDATE AS DATE)) THEN DATEADD(DAY, -1, :TempNextDate) - U.USR$DATEBEGIN + 1 " & _
        "      WHEN EXTRACT(MONTH FROM U.USR$DATEBEGIN) < EXTRACT(MONTH FROM U.USR$DATEEND) AND EXTRACT(MONTH FROM U.USR$DATEEND) = EXTRACT(MONTH FROM CAST(:FDATE AS DATE)) THEN U.USR$DATEEND - :FDATE + 1 " & _
        "      END) AS LEAVEDAY " & _
        "    FROM GD_DOCUMENT Z " & _
        "    JOIN USR$WG_LEAVEDOCLINE U ON Z.ID = U.DOCUMENTKEY " & _
        "    WHERE " & _
        "      Z.DOCUMENTTYPEKEY = 328606656 " & _
        "     AND " & _
        "      U.USR$EMPLKEY = :EMPLKEY " & _
        "     AND " & _
        "      EXTRACT(MONTH FROM CAST(:FDATE AS DATE)) BETWEEN EXTRACT(MONTH FROM U.USR$DATEBEGIN) AND EXTRACT(MONTH FROM U.USR$DATEEND) " & _
        "    INTO :LEAVEDAY; " & _
        "    IF (LEAVEDAY IS NULL) THEN " & _
        "        LEAVEDAY = 0; " & _
        " " & _
        " " & _
        "    IF (DOW + LEAVEDAY = MONTHDAY) THEN " & _
        "        OK = OK + 1; " & _
        "  END " & _
        "  SUSPEND; " & _
        "END "


    q.ParamByName("parent").AsInteger = gdcObject.ID
    q.ExecQuery

    if q.FieldByName("OK").AsInteger = 0 or (gdcObject.FieldByName("usr$reference").AsInteger = 1) then
      q.Close
      q.SQL.Text = _
      "SELECT FIRST 1 COALESCE(ML.USR$THOURRATE, 0) AS RATE " & _
      "FROM USR$WG_TOTAL T " & _
      "JOIN USR$WG_MOVEMENTLINE ML ON ML.USR$DATEBEGIN <= T.USR$DATEBEGIN " & _
      "WHERE " & _
      "  T.DOCUMENTKEY = :totalkey " & _
      "  AND ML.USR$EMPLKEY = :emplkey " & _
      "ORDER BY ML.USR$DATEBEGIN DESC "
      q.ParamByName("totalkey").AsInteger = gdcObject.FieldByName("USR$TOTALDOCKEY").AsInteger
      q.ParamByName("emplkey").AsInteger = gdcObject.FieldByName("USR$EMPLKEY").AsInteger
      q.ExecQuery

      gdcObject.FieldByName("usr$thirdmethod").AsInteger = 1

      if not q.EOF then
        AvgSum = 8*q.FieldByName("RATE").AsCurrency
      else
        AvgSum = 0
      end if
    end if
  end if
  gdcObject.FieldByName("usr$avgsumma").AsCurrency = Round(AvgSum)
end function

