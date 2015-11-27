%% twg_avg_wage_sql
%  спецификации и sql-шаблоны для базы знаний twg_avg_wage
%

:-  style_check(-atom),
    GetSQL = [gd_pl_ds/5, get_sql/5],
    %dynamic(GetSQL),
    multifile(GetSQL),
    discontiguous(GetSQL).

%
wg_valid_sql([
            % section twg_avg_wage
            %  05. Начисление отпусков
            -usr_wg_DbfSums/8, % 05, 06, 12
            usr_wg_MovementLine/15, % 05, 06, 12
            usr_wg_FCRate/4, % 05, 12
            usr_wg_TblCalDay/9, % 05, 06, 12
            -usr_wg_TblDayNorm/8, % 05, 06
            -usr_wg_TblYearNorm/5,
            usr_wg_TblCalLine/7, % 05, 06, 12
            usr_wg_TblCal_FlexLine/68, % 05, 06, 12
            usr_wg_HourType/13, % 05, 06
            usr_wg_TblCharge/10, % 05, 06, 12
            usr_wg_FeeType/6, % 05, 06, 12
            usr_wg_FeeTypeNoCoef/4,
            usr_wg_BadHourType/3,
            usr_wg_BadFeeType/3,
            usr_wg_SpecDep/3,
            %  06. Начисление больничных
            usr_wg_AvgWage/6,
            usr_wg_FeeTypeProp/4, % 06, 12
            wg_holiday/1,
            usr_wg_ExclDays/8, % 05, 06
            % 12. Начисление по-среднему
            usr_wg_TblChargeBonus/8,
            % section twg_struct
            %wg_holiday/1,
            wg_vacation_slice/2,
            wg_vacation_compensation/3,
            gd_const_budget/2,
            gd_const_AvgSalaryRB/2, % 06, 12
            %usr_wg_TblDayNorm/8,
            wg_job_ill_type/1,
            wg_child_ill_type/1,
            % section twg_rule
            usr_wg_pl_Rule/2,
            -
            ]).

%
is_valid_sql(Functor/Arity) :-
    wg_valid_sql(ValidSQL),
    memberchk(Functor/Arity, ValidSQL),
    !.

%  05. Начисление отпусков
gd_pl_ds(wg_avg_wage_vacation, kb, usr_wg_DbfSums, 8, [
    fEmplKey-integer, fInSum-float, fInDays-float, fInHoures-float,
    fInYear-integer, fInMonth-integer, fDateBegin-date,
    fSickProp-boolean
    ]).
% usr_wg_DbfSums(EmplKey, InSum, InDays, InHoures, InYear, InMonth, DateBegin, SickProp)
get_sql(wg_avg_wage_vacation, kb, usr_wg_DbfSums/8,
"
SELECT
  Z.USR$EMPLKEY,
  COALESCE(Z.USR$SUM, 0) AS INSUM,
  COALESCE(Z.USR$DOW, 0) AS InDays,
  COALESCE(Z.USR$MID_HOW, 0) AS INHOURES,
  EXTRACT(YEAR FROM IDK.USR$DATEBEGIN) AS InYear,
  EXTRACT(MONTH FROM IDK.USR$DATEBEGIN) AS InMonth,
  IDK.USR$DATEBEGIN,
  USR$SICK_PROP AS SickProp
FROM
  USR$GMK_SUMS Z
JOIN
  USR$WG_TOTAL IDK
    ON IDK.DOCUMENTKEY  =  Z.USR$INDOCKEY
WHERE
  Z.USR$EMPLKEY = pEmplKey
  AND
  IDK.USR$DATEBEGIN >= 'pDateCalcFrom'
  AND
  IDK.USR$DATEBEGIN < 'pDateCalcTo'
ORDER BY
  Z.USR$EMPLKEY,
  IDK.USR$DATEBEGIN
",
    [
    pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_
    ]).

gd_pl_ds(Scope, kb, usr_wg_MovementLine, 15, [
    fEmplKey-integer, fDocumentKey-integer, fFirstMoveKey-integer,
    fMoveYear-integer, fMoveMonth-integer, fDateBegin-date,
    fScheduleKey-integer, fMovementType-integer,
    fRate-float, fListNumber-string, fMSalary-float,
    fPayFormKey-integer, fSalaryKey-integer,
    fTSalary-float, fTHoureRate-float
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg,
        wg_struct_sick
        ]).
% usr_wg_MovementLine(EmplKey, DocumentKey, FirstMoveKey,
%   MoveYear, MoveMonth, DateBegin,
%   ScheduleKey, MovementType, Rate, ListNumber, MSalary,
%   PayFormKey, SalaryKey, TSalary, THoureRate)
get_sql(Scope, kb, usr_wg_MovementLine/15,
"
SELECT
  ml.USR$EMPLKEY,
  ml.DOCUMENTKEY,
  ml.USR$FIRSTMOVE AS FirstMoveKey,
  EXTRACT(YEAR FROM ml.USR$DATEBEGIN) AS MoveYear,
  EXTRACT(MONTH FROM ml.USR$DATEBEGIN) AS MoveMonth,
  ml.USR$DATEBEGIN,
  ml.USR$SCHEDULEKEY,
  ml.USR$MOVEMENTTYPE,
  COALESCE(ml.USR$RATE, 0) AS Rate,
  ml.USR$LISTNUMBER,
  COALESCE(ml.USR$MSALARY, 0) AS MSalary,
  COALESCE(ml.USR$PAYFORMKEY, 0) AS PayFormKey,
  (SELECT id FROM GD_P_GETID(pPayFormSalary_ruid)) AS SalaryKey,
  COALESCE(ml.USR$TSALARY, 0) AS TSalary,
  COALESCE(USR$THOURRATE, 0) AS THoureRate
FROM
  USR$WG_MOVEMENTLINE ml
WHERE
  ml.USR$EMPLKEY = pEmplKey
  AND
  ml.USR$FIRSTMOVE = pFirstMoveKey
  AND
  NOT ml.USR$MOVEMENTTYPE IN(7)
ORDER BY
  ml.USR$EMPLKEY,
  ml.USR$FIRSTMOVE,
  ml.USR$DATEBEGIN
",
    [
    pEmplKey-_, pFirstMoveKey-_, pPayFormSalary_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg,
        wg_struct_sick
        ]).

gd_pl_ds(Scope, kb, usr_wg_FCRate, 4, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fDate-date, fFCRateSum-float
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_avg
        ]).
% usr_wg_FCRate(EmplKey, FirstMoveKey, Date, FCRateSum)
get_sql(Scope, kb, usr_wg_FCRate/4,
"
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  fc.USR$WG_DATE,
  fc.USR$WG_FCRATESUM
FROM
  USR$WG_FCRATE fc
ORDER BY
  fc.USR$WG_DATE
",
    [
    pEmplKey-_, pFirstMoveKey-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_avg
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblCalDay, 9, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fTheDay-date, fWYear-integer, fWMonth-integer, fWDay-integer,
    fWDuration-float, fWorkDay-integer, fScheduleKey-integer
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg,
        wg_struct_sick
        ]).
% usr_wg_TblCalDay(EmplKey, FirstMoveKey, TheDay, WYear, WMonth, WDay,
%    WDuration, WorkDay, ScheduleKey)
get_sql(Scope, kb, usr_wg_TblCalDay/9,
"
SELECT
  ml.USR$EMPLKEY,
  ml.USR$FIRSTMOVE AS FirstMoveKey,
  tcd.THEDAY,
  EXTRACT(YEAR FROM tcd.THEDAY) AS WYEAR,
  EXTRACT(MONTH FROM tcd.THEDAY) AS WMONTH,
  EXTRACT(DAY FROM tcd.THEDAY) AS WDAY,
  tcd.WDURATION,
  tcd.WORKDAY,
  ml.USR$SCHEDULEKEY
FROM
(
SELECT DISTINCT
  USR$EMPLKEY,
  USR$FIRSTMOVE,
  USR$SCHEDULEKEY
FROM
  USR$WG_MOVEMENTLINE
WHERE
  USR$EMPLKEY = pEmplKey
  AND
  USR$FIRSTMOVE = pFirstMoveKey
) ml
JOIN
  WG_TBLCAL tc
    ON tc.ID = ml.USR$SCHEDULEKEY
JOIN
  WG_TBLCALDAY tcd
    ON tcd.TBLCALKEY = tc.ID
WHERE
  COALESCE(tcd.WDURATION, 0) > 0
  AND
  (tcd.THEDAY >= 'pDateCalcFrom' OR tcd.THEDAY >= 'pDateNormFrom')
  AND
  (tcd.THEDAY < 'pDateCalcTo' OR tcd.THEDAY < 'pDateNormTo')
ORDER BY
  tcd.THEDAY
",
    [
    pEmplKey-_, pFirstMoveKey-_,
    pDateCalcFrom-_, pDateCalcTo-_,
    pDateNormFrom-_, pDateNormTo-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg,
        wg_struct_sick
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblDayNorm, 8, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fWYear-integer, fWMonth-integer, fTheDay-date, fWDay-integer,
    fWDuration-float, fWorkDay-integer
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg
        ]).
% usr_wg_TblDayNorm(EmplKey, FirstMoveKey, WYear, WMonth, TheDay, WDay, WDuration, WorkDay)
get_sql(Scope, kb, usr_wg_TblDayNorm/8,
"
SELECT EmplKey, FirstMoveKey, WYear, WMonth, TheDay, WDay, WDuration, WorkDay
FROM USR$WG_TBLCALDAY_P(pEmplKey, pFirstMoveKey, 'pDateCalcFrom', 'pDateCalcTo')
",
    [
    pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg
        ]).

gd_pl_ds(wg_avg_wage_vacation, kb, usr_wg_TblYearNorm, 5,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fWYear-integer,
    fWHoures-float, fWDays-integer
    ]).
% usr_wg_TblYearNorm(EmplKey, FirstMoveKey, WYear, WHoures, WDays)
get_sql(wg_avg_wage_vacation, kb, usr_wg_TblYearNorm/5,
"
SELECT EmplKey, FirstMoveKey, WYear, SUM(WDuration) AS WHoures, SUM(WorkDay) AS WDays
FROM USR$WG_TBLCALDAY_P(pEmplKey, pFirstMoveKey, 'pDateNormFrom', 'pDateNormTo')
GROUP BY EmplKey, FirstMoveKey, WYear
",
    [
    pEmplKey-_, pFirstMoveKey-_, pDateNormFrom-_, pDateNormTo-_
    ]).

gd_pl_ds(Scope, kb, usr_wg_TblCalLine, 7, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDate-date,
    fDuration-float, fHoureType-integer
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg,
        wg_struct_sick
        ]).
% usr_wg_TblCalLine(EmplKey, FirstMoveKey, CalYear, CalMonth, Date, Duration, HoureType)
get_sql(Scope, kb, usr_wg_TblCalLine/7,
"
SELECT
  tc.USR$EMPLKEY,
  tc.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM tcl.USR$DATE) AS CalYear,
  EXTRACT(MONTH FROM tcl.USR$DATE) AS CalMonth,
  tcl.USR$DATE,
  SUM(tcl.USR$DURATION) AS Duration,
  tcl.USR$HOURTYPE
FROM
  USR$WG_TBLCAL tc
JOIN
  USR$WG_TBLCALLINE tcl
    ON tcl.MASTERKEY = tc.DOCUMENTKEY
WHERE
  tc.USR$EMPLKEY = pEmplKey
  AND
  tc.USR$FIRSTMOVEKEY = pFirstMoveKey
  AND
  tcl.USR$DATE >= 'pDateCalcFrom'
  AND
  tcl.USR$DATE < 'pDateCalcTo'
GROUP BY
  1,2,3,4,5,7
ORDER BY
  tc.USR$EMPLKEY,
  tc.USR$FIRSTMOVEKEY,
  tcl.USR$DATE
",
    [
    pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg,
        wg_struct_sick
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblCal_FlexLine, 68, [
    fFlexType-string,
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fS1-variant, fH1-variant, fS2-variant, fH2-variant,
    fS3-variant, fH3-variant, fS4-variant, fH4-variant,
    fS5-variant, fH5-variant, fS6-variant, fH6-variant,
    fS7-variant, fH7-variant, fS8-variant, fH8-variant,
    fS9-variant, fH9-variant, fS10-variant, fH10-variant,
    fS11-variant, fH11-variant, fS12-variant, fH12-variant,
    fS13-variant, fH13-variant, fS14-variant, fH14-variant,
    fS15-variant, fH15-variant, fS16-variant, fH16-variant,
    fS17-variant, fH17-variant, fS18-variant, fH18-variant,
    fS19-variant, fH19-variant, fS20-variant, fH20-variant,
    fS21-variant, fH21-variant, fS22-variant, fH22-variant,
    fS23-variant, fH23-variant, fS24-variant, fH24-variant,
    fS25-variant, fH25-variant, fS26-variant, fH26-variant,
    fS27-variant, fH27-variant, fS28-variant, fH28-variant,
    fS29-variant, fH29-variant, fS30-variant, fH30-variant,
    fS31-variant, fH31-variant
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg,
        wg_struct_sick
        ]).
% usr_wg_TblCal_FlexLine(FlexType, EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, S1, H1, ..., S31, H31)
get_sql(Scope, kb, usr_wg_TblCal_FlexLine/68,
"
SELECT
  CASE gd.DOCUMENTTYPEKEY
    WHEN
      (SELECT id FROM gd_ruid WHERE xid = pTblCal_DocType_Plan_xid1 AND dbid = pTblCal_DocType_Plan_dbid1)
        THEN 'plan'
    WHEN
      (SELECT id FROM gd_ruid WHERE xid = pTblCal_DocType_Plan_xid2 AND dbid = pTblCal_DocType_Plan_dbid2)
        THEN 'plan'
    WHEN
      (SELECT id FROM GD_P_GETID(pTblCal_DocType_Fact_ruid))
        THEN 'fact'
    ELSE
        'unknown'
  END
    AS FlexType,
  tcfl.USR$EMPLKEY,
  tcfl.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS CalYear,
  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS CalMonth,
  t.USR$DATEBEGIN,
  tcfl.USR$S1, tcfl.USR$H1, tcfl.USR$S2, tcfl.USR$H2,
  tcfl.USR$S3, tcfl.USR$H3, tcfl.USR$S4, tcfl.USR$H4,
  tcfl.USR$S5, tcfl.USR$H5, tcfl.USR$S6, tcfl.USR$H6,
  tcfl.USR$S7, tcfl.USR$H7, tcfl.USR$S8, tcfl.USR$H8,
  tcfl.USR$S9, tcfl.USR$H9, tcfl.USR$S10, tcfl.USR$H10,
  tcfl.USR$S11, tcfl.USR$H11, tcfl.USR$S12, tcfl.USR$H12,
  tcfl.USR$S13, tcfl.USR$H13, tcfl.USR$S14, tcfl.USR$H14,
  tcfl.USR$S15, tcfl.USR$H15, tcfl.USR$S16, tcfl.USR$H16,
  tcfl.USR$S17, tcfl.USR$H17, tcfl.USR$S18, tcfl.USR$H18,
  tcfl.USR$S19, tcfl.USR$H19, tcfl.USR$S20, tcfl.USR$H20,
  tcfl.USR$S21, tcfl.USR$H21, tcfl.USR$S22, tcfl.USR$H22,
  tcfl.USR$S23, tcfl.USR$H23, tcfl.USR$S24, tcfl.USR$H24,
  tcfl.USR$S25, tcfl.USR$H25, tcfl.USR$S26, tcfl.USR$H26,
  tcfl.USR$S27, tcfl.USR$H27, tcfl.USR$S28, tcfl.USR$H28,
  tcfl.USR$S29, tcfl.USR$H29, tcfl.USR$S30, tcfl.USR$H30,
  tcfl.USR$S31, tcfl.USR$H31
FROM
  GD_DOCUMENT gd
JOIN
  USR$WG_TBLCAL_FLEXLINE tcfl
    ON gd.ID = tcfl.DOCUMENTKEY
JOIN
  USR$WG_TBLCAL_FLEX tcf
    ON tcf.DOCUMENTKEY = tcfl.MASTERKEY
JOIN
  USR$WG_TOTAL t
    ON t.DOCUMENTKEY = tcf.USR$TOTALDOCKEY
WHERE
  tcfl.USR$EMPLKEY = pEmplKey
  AND
  tcfl.USR$FIRSTMOVEKEY = pFirstMoveKey
  AND
  t.USR$DATEBEGIN >= 'pDateCalcFrom'
  AND
  t.USR$DATEBEGIN < 'pDateCalcTo'
 ORDER BY
   tcfl.USR$EMPLKEY,
   tcfl.USR$FIRSTMOVEKEY,
   t.USR$DATEBEGIN
",
    [
    pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_,
    pTblCal_DocType_Plan_xid1-_, pTblCal_DocType_Plan_dbid1-_,
    pTblCal_DocType_Plan_xid2-_, pTblCal_DocType_Plan_dbid2-_,
    pTblCal_DocType_Fact_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg,
        wg_struct_sick
        ]).

gd_pl_ds(Scope, kb, usr_wg_HourType, 13, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fID-integer, fCode-string, fDigitCode-string,
    fDiscription-string, fIsWorked-integer, fShortName-string,
    fForCalFlex-integer, fForOverTime-integer, fForFlex-integer,
    fExcludeForSickList-integer, fExclType-string
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick
        ]).
% usr_wg_HourType(EmplKey, FirstMoveKey,
%   ID, Code, DigitCode, Description, IsWorked, ShortName,
%   ForCalFlex, ForOverTime, ForFlex, ExcludeForSickList, ExclType)
get_sql(Scope, kb, usr_wg_HourType/13,
"
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  ht.ID,
  ht.USR$CODE,
  ht.USR$DIGITCODE,
  ht.USR$DISCRIPTION,
  ht.USR$ISWORKED,
  ht.USR$SHORTNAME,
  ht.USR$FORCALFLEX,
  ht.USR$FOROVERTIME,
  ht.USR$FORFLEX,
  ht.USR$WG_EXCLUDEFORSICKLIST,
  CASE ht.ID
    WHEN
      (SELECT id FROM GD_P_GETID(pKindDayHourType_ruid))
        THEN 'kind_day'
    ELSE
        'unknown'
  END
    AS ExclType
FROM
  USR$WG_HOURTYPE ht
",
    [
    pEmplKey-_, pFirstMoveKey-_, pKindDayHourType_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblCharge, 10, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fDebit-float, fFeeTypeKey-integer, fDOW-float, fHOW-float,
    fPayPeriod-integer
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg
        ]).
% usr_wg_TblCharge(EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, Debit, FeeTypeKey, DOW, HOW, PayPeriod)
get_sql(Scope, kb, usr_wg_TblCharge/10,
"
SELECT
  tch.USR$EMPLKEY,
  tch.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear,
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth,
  tch.USR$DATEBEGIN,
  tch.USR$DEBIT,
  tch.USR$FEETYPEKEY,
  tch.USR$DOW,
  tch.USR$HOW,
  COALESCE(ft.USR$PAYPERIOD, 0) AS PayPeriod
FROM
  USR$WG_TBLCHARGE tch
JOIN
  USR$WG_FEETYPE ft
    ON ft.ID = tch.USR$FEETYPEKEY
WHERE
  tch.USR$EMPLKEY = pEmplKey
  AND
  NOT tch.USR$DEBIT = 0
  AND
  tch.USR$DATEBEGIN >= 'pDateCalcFrom'
  AND
  tch.USR$DATEBEGIN < 'pDateCalcTo'
  AND
  COALESCE(ft.USR$PAYPERIOD, 0) >= 0
ORDER BY
  tch.USR$EMPLKEY,
  tch.USR$DATEBEGIN
",
    [
    pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblChargeBonus, 8, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fDebit-float, fFeeTypeKey-integer,
    fPayPeriod-integer
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_avg
        ]).
% usr_wg_TblChargeBonus(EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin,
%   Debit, FeeTypeKey, PayPeriod)
get_sql(Scope, kb, usr_wg_TblChargeBonus/8,
"
SELECT
  tch.USR$EMPLKEY,
  tch.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear,
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth,
  tch.USR$DATEBEGIN,
  tch.USR$DEBIT,
  tch.USR$FEETYPEKEY,
  COALESCE(ft.USR$PAYPERIOD, 0) AS PayPeriod
FROM
  USR$WG_TBLCHARGE tch
JOIN
  USR$WG_FEETYPE ft
    ON ft.ID = tch.USR$FEETYPEKEY
WHERE
  tch.USR$EMPLKEY = pEmplKey
  AND
  NOT tch.USR$DEBIT = 0
  AND
  tch.USR$DATEBEGIN >= 'pDateBonusFrom'
  AND
  tch.USR$DATEBEGIN < 'pDateBonusTo'
  AND
  COALESCE(ft.USR$PAYPERIOD, 0) > 1
ORDER BY
  tch.USR$EMPLKEY,
  tch.USR$DATEBEGIN
",
    [
    pEmplKey-_, pFirstMoveKey-_, pDateBonusFrom-_, pDateBonusTo-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_avg
        ]).

gd_pl_ds(Scope, kb, usr_wg_FeeType, 6, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fFeeGroupKey-integer, fFeeTypeKey-integer,
    fAvgDayHOW-integer, fAlias-string
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg
        ]).
% usr_wg_FeeType(EmplKey, FirstMoveKey, FeeGroupKey, FeeTypeKey, AvgDayHOW, Alias)
get_sql(Scope, kb, usr_wg_FeeType/6,
"
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  ft.USR$WG_FEEGROUPKEY,
  ft.USR$WG_FEETYPEKEY,
  ft_avg.USR$AVGDAYHOW,
  CASE ft.USR$WG_FEETYPEKEY
    WHEN
      (SELECT id FROM GD_P_GETID(pYearBonus_ruid))
        THEN 'ftYearBonus'
    ELSE
        'unknown'
  END
    AS Alias
FROM
  USR$CROSS179_256548741 ft
JOIN
  USR$WG_FEETYPE ft_avg
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY
WHERE
  ft.USR$WG_FEEGROUPKEY IN
    (SELECT id FROM GD_P_GETID(pFeeGroupKey_ruid))
",
    [
    pEmplKey-_, pFirstMoveKey-_, pFeeGroupKey_ruid-_, pYearBonus_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg
        ]).

gd_pl_ds(wg_avg_wage_vacation, kb, usr_wg_FeeTypeNoCoef, 4, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fFeeGroupKeyNoCoef-integer, fFeeTypeKeyNoCoef-integer
    ]).
% usr_wg_FeeTypeNoCoef(EmplKey, FirstMoveKey, FeeGroupKeyNoCoef, FeeTypeKeyNoCoef)
get_sql(wg_avg_wage_vacation, kb, usr_wg_FeeTypeNoCoef/4,
"
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  ft.USR$WG_FEEGROUPKEY,
  ft.USR$WG_FEETYPEKEY
FROM
  USR$CROSS179_256548741 ft
JOIN
  USR$WG_FEETYPE ft_avg
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY
WHERE
  ft.USR$WG_FEEGROUPKEY =
    (SELECT id FROM GD_P_GETID(pFeeGroupKeyNoCoef_ruid))
",
    [
    pEmplKey-_, pFirstMoveKey-_, pFeeGroupKeyNoCoef_ruid-_
    ]).

gd_pl_ds(wg_avg_wage_vacation, kb, usr_wg_BadHourType, 3, [
    fEmplKey-integer, fFirstMoveKey-integer, fID-integer
    ]).
% usr_wg_BadHourType(EmplKey, FirstMoveKey, ID)
get_sql(wg_avg_wage_vacation, kb, usr_wg_BadHourType/3,
"
SELECT
  pEmplKey AS EmplKey, pFirstMoveKey AS FirstMoveKey, id
FROM USR$WG_HOURTYPE
WHERE id IN
(SELECT id FROM gd_ruid
WHERE xid IN (pBadHourType_xid_IN)
AND dbid = pBadHourType_dbid
)
",
    [
    pEmplKey-_, pFirstMoveKey-_, pBadHourType_xid_IN-_, pBadHourType_dbid-_
    ]).

gd_pl_ds(wg_avg_wage_vacation, kb, usr_wg_BadFeeType, 3, [
    fEmplKey-integer, fFirstMoveKey-integer, fID-integer
    ]).
% usr_wg_BadFeeType(EmplKey, FirstMoveKey, ID)
get_sql(wg_avg_wage_vacation, kb, usr_wg_BadFeeType/3,
"
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  ft.USR$WG_FEETYPEKEY AS id
FROM
  USR$CROSS179_256548741 ft
JOIN
  USR$WG_FEETYPE ft_avg
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY
WHERE
  ft.USR$WG_FEEGROUPKEY =
    (SELECT id FROM GD_P_GETID(pBadFeeGroupKey_ruid))
",
    [
    pEmplKey-_, pFirstMoveKey-_, pBadFeeGroupKey_ruid-_
    ]).

gd_pl_ds(-wg_avg_wage_vacation, kb, usr_wg_BadFeeType, 3, [
    fEmplKey-integer, fFirstMoveKey-integer, fID-integer
    ]).
% usr_wg_BadFeeType(EmplKey, FirstMoveKey, ID)
get_sql(-wg_avg_wage_vacation, kb, usr_wg_BadFeeType/3,
"
SELECT
  pEmplKey AS EmplKey, pFirstMoveKey AS FirstMoveKey, id
FROM USR$WG_FEETYPE
WHERE id IN
(SELECT id FROM gd_ruid
WHERE xid IN (pBadFeeType_xid_IN)
AND dbid = pBadFeeType_dbid
)
",
    [
    pEmplKey-_, pFirstMoveKey-_, pBadFeeType_xid_IN-_, pBadFeeType_dbid-_
    ]).

gd_pl_ds(wg_avg_wage_vacation, kb, usr_wg_SpecDep, 3, [
    fEmplKey-integer, fFirstMoveKey-integer, fID-integer
    ]).
% usr_wg_SpecDep(EmplKey, FirstMoveKey, ID)
get_sql(wg_avg_wage_vacation, kb, usr_wg_SpecDep/3,
"
SELECT
  pEmplKey AS EmplKey, pFirstMoveKey AS FirstMoveKey, id
FROM
  GD_P_GETID(pSpecDep_ruid)
",
    [
    pEmplKey-_, pFirstMoveKey-_, pSpecDep_ruid-_
    ]).

%  06. Начисление больничных
gd_pl_ds(Scope, kb, usr_wg_DbfSums, 8, [
    fEmplKey-integer, fInSum-float, fInDays-float, fInHoures-float,
    fInYear-integer, fInMonth-integer, fDateBegin-date,
    fSickProp-boolean
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_sick, wg_avg_wage_avg
        ]).
% usr_wg_DbfSums(EmplKey, InSum, InDays, InHoures, InYear, InMonth, DateBegin, SickProp)
get_sql(Scope, kb, usr_wg_DbfSums/8,
"
SELECT
  Z.USR$EMPLKEY,
  COALESCE(Z.USR$SUMSICK, 0) AS INSUM,
  COALESCE(Z.USR$DOW, 0) AS InDays,
  COALESCE(Z.USR$MID_HOW, 0) AS INHOURES,
  EXTRACT(YEAR FROM IDK.USR$DATEBEGIN) AS InYear,
  EXTRACT(MONTH FROM IDK.USR$DATEBEGIN) AS InMonth,
  IDK.USR$DATEBEGIN,
  USR$SICK_PROP AS SickProp
FROM
  USR$GMK_SUMS Z
JOIN
  USR$WG_TOTAL IDK
    ON IDK.DOCUMENTKEY  =  Z.USR$INDOCKEY
WHERE
  Z.USR$EMPLKEY = pEmplKey
  AND
  IDK.USR$DATEBEGIN >= 'pDateCalcFrom'
  AND
  IDK.USR$DATEBEGIN < 'pDateCalcTo'
ORDER BY
  Z.USR$EMPLKEY,
  IDK.USR$DATEBEGIN
",
    [
    pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_sick, wg_avg_wage_avg
        ]).

gd_pl_ds(wg_avg_wage_sick, kb, usr_wg_AvgWage, 6, [
    fAvgType-string,
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer,
    fAvgSumma-float
    ]).
% usr_wg_AvgWage(AvgType, EmplKey, FirstMoveKey, CalYear, CalMonth, AvgSumma)
get_sql(wg_avg_wage_sick, kb, usr_wg_AvgWage/6,
"
SELECT
  'vacation' AS AvgType,
  v.USR$EMPLKEY,
  v.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM vl.USR$DATEBEGIN) AS CalYear,
  EXTRACT(MONTH FROM vl.USR$DATEBEGIN) AS CalMonth,
  v.USR$AVGSUMMA
FROM
  USR$WG_VACATION v
JOIN
  USR$WG_VACATIONLINE vl
    ON vl.MASTERKEY = v.DOCUMENTKEY
WHERE
  v.USR$EMPLKEY = pEmplKey
  AND
  v.USR$FIRSTMOVEKEY = pFirstMoveKey
  AND
  vl.USR$DATEBEGIN >= 'pDateCalcFrom'
  AND
  vl.USR$DATEBEGIN < 'pDateCalcTo'
UNION ALL
SELECT
  'sick' AS AvgType,
  s.USR$EMPLKEY,
  s.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM sl.USR$DATEBEGIN) AS CalYear,
  EXTRACT(MONTH FROM sl.USR$DATEBEGIN) AS CalMonth,
  s.USR$AVGSUMMA
FROM
  USR$WG_SICKLIST s
JOIN
  USR$WG_SICKLISTLINE sl
    ON sl.MASTERKEY = s.DOCUMENTKEY
WHERE
  s.USR$EMPLKEY = pEmplKey
  AND
  s.USR$FIRSTMOVEKEY = pFirstMoveKey
  AND
  sl.USR$DATEBEGIN >= 'pDateCalcFrom'
  AND
  sl.USR$DATEBEGIN < 'pDateCalcTo'
  AND
  NOT s.USR$ILLTYPEKEY = ( SELECT id FROM GD_P_GETID(pJobIllType_ruid) )
UNION ALL
SELECT
  'avg' AS AvgType,
  al.USR$EMPLKEY,
  al.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS CalYear,
  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS CalMonth,
  CASE COALESCE(a.USR$CALCBYHOUR, 0)
    WHEN 1 THEN
      8 * COALESCE(al.USR$AVGSUM, 0)
    ELSE
      COALESCE(al.USR$AVGSUM, 0)
  END
    AS AvgSumma
FROM
  USR$WG_AVGADDPAYLINE al
JOIN
  USR$WG_AVGADDPAY a
    ON a.DOCUMENTKEY = al.MASTERKEY
JOIN
  USR$WG_TOTAL t
    ON t.DOCUMENTKEY = a.USR$TOTALDOCKEY
WHERE
  al.USR$EMPLKEY = pEmplKey
  AND
  al.USR$FIRSTMOVEKEY = pFirstMoveKey
  AND
  t.USR$DATEBEGIN >= 'pDateCalcFrom'
  AND
  t.USR$DATEBEGIN < 'pDateCalcTo'
",
    [
    pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_,
    pJobIllType_ruid-_
    ]).

gd_pl_ds(Scope, kb, usr_wg_FeeTypeProp, 4, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fFeeGroupKeyProp-integer, fFeeTypeKeyProp-integer
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_sick, wg_avg_wage_avg
        ]).
% usr_wg_FeeTypeProp(EmplKey, FirstMoveKey, FeeGroupKeyProp, FeeTypeKeyProp)
get_sql(Scope, kb, usr_wg_FeeTypeProp/4,
"
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  ft.USR$WG_FEEGROUPKEY,
  ft.USR$WG_FEETYPEKEY
FROM
  USR$CROSS179_256548741 ft
JOIN
  USR$WG_FEETYPE ft_avg
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY
WHERE
  ft.USR$WG_FEEGROUPKEY = (SELECT id FROM GD_P_GETID(pFeeGroupKeyProp_ruid))
",
    [
    pEmplKey-_, pFirstMoveKey-_, pFeeGroupKeyProp_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_sick, wg_avg_wage_avg
        ]).

gd_pl_ds(wg_avg_wage_sick, kb, wg_holiday, 1, [
    fHolidayDate-date
    ]).
% wg_holiday(HolidayDate)
get_sql(wg_avg_wage_sick, kb, wg_holiday/1,
"
SELECT
  h.holidaydate
FROM
  wg_holiday h
WHERE
  h.holidaydate BETWEEN 'pDateCalcFrom' AND 'pDateCalcTo'
  AND COALESCE(h.disabled, 0) = 0
",
    [
    pDateCalcFrom-_, pDateCalcTo-_
    ]).

gd_pl_ds(Scope, kb, usr_wg_ExclDays, 8, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fExclType-string, fOrderType-integer, fHourType-integer,
    fExclWeekDay-integer,
    fFromDate-date, fToDate-date
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick
        ]).
% usr_wg_ExclDays(EmplKey, FirstMoveKey, ExclType, OrderType, HourType, ExclWeekDay, FromDate, ToDate)
get_sql(Scope, kb, usr_wg_ExclDays/8,
"
SELECT
  EmplKey, FirstMoveKey, ExclType, OrderType, HourType, ExclWeekDay, FromDate, ToDate
FROM (
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  'LIGHTWORKLINE' AS ExclType,
  0 AS OrderType,
  0 AS HourType,
  0 AS ExclWeekDay,
  CAST( IIF(lw.USR$DATEBEGIN < 'pDateCalcFrom', 'pDateCalcFrom', lw.USR$DATEBEGIN) AS DATE) AS FromDate,
  CAST( IIF(lw.USR$DATEEND IS NULL, 'pDateCalcTo', IIF(lw.USR$DATEEND > 'pDateCalcTo', 'pDateCalcTo', lw.USR$DATEEND)) AS DATE) AS ToDate
FROM USR$WG_LIGHTWORKLINE lw
WHERE lw.USR$FIRSTMOVEKEY = pFirstMoveKey
  AND lw.USR$EMPLKEY = pEmplKey
  AND lw.USR$DATEBEGIN <= 'pDateCalcTo'
  AND COALESCE(lw.USR$DATEEND, 'pDateCalcTo') >= 'pDateCalcFrom'
UNION ALL
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  'LEAVEDOCLINE' AS ExclType,
  t.USR$TYPE AS OrderType,
  t.USR$HOURTYPE AS HourType,
  0 AS ExclWeekDay,
  CAST( IIF(ld.USR$DATEBEGIN < 'pDateCalcFrom', 'pDateCalcFrom', ld.USR$DATEBEGIN) AS DATE) AS FromDate,
  CAST( IIF(ld.USR$DATEEND IS NULL, 'pDateCalcTo', IIF(ld.USR$DATEEND > 'pDateCalcTo', 'pDateCalcTo', ld.USR$DATEEND)) AS DATE) AS ToDate
FROM USR$WG_LEAVEDOCLINE ld
JOIN USR$WG_VACATIONTYPE t ON t.ID = ld.USR$VACATIONTYPEKEY
WHERE ld.USR$FIRSTMOVEKEY = pFirstMoveKey
  AND ld.USR$EMPLKEY = pEmplKey
  AND ld.USR$DATEBEGIN <= 'pDateCalcTo'
  AND COALESCE(ld.USR$DATEEND, 'pDateCalcTo') >= 'pDateCalcFrom'
  AND COALESCE(t.USR$EXCLUDEFORSICKLIST, 0) = 1
UNION ALL
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  'SICKLISTJOURNAL' AS ExclType,
  t.USR$CALCTYPE AS OrderType,
  0 AS HourType,
  0 AS ExclWeekDay,
  CAST( IIF(s.USR$DATEBEGIN < 'pDateCalcFrom', 'pDateCalcFrom', s.USR$DATEBEGIN) AS DATE) AS FromDate,
  CAST( IIF(s.USR$DATEEND IS NULL, 'pDateCalcTo', IIF(s.USR$DATEEND > 'pDateCalcTo', 'pDateCalcTo', s.USR$DATEEND)) AS DATE) AS ToDate
FROM USR$WG_SICKLISTJOURNAL s
JOIN USR$WG_ILLTYPE t ON t.ID = s.USR$ILLTYPEKEY
WHERE s.USR$EMPLKEY = pEmplKey
  AND s.USR$DATEBEGIN <= 'pDateCalcTo'
  AND COALESCE(s.USR$DATEEND, 'pDateCalcTo') >= 'pDateCalcFrom'
UNION ALL
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  'LEAVEEXTDOC' AS ExclType,
  1 AS OrderType,
  0 AS HourType,
  0 AS ExclWeekDay,
  CAST( IIF(ext.USR$DATEBEGIN < 'pDateCalcFrom', 'pDateCalcFrom', ext.USR$DATEBEGIN) AS DATE) AS FromDate,
  CAST( IIF(ext.USR$DATEEND IS NULL, 'pDateCalcTo', IIF(ext.USR$DATEEND > 'pDateCalcTo', 'pDateCalcTo', ext.USR$DATEEND)) AS DATE) AS ToDate
FROM USR$WG_LEAVEEXTDOC ext
WHERE ext.USR$EMPLKEY = pEmplKey
  AND ext.USR$DATEBEGIN <= 'pDateCalcTo'
  AND COALESCE(ext.USR$DATEEND, 'pDateCalcTo') >= 'pDateCalcFrom'
UNION ALL
SELECT
  pEmplKey AS EmplKey,
  pFirstMoveKey AS FirstMoveKey,
  'KINDDAYLINE' AS ExclType,
  0 AS OrderType,
  0 AS HourType,
  kdl.USR$DAY AS ExclWeekDay,
  CAST( IIF(kdl.USR$DATEBEGIN < 'pDateCalcFrom', 'pDateCalcFrom', kdl.USR$DATEBEGIN) AS DATE) AS FromDate,
  CAST( IIF(kdl.USR$DATEEND IS NULL, 'pDateCalcTo', IIF(kdl.USR$DATEEND > 'pDateCalcTo', 'pDateCalcTo', kdl.USR$DATEEND)) AS DATE) AS ToDate
FROM USR$WG_KINDDAYLINE kdl
WHERE kdl.USR$EMPLKEY = pEmplKey
  AND kdl.USR$DATEBEGIN <= 'pDateCalcTo'
  AND COALESCE(kdl.USR$DATEEND, 'pDateCalcTo') >= 'pDateCalcFrom'
)
ORDER BY
  ExclWeekDay,
  FromDate
",
    [
    pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick
        ]).

% twg_struct

gd_pl_ds(wg_struct_vacation, kb, wg_holiday, 1, [
    fHolidayDate-date
    ]).
% wg_holiday(HolidayDate)
get_sql(wg_struct_vacation, kb, wg_holiday/1,
"
SELECT
  h.holidaydate
FROM
  wg_holiday h
WHERE
  h.holidaydate BETWEEN 'pDateBegin' AND 'pDateEnd'
  AND COALESCE(h.disabled, 0) = 0
",
    [
    pDateBegin-_, pDateEnd-_
    ]).

gd_pl_ds(wg_struct_vacation, kb, wg_vacation_slice, 2, [
    fVcType-integer, fSlice-float
    ]).
% wg_vacation_slice(VcType, Slice)
get_sql(wg_struct_vacation, kb, wg_vacation_slice/2,
"
SELECT
  0 AS VcType, COALESCE(USR$DURATION,0) AS Slice
FROM
  USR$WG_VACATION
WHERE
  DOCUMENTKEY = pDocKey
UNION ALL
SELECT
  1 AS VcType, COALESCE(USR$EXTRADURATION,0) AS Slice
FROM
  USR$WG_VACATION
WHERE
  DOCUMENTKEY = pDocKey
/*
UNION ALL
SELECT
  2 AS VcType, COALESCE(USR$UNHEALTHY,0) AS Slice
FROM
  USR$WG_VACATION
WHERE
  DOCUMENTKEY = pDocKey
UNION ALL
SELECT
  3 AS VcType, COALESCE(USR$UNFIXED,0) AS Slice
FROM
  USR$WG_VACATION
WHERE
  DOCUMENTKEY = pDocKey
UNION ALL
SELECT
  4 AS VcType, COALESCE(USR$COMPENSATIONDAY,0) AS Slice
FROM
  USR$WG_VACATION
WHERE
  DOCUMENTKEY = pDocKey
*/
",
    [
    pDocKey-_
    ]).

gd_pl_ds(wg_struct_vacation, kb, wg_vacation_compensation, 3, [
    fDateFrom-integer, fDuration-float, fCompensation-integer
    ]).
% wg_vacation_compensation(DateFrom, Duration, Compensation)
get_sql(wg_struct_vacation, kb, wg_vacation_compensation/3,
"
SELECT
  USR$FROM AS DateFrom,
  COALESCE(USR$DURATION,0) AS Duration,
  COALESCE(USR$COMPENSATION,0) AS Compensation
FROM
  USR$WG_VACATION
WHERE
  DOCUMENTKEY = pDocKey
",
    [
    pDocKey-_
    ]).

gd_pl_ds(wg_struct_sick, kb, gd_const_budget, 2, [
    fConstDate-date, fBudget-float
    ]).
% gd_const_budget(ConstDate, Budget)
get_sql(wg_struct_sick, kb, gd_const_budget/2,
"
SELECT
  cv.CONSTDATE,
  CAST(cv.CONSTVALUE AS DECIMAL(15,4)) AS Budget
FROM
  GD_CONSTVALUE cv
JOIN
  GD_CONST c
    ON c.ID  =  cv.CONSTKEY
WHERE
  cv.CONSTKEY = (SELECT id FROM GD_P_GETID(pBudget_ruid))
ORDER BY
  cv.CONSTDATE
",
    [
    pBudget_ruid-_
    ]).

gd_pl_ds(Scope, kb, gd_const_AvgSalaryRB, 2, [
    fConstDate-date, fAvgSalaryRB-float
    ]) :-
    memberchk(Scope, [
        wg_struct_sick, wg_avg_wage_sick
        ]).
% gd_const_AvgSalaryRB(ConstDate, AvgSalaryRB)
get_sql(Scope, kb, gd_const_AvgSalaryRB/2,
"
SELECT
  cv.CONSTDATE,
  CAST(cv.CONSTVALUE AS DECIMAL(15,4)) AS AvgSalaryRB
FROM
  GD_CONSTVALUE cv
JOIN
  GD_CONST c
    ON c.ID  =  cv.CONSTKEY
WHERE
  cv.CONSTKEY = (SELECT id FROM GD_P_GETID(pAvgSalaryRB_ruid))
ORDER BY
  cv.CONSTDATE
",
    [
    pAvgSalaryRB_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_struct_sick, wg_avg_wage_sick
        ]).

gd_pl_ds(wg_struct_sick, kb, usr_wg_TblDayNorm, 8, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fWYear-integer, fWMonth-integer, fTheDay-date, fWDay-integer,
    fWDuration-float, fWorkDay-integer
    ]).
% usr_wg_TblDayNorm(EmplKey, FirstMoveKey, WYear, WMonth, TheDay, WDay, WDuration, WorkDay)
get_sql(wg_struct_sick, kb, usr_wg_TblDayNorm/8,
"
SELECT EmplKey, FirstMoveKey, WYear, WMonth, TheDay, WDay, WDuration, WorkDay
FROM USR$WG_TBLCALDAY_P(pEmplKey, pFirstMoveKey, 'pDateCalcFrom', 'pDateCalcTo')
",
    [
    pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_
    ]).

gd_pl_ds(Scope, kb, wg_job_ill_type, 1, [
    fJobIllType-integer
    ]) :-
    memberchk(Scope, [
        wg_struct_sick, wg_avg_wage_sick
        ]).
% wg_job_ill_type(ID)
get_sql(Scope, kb, wg_job_ill_type/1,
"
SELECT id FROM GD_P_GETID(pJobIllType_ruid)
",
    [
    pJobIllType_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_struct_sick, wg_avg_wage_sick
        ]).

gd_pl_ds(Scope, kb, wg_child_ill_type, 1, [
    fChildIllType-integer
    ]) :-
    memberchk(Scope, [
        wg_struct_sick
        ]).
% wg_child_ill_type(ID)
get_sql(Scope, kb, wg_child_ill_type/1,
"
SELECT id FROM GD_P_GETID(pChildIllType_ruid)
",
    [
    pChildIllType_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_struct_sick
        ]).

gd_pl_ds(Scope, kb, usr_wg_pl_Rule, 2, [
    fAtom-string, fEnabled-boolean
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg
        ]).
% usr_wg_pl_Rule(Atom, Enabled)
get_sql(Scope, kb, usr_wg_pl_Rule/2,
"
SELECT
  r.USR$ATOM,
  r.USR$ENABLED
FROM
  USR$WG_PL_RULE r
WHERE
  NOT r.USR$ATOM IS NULL
ORDER BY
  r.PARENT,
  r.USR$ORDER
",
    [
    ]) :-
    memberchk(Scope, [
        wg_avg_wage_vacation, wg_avg_wage_sick, wg_avg_wage_avg
        ]).

 %
%%

