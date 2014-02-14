% twg_avg_wage_sql

:-
    GetSQL = [gd_pl_ds/5, get_sql/4],
    dynamic(GetSQL),
    multifile(GetSQL),
    discontiguous(GetSQL).

%
wg_valid_sql([
            usr_wg_DbfSums/6,
            usr_wg_MovementLine/11,
            usr_wg_FCRate/4,
            usr_wg_TblDayNorm/8,
            usr_wg_TblYearNorm/5,
            usr_wg_TblCalLine/7,
            usr_wg_TblCal_FlexLine/68,
            -usr_wg_HourType/11,
            usr_wg_TblCharge/9,
            usr_wg_FeeType/5,
            usr_wg_FeeTypeNoCoef/4,
            usr_wg_BadHourType/3,
            usr_wg_BadFeeType/3
            ]).

%
is_valid_sql(Functor/Arity) :-
    wg_valid_sql(ValidSQL),
    member(Functor/Arity, ValidSQL),
    !.

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_DbfSums, 6,
    [
    fEmplKey-integer, fInSum-float, fInHoures-float,
    fInYear-integer, fInMonth-integer, fDateBegin-date
    ]).
% usr_wg_DbfSums(EmplKey, InSum, InHoures, InYear, InMonth, DateBegin)
get_sql(gsdb, usr_wg_DbfSums/6,
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

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_MovementLine, 11,
    [
    fEmplKey-integer, fDocumentKey-integer, fFirstMoveKey-integer,
    fMoveYear-integer, fMoveMonth-integer, fDateBegin-date,
    fScheduleKey-integer, fMovementType-integer,
    fRate-float, fListNumber-string, fMSalary-float
    ]).
% usr_wg_MovementLine(EmplKey, DocumentKey, FirstMoveKey,
%   MoveYear, MoveMonth, DateBegin,
%   ScheduleKey, MovementType, Rate, ListNumber, MSalary)
get_sql(gsdb, usr_wg_MovementLine/11,
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
  COALESCE(ml.USR$MSALARY, 0) AS MSalary \c
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
[pEmplKey-_, pFirstMoveKey-_]
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_FCRate, 4,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fDate-date, fFCRateSum-float
    ]).
% usr_wg_FCRate(EmplKey, FirstMoveKey, Date, FCRateSum)
get_sql(gsdb, usr_wg_FCRate/4,
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

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_TblDayNorm, 8,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fWYear-integer, fWMonth-integer, fTheDay-date, fWDay-integer,
    fWDuration-float, fWorkDay-integer
    ]).
% usr_wg_TblDayNorm(EmplKey, FirstMoveKey, WYear, WMonth, TheDay, WDay, WDuration, WorkDay)
get_sql(gsdb, usr_wg_TblDayNorm/8,
"\c
SELECT EmplKey, FirstMoveKey, WYear, WMonth, TheDay, WDay, WDuration, WorkDay \c
FROM USR$WG_TBLCALDAY_P(pEmplKey, pFirstMoveKey, \'pDateCalcFrom\', \'pDateCalcTo\') \c
",
[pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_TblYearNorm, 5,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fWYear-integer,
    fWHoures-float, fWDays-integer
    ]).
% usr_wg_TblYearNorm(EmplKey, FirstMoveKey, WYear, WHoures, WDays)
get_sql(gsdb, usr_wg_TblYearNorm/5,
"\c
SELECT EmplKey, FirstMoveKey, WYear, SUM(WDuration) AS WHoures, SUM(WorkDay) AS WDays \c
FROM USR$WG_TBLCALDAY_P(pEmplKey, pFirstMoveKey, \'pDateNormFrom\', \'pDateNormTo\') \c
GROUP BY EmplKey, FirstMoveKey, WYear \c
",
[pEmplKey-_, pFirstMoveKey-_, pDateNormFrom-_, pDateNormTo-_]
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_TblCalLine, 7,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDate-date,
    fDuration-float, fHoureType-integer
    ]).
% usr_wg_TblCalLine(EmplKey, FirstMoveKey, CalYear, CalMonth, Date, Duration, HoureType)
get_sql(gsdb, usr_wg_TblCalLine/7,
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
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_TblCal_FlexLine, 68,
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
    ]).
% usr_wg_TblCal_FlexLine(FlexType, EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, S1, H1, ..., S31, H31)
get_sql(gsdb, usr_wg_TblCal_FlexLine/68,
"SELECT \c
  CASE gd.DOCUMENTTYPEKEY \c
    WHEN pTblCal_DocType_Plan THEN \'plan\' \c
    WHEN pTblCal_DocType_Fact THEN \'fact\' \c
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
  gd.DOCUMENTTYPEKEY IN(pTblCal_DocType_Plan,pTblCal_DocType_Fact) \c
  AND \c
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
[pTblCal_DocType_Plan-_, pTblCal_DocType_Fact-_,
pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_HourType, 11,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fID-integer, fCode-string, fDigitCode-string,
    fDiscription-string, fIsWorked-integer, fShortName-string,
    fForCalFlex-integer, fForOverTime-integer, fForFlex-integer
    ]).
% usr_wg_HourType(EmplKey, FirstMoveKey,
%   ID, Code, DigitCode, Description, IsWorked, ShortName,
%   ForCalFlex, ForOverTime, ForFlex)
get_sql(gsdb, usr_wg_HourType/11,
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
  ht.USR$FORFLEX \c
FROM \c
  USR$WG_HOURTYPE ht \c
",
[pEmplKey-_, pFirstMoveKey-_]
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_TblCharge, 9,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fDebit-float, fFeeTypeKey-integer, fDOW-float, fHOW-float
    ]).
% usr_wg_TblCharge(EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin,
%   Debit, FeeTypeKey, DOW, HOW)
get_sql(gsdb, usr_wg_TblCharge/9,
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
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_FeeType, 5,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fFeeGroupKey-integer, fFeeTypeKey-integer, fAvgDayHOW-integer
    ]).
% usr_wg_FeeType(EmplKey, FirstMoveKey, FeeGroupKey, FeeTypeKey, AvgDayHOW)
get_sql(gsdb, usr_wg_FeeType/5,
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
    ).

gd_pl_ds(wg_avg_wage_vacation, in, usr_wg_FeeTypeNoCoef, 4,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fFeeGroupKeyNoCoef-integer, fFeeTypeKeyNoCoef-integer
    ]).
% usr_wg_FeeTypeNoCoef(EmplKey, FirstMoveKey, FeeGroupKeyNoCoef, FeeTypeKeyNoCoef)
get_sql(gsdb, usr_wg_FeeTypeNoCoef/4,
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
get_sql(gsdb, usr_wg_BadHourType/3,
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
get_sql(gsdb, usr_wg_BadFeeType/3,
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

%
