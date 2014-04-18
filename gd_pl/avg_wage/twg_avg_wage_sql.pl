% twg_avg_wage_sql

:-
    GetSQL = [gd_pl_ds/5, get_sql/5],
    %dynamic(GetSQL),
    multifile(GetSQL),
    discontiguous(GetSQL).

%
wg_valid_sql([
            %  05. Начисление отпусков
            -usr_wg_DbfSums/6, % 05, 06
            usr_wg_MovementLine/15, % 05, 06
            usr_wg_FCRate/4,
            usr_wg_TblCalDay/9, % 05, 06
            -usr_wg_TblDayNorm/8, % 05, 06
            -usr_wg_TblYearNorm/5,
            usr_wg_TblCalLine/7, % 05, 06
            usr_wg_TblCal_FlexLine/68, % 05, 06
            usr_wg_HourType/12, % 05, 06
            usr_wg_TblCharge/9, % 05, 06
            usr_wg_FeeType/5, % 05, 06
            usr_wg_FeeTypeNoCoef/4,
            usr_wg_BadHourType/3,
            usr_wg_BadFeeType/3,
            usr_wg_SpecDep/3,
            %  06. Начисление больничных
            usr_wg_FeeTypeProp/4,
            wg_holiday/1,
            usr_wg_ExclDays/6,
            gd_const_AvgSalaryRB/2,
            % twg_struct
            %wg_holiday/1,
            wg_vacation_slice/2,
            gd_const_budget/2,
            -usr_wg_TblDayNorm/8,
            wg_job_ill_type/1,
            -
            ]).

%
is_valid_sql(Functor/Arity) :-
    wg_valid_sql(ValidSQL),
    member(Functor/Arity, ValidSQL),
    !.

%  05. Начисление отпусков
gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_DbfSums, 6,
    [
    fEmplKey-integer, fInSum-float, fInHoures-float,
    fInYear-integer, fInMonth-integer, fDateBegin-date
    ]).
% usr_wg_DbfSums(EmplKey, InSum, InHoures, InYear, InMonth, DateBegin)
get_sql(wg_avg_wage_vacation, in, usr_wg_DbfSums/6,
"SELECT \c
  Z.USR$EMPLKEY, \c
  COALESCE(Z.USR$SUM, 0) AS INSUM, \c
  COALESCE(Z.USR$MID_HOW, 0) AS INHOURES, \c
  EXTRACT(YEAR FROM IDK.USR$DATEBEGIN) AS InYear, \c
  EXTRACT(MONTH FROM IDK.USR$DATEBEGIN) AS InMonth, \c
  IDK.USR$DATEBEGIN \c
FROM \c
  USR$GMK_SUMS Z \c
JOIN \c
  USR$WG_TOTAL IDK \c
    ON IDK.DOCUMENTKEY  =  Z.USR$INDOCKEY \c
WHERE \c
  Z.USR$EMPLKEY = pEmplKey \c
  AND \c
  IDK.USR$DATEBEGIN >= \'pDateCalcFrom\' \c
  AND \c
  IDK.USR$DATEBEGIN < \'pDateCalcTo\' \c
ORDER BY \c
  Z.USR$EMPLKEY, \c
  IDK.USR$DATEBEGIN \c
",
[pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ).

gd_pl_ds(Scope, in, usr_wg_MovementLine, 15,
    [
    fEmplKey-integer, fDocumentKey-integer, fFirstMoveKey-integer,
    fMoveYear-integer, fMoveMonth-integer, fDateBegin-date,
    fScheduleKey-integer, fMovementType-integer,
    fRate-float, fListNumber-string, fMSalary-float,
    fPayFormKey-integer, fSalaryKey-integer, fTSalary-float, fAvgWageRate-float
    ]) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick, wg_struct_sick]) ).
% usr_wg_MovementLine(EmplKey, DocumentKey, FirstMoveKey,
%   MoveYear, MoveMonth, DateBegin,
%   ScheduleKey, MovementType, Rate, ListNumber, MSalary,
%   PayFormKey, SalaryKey, TSalary, AvgWageRate)
get_sql(Scope, in, usr_wg_MovementLine/15,
"SELECT \c
  ml.USR$EMPLKEY, \c
  ml.DOCUMENTKEY, \c
  ml.USR$FIRSTMOVE AS FirstMoveKey, \c
  EXTRACT(YEAR FROM ml.USR$DATEBEGIN) AS MoveYear, \c
  EXTRACT(MONTH FROM ml.USR$DATEBEGIN) AS MoveMonth, \c
  ml.USR$DATEBEGIN, \c
  ml.USR$SCHEDULEKEY, \c
  ml.USR$MOVEMENTTYPE, \c
  COALESCE(ml.USR$RATE, 0) AS Rate, \c
  ml.USR$LISTNUMBER, \c
  COALESCE(ml.USR$MSALARY, 0) AS MSalary, \c
  COALESCE(ml.USR$PAYFORMKEY, 0) AS PayFormKey, \c
  (SELECT id FROM gd_ruid WHERE xid = pPayFormSalary_xid AND dbid = pPayFormSalary_dbid) AS SalaryKey, \c
  COALESCE(ml.USR$TSALARY, 0) AS TSalary, \c
  8 * COALESCE(USR$THOURRATE, 0) AS AvgWageRate \c
FROM \c
  USR$WG_MOVEMENTLINE ml \c
WHERE \c
  ml.USR$EMPLKEY = pEmplKey \c
  AND \c
  ml.USR$FIRSTMOVE = pFirstMoveKey \c
ORDER BY \c
  ml.USR$EMPLKEY, \c
  ml.USR$FIRSTMOVE, \c
  ml.USR$DATEBEGIN \c
",
[pEmplKey-_, pFirstMoveKey-_, pPayFormSalary_xid-_, pPayFormSalary_dbid-_]
    ) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick, wg_struct_sick]) ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_FCRate, 4,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fDate-date, fFCRateSum-float
    ]).
% usr_wg_FCRate(EmplKey, FirstMoveKey, Date, FCRateSum)
get_sql(wg_avg_wage_vacation, in, usr_wg_FCRate/4,
"SELECT \c
  pEmplKey AS EmplKey, \c
  pFirstMoveKey AS FirstMoveKey, \c
  fc.USR$WG_DATE, \c
  fc.USR$WG_FCRATESUM \c
FROM \c
  USR$WG_FCRATE fc \c
ORDER BY \c
  fc.USR$WG_DATE \c
",
[pEmplKey-_, pFirstMoveKey-_]
    ).

gd_pl_ds(Scope, in, usr_wg_TblCalDay, 9,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fTheDay-date, fWYear-integer, fWMonth-integer, fWDay-integer,
    fWDuration-float, fWorkDay-integer, fScheduleKey-integer
    ]) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick, wg_struct_sick]) ).
% usr_wg_TblCalDay(EmplKey, FirstMoveKey, TheDay, WYear, WMonth, WDay,
%    WDuration, WorkDay, ScheduleKey)
get_sql(Scope, in, usr_wg_TblCalDay/9,
"SELECT \c
  ml.USR$EMPLKEY, \c
  ml.USR$FIRSTMOVE AS FirstMoveKey, \c
  tcd.THEDAY, \c
  EXTRACT(YEAR FROM tcd.THEDAY) AS WYEAR, \c
  EXTRACT(MONTH FROM tcd.THEDAY) AS WMONTH, \c
  EXTRACT(DAY FROM tcd.THEDAY) AS WDAY, \c
  tcd.WDURATION, \c
  tcd.WORKDAY, \c
  ml.USR$SCHEDULEKEY \c
FROM \c
( \c
SELECT DISTINCT \c
  USR$EMPLKEY, \c
  USR$FIRSTMOVE, \c
  USR$SCHEDULEKEY \c
FROM \c
  USR$WG_MOVEMENTLINE \c
WHERE \c
  USR$EMPLKEY = pEmplKey \c
  AND \c
  USR$FIRSTMOVE = pFirstMoveKey \c
) ml \c
JOIN \c
  WG_TBLCAL tc \c
    ON tc.ID = ml.USR$SCHEDULEKEY \c
JOIN \c
  WG_TBLCALDAY tcd \c
    ON tcd.TBLCALKEY = tc.ID \c
WHERE \c
  COALESCE(tcd.WDURATION, 0) > 0 \c
  AND \c
  (tcd.THEDAY >= \'pDateCalcFrom\' OR tcd.THEDAY >= \'pDateNormFrom\') \c
  AND \c
  (tcd.THEDAY < \'pDateCalcTo\' OR tcd.THEDAY < \'pDateNormTo\') \c
ORDER BY \c
  tcd.THEDAY \c
",
[pEmplKey-_, pFirstMoveKey-_,
 pDateCalcFrom-_, pDateCalcTo-_,
 pDateNormFrom-_, pDateNormTo-_
]
    ) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick, wg_struct_sick]) ).

gd_pl_ds(Scope, in, usr_wg_TblDayNorm, 8,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fWYear-integer, fWMonth-integer, fTheDay-date, fWDay-integer,
    fWDuration-float, fWorkDay-integer
    ]) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick]) ).
% usr_wg_TblDayNorm(EmplKey, FirstMoveKey, WYear, WMonth, TheDay, WDay, WDuration, WorkDay)
get_sql(Scope, in, usr_wg_TblDayNorm/8,
"\c
SELECT EmplKey, FirstMoveKey, WYear, WMonth, TheDay, WDay, WDuration, WorkDay \c
FROM USR$WG_TBLCALDAY_P(pEmplKey, pFirstMoveKey, \'pDateCalcFrom\', \'pDateCalcTo\') \c
",
[pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick]) ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_TblYearNorm, 5,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fWYear-integer,
    fWHoures-float, fWDays-integer
    ]).
% usr_wg_TblYearNorm(EmplKey, FirstMoveKey, WYear, WHoures, WDays)
get_sql(wg_avg_wage_vacation, in, usr_wg_TblYearNorm/5,
"\c
SELECT EmplKey, FirstMoveKey, WYear, SUM(WDuration) AS WHoures, SUM(WorkDay) AS WDays \c
FROM USR$WG_TBLCALDAY_P(pEmplKey, pFirstMoveKey, \'pDateNormFrom\', \'pDateNormTo\') \c
GROUP BY EmplKey, FirstMoveKey, WYear \c
",
[pEmplKey-_, pFirstMoveKey-_, pDateNormFrom-_, pDateNormTo-_]
    ).

gd_pl_ds(Scope, in, usr_wg_TblCalLine, 7,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDate-date,
    fDuration-float, fHoureType-integer
    ]) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick]) ).
% usr_wg_TblCalLine(EmplKey, FirstMoveKey, CalYear, CalMonth, Date, Duration, HoureType)
get_sql(Scope, in, usr_wg_TblCalLine/7,
"SELECT \c
  tc.USR$EMPLKEY, \c
  tc.USR$FIRSTMOVEKEY, \c
  EXTRACT(YEAR FROM tcl.USR$DATE) AS CalYear, \c
  EXTRACT(MONTH FROM tcl.USR$DATE) AS CalMonth, \c
  tcl.USR$DATE, \c
  tcl.USR$DURATION, \c
  tcl.USR$HOURTYPE \c
FROM \c
  USR$WG_TBLCAL tc \c
JOIN \c
  USR$WG_TBLCALLINE tcl \c
    ON tcl.MASTERKEY = tc.DOCUMENTKEY \c
WHERE \c
  tc.USR$EMPLKEY = pEmplKey \c
  AND \c
  tc.USR$FIRSTMOVEKEY = pFirstMoveKey \c
  AND \c
  tcl.USR$DATE >= \'pDateCalcFrom\' \c
  AND \c
  tcl.USR$DATE < \'pDateCalcTo\' \c
ORDER BY \c
  tc.USR$EMPLKEY, \c
  tc.USR$FIRSTMOVEKEY, \c
  tcl.USR$DATE \c
",
[pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick]) ).

gd_pl_ds(Scope, in, usr_wg_TblCal_FlexLine, 68,
    [fFlexType-string,
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
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick, wg_struct_sick]) ).
% usr_wg_TblCal_FlexLine(FlexType, EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, S1, H1, ..., S31, H31)
get_sql(Scope, in, usr_wg_TblCal_FlexLine/68,
"SELECT \c
  CASE gd.DOCUMENTTYPEKEY \c
    WHEN \c
      (SELECT id FROM gd_ruid \c
      WHERE xid = pTblCal_DocType_Plan_xid AND dbid = pTblCal_DocType_Plan_dbid) \c
        THEN \'plan\' \c
    WHEN \c
      (SELECT id FROM gd_ruid \c
      WHERE xid = pTblCal_DocType_Fact_xid AND dbid = pTblCal_DocType_Fact_dbid) \c
        THEN \'fact\' \c
    ELSE \c
        \'unknown\' \c
  END \c
    AS FlexType, \c
  tcfl.USR$EMPLKEY, \c
  tcfl.USR$FIRSTMOVEKEY, \c
  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS CalYear, \c
  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS CalMonth, \c
  t.USR$DATEBEGIN, \c
  tcfl.USR$S1, tcfl.USR$H1, tcfl.USR$S2, tcfl.USR$H2, \c
  tcfl.USR$S3, tcfl.USR$H3, tcfl.USR$S4, tcfl.USR$H4, \c
  tcfl.USR$S5, tcfl.USR$H5, tcfl.USR$S6, tcfl.USR$H6, \c
  tcfl.USR$S7, tcfl.USR$H7, tcfl.USR$S8, tcfl.USR$H8, \c
  tcfl.USR$S9, tcfl.USR$H9, tcfl.USR$S10, tcfl.USR$H10, \c
  tcfl.USR$S11, tcfl.USR$H11, tcfl.USR$S12, tcfl.USR$H12, \c
  tcfl.USR$S13, tcfl.USR$H13, tcfl.USR$S14, tcfl.USR$H14, \c
  tcfl.USR$S15, tcfl.USR$H15, tcfl.USR$S16, tcfl.USR$H16, \c
  tcfl.USR$S17, tcfl.USR$H17, tcfl.USR$S18, tcfl.USR$H18, \c
  tcfl.USR$S19, tcfl.USR$H19, tcfl.USR$S20, tcfl.USR$H20, \c
  tcfl.USR$S21, tcfl.USR$H21, tcfl.USR$S22, tcfl.USR$H22, \c
  tcfl.USR$S23, tcfl.USR$H23, tcfl.USR$S24, tcfl.USR$H24, \c
  tcfl.USR$S25, tcfl.USR$H25, tcfl.USR$S26, tcfl.USR$H26, \c
  tcfl.USR$S27, tcfl.USR$H27, tcfl.USR$S28, tcfl.USR$H28, \c
  tcfl.USR$S29, tcfl.USR$H29, tcfl.USR$S30, tcfl.USR$H30, \c
  tcfl.USR$S31, tcfl.USR$H31 \c
FROM \c
  GD_DOCUMENT gd \c
JOIN \c
  USR$WG_TBLCAL_FLEXLINE tcfl \c
    ON gd.ID = tcfl.DOCUMENTKEY \c
JOIN \c
  USR$WG_TBLCAL_FLEX tcf \c
    ON tcf.DOCUMENTKEY = tcfl.MASTERKEY \c
JOIN \c
  USR$WG_TOTAL t \c
    ON t.DOCUMENTKEY = tcf.USR$TOTALDOCKEY \c
WHERE \c
  tcfl.USR$EMPLKEY = pEmplKey \c
  AND \c
  tcfl.USR$FIRSTMOVEKEY = pFirstMoveKey \c
  AND \c
  t.USR$DATEBEGIN >= \'pDateCalcFrom\' \c
  AND \c
  t.USR$DATEBEGIN < \'pDateCalcTo\' \c
 ORDER BY \c
   tcfl.USR$EMPLKEY, \c
   tcfl.USR$FIRSTMOVEKEY, \c
   t.USR$DATEBEGIN \c
",
[pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_,
pTblCal_DocType_Plan_xid-_, pTblCal_DocType_Plan_dbid-_,
pTblCal_DocType_Fact_xid-_, pTblCal_DocType_Fact_dbid-_
]
    ) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick, wg_struct_sick]) ).

gd_pl_ds(Scope, in, usr_wg_HourType, 12,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fID-integer, fCode-string, fDigitCode-string,
    fDiscription-string, fIsWorked-integer, fShortName-string,
    fForCalFlex-integer, fForOverTime-integer, fForFlex-integer,
    fExcludeForSickList-integer
    ]) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick]) ).
% usr_wg_HourType(EmplKey, FirstMoveKey,
%   ID, Code, DigitCode, Description, IsWorked, ShortName,
%   ForCalFlex, ForOverTime, ForFlex, ExcludeForSickList)
get_sql(Scope, in, usr_wg_HourType/12,
"SELECT \c
  pEmplKey AS EmplKey, \c
  pFirstMoveKey AS FirstMoveKey, \c
  ht.ID, \c
  ht.USR$CODE, \c
  ht.USR$DIGITCODE, \c
  ht.USR$DISCRIPTION \c,
  ht.USR$ISWORKED, \c
  ht.USR$SHORTNAME, \c
  ht.USR$FORCALFLEX, \c
  ht.USR$FOROVERTIME, \c
  ht.USR$FORFLEX, \c
  ht.USR$WG_EXCLUDEFORSICKLIST \c
FROM \c
  USR$WG_HOURTYPE ht \c
",
[pEmplKey-_, pFirstMoveKey-_]
    ) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick]) ).

gd_pl_ds(Scope, in, usr_wg_TblCharge, 9,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fDebit-float, fFeeTypeKey-integer, fDOW-float, fHOW-float
    ]) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick]) ).
% usr_wg_TblCharge(EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin,
%   Debit, FeeTypeKey, DOW, HOW)
get_sql(Scope, in, usr_wg_TblCharge/9,
"SELECT \c
  tch.USR$EMPLKEY, \c
  tch.USR$FIRSTMOVEKEY, \c
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, \c
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, \c
  tch.USR$DATEBEGIN, \c
  tch.USR$DEBIT, \c
  tch.USR$FEETYPEKEY, \c
  tch.USR$DOW, \c
  tch.USR$HOW \c
FROM \c
  USR$WG_TBLCHARGE tch \c
WHERE \c
  tch.USR$EMPLKEY = pEmplKey \c
  AND \c
  NOT tch.USR$DEBIT = 0 \c
  AND \c
  tch.USR$DATEBEGIN >= \'pDateCalcFrom\' \c
  AND \c
  tch.USR$DATEBEGIN < \'pDateCalcTo\' \c
ORDER BY \c
  tch.USR$EMPLKEY, \c
  tch.USR$DATEBEGIN \c
",
[pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick]) ).

gd_pl_ds(Scope, in, usr_wg_FeeType, 5,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fFeeGroupKey-integer, fFeeTypeKey-integer, fAvgDayHOW-integer
    ]) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick]) ).
% usr_wg_FeeType(EmplKey, FirstMoveKey, FeeGroupKey, FeeTypeKey, AvgDayHOW)
get_sql(Scope, in, usr_wg_FeeType/5,
"SELECT \c
  pEmplKey AS EmplKey,  \c
  pFirstMoveKey AS FirstMoveKey, \c
  ft.USR$WG_FEEGROUPKEY, \c
  ft.USR$WG_FEETYPEKEY, \c
  ft_avg.USR$AVGDAYHOW \c
FROM \c
  USR$CROSS179_256548741 ft \c
JOIN \c
  USR$WG_FEETYPE ft_avg \c
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY \c
WHERE \c
  ft.USR$WG_FEEGROUPKEY IN \c
(SELECT id FROM gd_ruid \c
WHERE xid = pFeeGroupKey_xid \c
AND dbid = pFeeGroupKey_dbid \c
) \c
",
[pEmplKey-_, pFirstMoveKey-_, pFeeGroupKey_xid-_, pFeeGroupKey_dbid-_]
    ) :-
    once( member(Scope, [wg_avg_wage_vacation, wg_avg_wage_sick]) ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_FeeTypeNoCoef, 4,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fFeeGroupKeyNoCoef-integer, fFeeTypeKeyNoCoef-integer
    ]).
% usr_wg_FeeTypeNoCoef(EmplKey, FirstMoveKey, FeeGroupKeyNoCoef, FeeTypeKeyNoCoef)
get_sql(wg_avg_wage_vacation, in, usr_wg_FeeTypeNoCoef/4,
"SELECT \c
  pEmplKey AS EmplKey,  \c
  pFirstMoveKey AS FirstMoveKey, \c
  ft.USR$WG_FEEGROUPKEY, \c
  ft.USR$WG_FEETYPEKEY \c
FROM \c
  USR$CROSS179_256548741 ft \c
JOIN \c
  USR$WG_FEETYPE ft_avg \c
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY \c
WHERE \c
  ft.USR$WG_FEEGROUPKEY IN \c
(SELECT id FROM gd_ruid \c
WHERE xid = pFeeGroupKeyNoCoef_xid \c
AND dbid = pFeeGroupKeyNoCoef_dbid \c
) \c
",
[pEmplKey-_, pFirstMoveKey-_, pFeeGroupKeyNoCoef_xid-_, pFeeGroupKeyNoCoef_dbid-_]
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_BadHourType, 3,
    [
    fEmplKey-integer, fFirstMoveKey-integer, fID-integer
    ]).
% usr_wg_BadHourType(EmplKey, FirstMoveKey, ID)
get_sql(wg_avg_wage_vacation, in, usr_wg_BadHourType/3,
"SELECT \c
  pEmplKey AS EmplKey, pFirstMoveKey AS FirstMoveKey, id \c
FROM USR$WG_HOURTYPE \c
WHERE id IN \c
(SELECT id FROM gd_ruid \c
WHERE xid IN (pBadHourType_xid_IN) \c
AND dbid = pBadHourType_dbid \c
) \c
",
[pEmplKey-_, pFirstMoveKey-_, pBadHourType_xid_IN-_, pBadHourType_dbid-_]
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_BadFeeType, 3,
    [
    fEmplKey-integer, fFirstMoveKey-integer, fID-integer
    ]).
% usr_wg_BadFeeType(EmplKey, FirstMoveKey, ID)
get_sql(wg_avg_wage_vacation, in, usr_wg_BadFeeType/3,
"SELECT \c
  pEmplKey AS EmplKey, pFirstMoveKey AS FirstMoveKey, id \c
FROM USR$WG_FEETYPE \c
WHERE id IN \c
(SELECT id FROM gd_ruid \c
WHERE xid IN (pBadFeeType_xid_IN) \c
AND dbid = pBadFeeType_dbid \c
) \c
",
[pEmplKey-_, pFirstMoveKey-_, pBadFeeType_xid_IN-_, pBadFeeType_dbid-_]
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_SpecDep, 3,
    [
    fEmplKey-integer, fFirstMoveKey-integer, fID-integer
    ]).
% usr_wg_SpecDep(EmplKey, FirstMoveKey, ID)
get_sql(wg_avg_wage_vacation, in, usr_wg_SpecDep/3,
"SELECT \c
  pEmplKey AS EmplKey, pFirstMoveKey AS FirstMoveKey, id \c
FROM \c
  gd_ruid \c
WHERE \c
  xid = pSpecDep_xid AND dbid = pSpecDep_dbid \c
",
[pEmplKey-_, pFirstMoveKey-_, pSpecDep_xid-_, pSpecDep_dbid-_]
    ).

%  06. Начисление больничных
gd_pl_ds(wg_avg_wage_sick, in, usr_wg_DbfSums, 6,
    [
    fEmplKey-integer, fInSum-float, fInHoures-float,
    fInYear-integer, fInMonth-integer, fDateBegin-date
    ]).
% usr_wg_DbfSums(EmplKey, InSum, InHoures, InYear, InMonth, DateBegin)
get_sql(wg_avg_wage_sick, in, usr_wg_DbfSums/6,
"SELECT \c
  Z.USR$EMPLKEY, \c
  COALESCE(Z.USR$SUMSICK, 0) AS INSUM, \c
  COALESCE(Z.USR$MID_HOW, 0) AS INHOURES, \c
  EXTRACT(YEAR FROM IDK.USR$DATEBEGIN) AS InYear, \c
  EXTRACT(MONTH FROM IDK.USR$DATEBEGIN) AS InMonth, \c
  IDK.USR$DATEBEGIN \c
FROM \c
  USR$GMK_SUMS Z \c
JOIN \c
  USR$WG_TOTAL IDK \c
    ON IDK.DOCUMENTKEY  =  Z.USR$INDOCKEY \c
WHERE \c
  Z.USR$EMPLKEY = pEmplKey \c
  AND \c
  IDK.USR$DATEBEGIN >= \'pDateCalcFrom\' \c
  AND \c
  IDK.USR$DATEBEGIN < \'pDateCalcTo\' \c
ORDER BY \c
  Z.USR$EMPLKEY, \c
  IDK.USR$DATEBEGIN \c
",
[pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ).

gd_pl_ds(wg_avg_wage_sick, in, usr_wg_FeeTypeProp, 4,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fFeeGroupKeyProp-integer, fFeeTypeKeyProp-integer
    ]).
% usr_wg_FeeTypeProp(EmplKey, FirstMoveKey, FeeGroupKeyProp, FeeTypeKeyProp)
get_sql(wg_avg_wage_sick, in, usr_wg_FeeTypeProp/4,
"SELECT \c
  pEmplKey AS EmplKey, \c
  pFirstMoveKey AS FirstMoveKey, \c
  ft.USR$WG_FEEGROUPKEY, \c
  ft.USR$WG_FEETYPEKEY \c
FROM \c
  USR$CROSS179_256548741 ft \c
JOIN \c
  USR$WG_FEETYPE ft_avg \c
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY \c
WHERE \c
  ft.USR$WG_FEEGROUPKEY IN \c
(SELECT id FROM gd_ruid \c
WHERE xid = pFeeGroupKeyProp_xid \c
AND dbid = pFeeGroupKeyProp_dbid \c
) \c
",
[pEmplKey-_, pFirstMoveKey-_, pFeeGroupKeyProp_xid-_, pFeeGroupKeyProp_dbid-_]
    ).

gd_pl_ds(wg_avg_wage_sick, in, wg_holiday, 1, [fHolidayDate-date]).
% wg_holiday(HolidayDate)
get_sql(wg_avg_wage_sick, in, wg_holiday/1,
"SELECT \c
  h.holidaydate \c
FROM \c
  wg_holiday h \c
WHERE \c
  h.holidaydate BETWEEN \'pDateCalcFrom\' AND \'pDateCalcTo\' \c
  AND COALESCE(h.disabled, 0) = 0 \c
",
[pDateCalcFrom-_, pDateCalcTo-_]
    ).

gd_pl_ds(wg_avg_wage_sick, in, usr_wg_ExclDays, 6,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fExclType-string, fExclWeekDay-integer,
    fFromDate-date, fToDate-date
    ]).
% usr_wg_ExclDays(EmplKey, FirstMoveKey, ExclType, ExclWeekDay, FromDate, ToDate)
get_sql(wg_avg_wage_sick, in, usr_wg_ExclDays/6,
"SELECT \c
  EmplKey, FirstMoveKey, ExclType, ExclWeekDay, FromDate, ToDate \c
FROM ( \c
SELECT \c
  pEmplKey AS EmplKey, \c
  pFirstMoveKey AS FirstMoveKey, \c
  \'LIGHTWORKLINE\' AS ExclType, \c
  0 AS ExclWeekDay, \c
  CAST( IIF(lw.USR$DATEBEGIN < \'pDateCalcFrom\', \'pDateCalcFrom\', lw.USR$DATEBEGIN) AS DATE) AS FromDate, \c
  CAST( IIF(lw.USR$DATEEND IS NULL, \'pDateCalcTo\', IIF(lw.USR$DATEEND > \'pDateCalcTo\', \'pDateCalcTo\', lw.USR$DATEEND)) AS DATE) AS ToDate \c
FROM USR$WG_LIGHTWORKLINE lw \c
WHERE lw.USR$FIRSTMOVEKEY = pFirstMoveKey \c
  AND lw.USR$EMPLKEY = pEmplKey \c
  AND lw.USR$DATEBEGIN <= \'pDateCalcTo\' \c
  AND COALESCE(lw.USR$DATEEND, \'pDateCalcTo\') >= \'pDateCalcFrom\' \c
UNION ALL \c
SELECT \c
  pEmplKey AS EmplKey, \c
  pFirstMoveKey AS FirstMoveKey, \c
  \'LEAVEDOCLINE\' AS ExclType, \c
  0 AS ExclWeekDay, \c
  CAST( IIF(ld.USR$DATEBEGIN < \'pDateCalcFrom\', \'pDateCalcFrom\', ld.USR$DATEBEGIN) AS DATE) AS FromDate, \c
  CAST( IIF(ld.USR$DATEEND IS NULL, \'pDateCalcTo\', IIF(ld.USR$DATEEND > \'pDateCalcTo\', \'pDateCalcTo\', ld.USR$DATEEND)) AS DATE) AS ToDate \c
FROM USR$WG_LEAVEDOCLINE ld \c
LEFT JOIN USR$WG_VACATIONTYPE t ON t.ID = ld.USR$VACATIONTYPEKEY \c
WHERE ld.USR$FIRSTMOVEKEY = pFirstMoveKey \c
  AND ld.USR$EMPLKEY = pEmplKey \c
  AND ld.USR$DATEBEGIN <= \'pDateCalcTo\' \c
  AND COALESCE(ld.USR$DATEEND, \'pDateCalcTo\') >= \'pDateCalcFrom\' \c
  AND COALESCE(t.USR$EXCLUDEFORSICKLIST, 0) = 1 \c
UNION ALL \c
SELECT \c
  pEmplKey AS EmplKey, \c
  pFirstMoveKey AS FirstMoveKey, \c
  \'SICKLISTJOURNAL\' AS ExclType, \c
  0 AS ExclWeekDay, \c
  CAST( IIF(s.USR$DATEBEGIN < \'pDateCalcFrom\', \'pDateCalcFrom\', s.USR$DATEBEGIN) AS DATE) AS FromDate, \c
  CAST( IIF(s.USR$DATEEND IS NULL, \'pDateCalcTo\', IIF(s.USR$DATEEND > \'pDateCalcTo\', \'pDateCalcTo\', s.USR$DATEEND)) AS DATE) AS ToDate \c
FROM USR$WG_SICKLISTJOURNAL s \c
WHERE s.USR$EMPLKEY = pEmplKey \c
  AND s.USR$DATEBEGIN <= \'pDateCalcTo\' \c
  AND COALESCE(s.USR$DATEEND, \'pDateCalcTo\') >= \'pDateCalcFrom\' \c
UNION ALL \c
SELECT \c
  pEmplKey AS EmplKey, \c
  pFirstMoveKey AS FirstMoveKey, \c
  \'LEAVEEXTDOC\' AS ExclType, \c
  0 AS ExclWeekDay, \c
  CAST( IIF(ext.USR$DATEBEGIN < \'pDateCalcFrom\', \'pDateCalcFrom\', ext.USR$DATEBEGIN) AS DATE) AS FromDate, \c
  CAST( IIF(ext.USR$DATEEND IS NULL, \'pDateCalcTo\', IIF(ext.USR$DATEEND > \'pDateCalcTo\', \'pDateCalcTo\', ext.USR$DATEEND)) AS DATE) AS ToDate \c
FROM USR$WG_LEAVEEXTDOC ext \c
WHERE ext.USR$EMPLKEY = pEmplKey \c
  AND ext.USR$DATEBEGIN <= \'pDateCalcTo\' \c
  AND COALESCE(ext.USR$DATEEND, \'pDateCalcTo\') >= \'pDateCalcFrom\' \c
UNION ALL \c
SELECT \c
  pEmplKey AS EmplKey, \c
  pFirstMoveKey AS FirstMoveKey, \c
  \'KINDDAYLINE\' AS ExclType, \c
  kdl.USR$DAY AS ExclWeekDay, \c
  CAST( IIF(kdl.USR$DATEBEGIN < \'pDateCalcFrom\', \'pDateCalcFrom\', kdl.USR$DATEBEGIN) AS DATE) AS FromDate, \c
  CAST( IIF(kdl.USR$DATEEND IS NULL, \'pDateCalcTo\', IIF(kdl.USR$DATEEND > \'pDateCalcTo\', \'pDateCalcTo\', kdl.USR$DATEEND)) AS DATE) AS ToDate \c
FROM USR$WG_KINDDAYLINE kdl \c
WHERE kdl.USR$EMPLKEY = pEmplKey \c
  AND kdl.USR$DATEBEGIN <= \'pDateCalcTo\' \c
  AND COALESCE(kdl.USR$DATEEND, \'pDateCalcTo\') >= \'pDateCalcFrom\' \c
) \c
ORDER BY \c
  ExclWeekDay, \c
  FromDate \c
",
[pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ).

gd_pl_ds(wg_avg_wage_sick, in, gd_const_AvgSalaryRB, 2, [fConstDate-date, fAvgSalaryRB-float]).
% gd_const_AvgSalaryRB(ConstDate, AvgSalaryRB)
get_sql(wg_avg_wage_sick, in, gd_const_AvgSalaryRB/2,
"SELECT \c
  cv.CONSTDATE, \c
  CAST(cv.CONSTVALUE AS DECIMAL(15,4)) AS AvgSalaryRB \c
FROM \c
  GD_CONSTVALUE cv \c
JOIN \c
  GD_CONST c \c
    ON c.ID  =  cv.CONSTKEY \c
WHERE \c
  cv.CONSTKEY = \c
  (SELECT id FROM gd_ruid WHERE xid = pAvgSalaryRB_xid AND dbid = pAvgSalaryRB_dbid) \c
ORDER BY \c
  cv.CONSTDATE \c
",
[pAvgSalaryRB_xid-_, pAvgSalaryRB_dbid-_]
    ).

% twg_struct

gd_pl_ds(wg_struct_vacation, in, wg_holiday, 1, [fHolidayDate-date]).
% wg_holiday(HolidayDate)
get_sql(wg_struct_vacation, in, wg_holiday/1,
"SELECT \c
  h.holidaydate \c
FROM \c
  wg_holiday h \c
WHERE \c
  h.holidaydate BETWEEN \'pDateBegin\' AND \'pDateEnd\' \c
  AND COALESCE(h.disabled, 0) = 0 \c
",
[pDateBegin-_, pDateEnd-_]
    ).

gd_pl_ds(wg_struct_vacation, in, wg_vacation_slice, 2,
    [
    fVcType-integer, fSlice-float
    ]).
% wg_vacation_slice(VcType, Slice)
get_sql(wg_struct_vacation, in, wg_vacation_slice/2,
"SELECT \c
  0 AS VcType, COALESCE(USR$DURATION,0) AS Slice \c
FROM \c
  USR$WG_VACATION \c
WHERE \c
  DOCUMENTKEY = pDocKey \c
UNION ALL \c
SELECT \c
  1 AS VcType, COALESCE(USR$EXTRADURATION,0) AS Slice \c
FROM \c
  USR$WG_VACATION \c
WHERE \c
  DOCUMENTKEY = pDocKey \c
--UNION ALL \c
SELECT \c
  2 AS VcType, COALESCE(USR$UNHEALTHY,0) AS Slice \c
FROM \c
  USR$WG_VACATION \c
WHERE \c
  DOCUMENTKEY = pDocKey \c
UNION ALL \c
SELECT \c
  3 AS VcType, COALESCE(USR$UNFIXED,0) AS Slice \c
FROM \c
  USR$WG_VACATION \c
WHERE \c
  DOCUMENTKEY = pDocKey \c
UNION ALL \c
SELECT \c
  4 AS VcType, COALESCE(USR$COMPENSATIONDAY,0) AS Slice \c
FROM \c
  USR$WG_VACATION \c
WHERE \c
  DOCUMENTKEY = pDocKey \c
",
[pDocKey-_]
    ).

gd_pl_ds(wg_struct_sick, in, gd_const_budget, 2, [fConstDate-date, fBudget-float]).
% gd_const_budget(ConstDate, Budget)
get_sql(wg_struct_sick, in, gd_const_budget/2,
"SELECT \c
  cv.CONSTDATE, \c
  CAST(cv.CONSTVALUE AS DECIMAL(15,4)) AS Budget \c
FROM \c
  GD_CONSTVALUE cv \c
JOIN \c
  GD_CONST c \c
    ON c.ID  =  cv.CONSTKEY \c
WHERE \c
  cv.CONSTKEY = \c
  (SELECT id FROM gd_ruid WHERE xid = pBudget_xid AND dbid = pBudget_dbid) \c
ORDER BY \c
  cv.CONSTDATE \c
",
[pBudget_xid-_, pBudget_dbid-_]
    ).

gd_pl_ds(wg_struct_sick, in, usr_wg_TblDayNorm, 8,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fWYear-integer, fWMonth-integer, fTheDay-date, fWDay-integer,
    fWDuration-float, fWorkDay-integer
    ]).
% usr_wg_TblDayNorm(EmplKey, FirstMoveKey, WYear, WMonth, TheDay, WDay, WDuration, WorkDay)
get_sql(wg_struct_sick, in, usr_wg_TblDayNorm/8,
"\c
SELECT EmplKey, FirstMoveKey, WYear, WMonth, TheDay, WDay, WDuration, WorkDay \c
FROM USR$WG_TBLCALDAY_P(pEmplKey, pFirstMoveKey, \'pDateCalcFrom\', \'pDateCalcTo\') \c
",
[pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ).

gd_pl_ds(wg_struct_sick, in, wg_job_ill_type, 1, [fJobIllType-integer]).
% wg_job_ill_type(ID)
get_sql(wg_struct_sick, in, wg_job_ill_type/1,
"\c
SELECT id FROM GD_P_GETID(pJobIllType_ruid) \c
",
[pJobIllType_ruid-_]
    ).

%
