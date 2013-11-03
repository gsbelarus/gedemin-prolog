% twg_avg_wage_sql

init_sql:-
    GetSQL = [get_sql/3, get_sql/4],
    dynamic(GetSQL),
    multifile(GetSQL),
    discontiguous(GetSQL),
    init_data,
    !.
:- init_sql.

gd_pl_ds(wg_avg_wage, in, usr_wg_MovementLine, 8,
    [
    fEmplKey-integer, fDocumentKey-integer, fFirstMoveKey-integer,
    fDateBegin-date, fScheduleKey-integer, fMovementType-integer,
    fRate-float, fListNumber-string
    ]).
% usr_wg_MovementLine(EmplKey, DocumentKey, FirstMoveKey, DateBegin, ScheduleKey,
%   MovementType, Rate, ListNumber)
get_sql(bogem, usr_wg_MovementLine/8,
'SELECT \c
  ml.USR$EMPLKEY, \c
  ml.DOCUMENTKEY, \c
  ml.USR$FIRSTMOVE AS FirstMoveKey, \c
  ml.USR$DATEBEGIN, \c
  ml.USR$SCHEDULEKEY, \c
  ml.USR$MOVEMENTTYPE, \c
  ml.USR$RATE, \c
  ml.USR$LISTNUMBER \c
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
',
[pEmplKey-_, pFirstMoveKey-_]
    ).

gd_pl_ds(wg_avg_wage, in, wg_TblCalDay, 6,
    [
    fEmplKey-integer, fFirstMoveKey-integer, fTheDay-date, fWDuration-float,
    fWorkDay-integer, fTblCalKey-integer
    ]).
% wg_TblCalDay(EmplKey, FirstMoveKey, TheDay, WDuration, WorkDay, TblCalKey)
get_sql(bogem, wg_TblCalDay/6,
'SELECT \c
  pEmplKey AS EmplKey, \c
  pFirstMoveKey AS FirstMoveKey, \c
  tcd.THEDAY, \c
  tcd.WDURATION, \c
  tcd.WORKDAY, \c
  tcd.TBLCALKEY \c
FROM \c
  WG_TBLCALDAY tcd \c
WHERE \c
  tcd.THEDAY >= CAST(\'pDateNormFrom\' AS DATE) \c
  AND \c
  tcd.THEDAY < CAST(\'pDateNormTo\' AS DATE) \c
ORDER BY \c
  tcd.TBLCALKEY, \c
  tcd.THEDAY \c
',
[pEmplKey-_, pFirstMoveKey-_, pDateNormFrom-_, pDateNormTo-_]
    ).

gd_pl_ds(wg_avg_wage, in, usr_wg_TblCalLine, 5,
    [
    fEmplKey-integer, fFirstMoveKey-integer, fDate-date,
    fDuration-float, fHoureType-integer
    ]).
% usr_wg_TblCalLine(EmplKey, FirstMoveKey, Date, Duration, HoureType)
get_sql(bogem, usr_wg_TblCalLine/5,
'SELECT \c
  tc.USR$EMPLKEY, \c
  tc.USR$FIRSTMOVEKEY, \c
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
  tcl.USR$DATE >= CAST(\'pDateCalcFrom\' AS DATE) \c
  AND \c
  tcl.USR$DATE < CAST(\'pDateCalcTo\' AS DATE) \c
ORDER BY \c
  tc.USR$EMPLKEY, \c
  tc.USR$FIRSTMOVEKEY, \c
  tcl.USR$DATE \c
',
[pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ).

gd_pl_ds(wg_avg_wage, in, usr_wg_TblCal_FlexLine, 65,
    [
    fEmplKey-integer, fFirstMoveKey-integer, fDateBegin-date,
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
% usr_wg_TblCal_FlexLine(EmplKey, FirstMoveKey, DateBegin, S1, H1, ..., S31, H31)
get_sql(bogem, usr_wg_TblCal_FlexLine/65,
'SELECT \c
  tcfl.USR$EMPLKEY, \c
  tcfl.USR$FIRSTMOVEKEY, \c
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
  USR$WG_TBLCAL_FLEXLINE tcfl \c
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
  t.USR$DATEBEGIN >= CAST(\'pDateCalcFrom\' AS DATE) \c
  AND \c
  t.USR$DATEBEGIN < CAST(\'pDateCalcTo\' AS DATE) \c
 ORDER BY \c
   tcfl.USR$EMPLKEY, \c
   tcfl.USR$FIRSTMOVEKEY, \c
   t.USR$DATEBEGIN \c
',
[pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ).

gd_pl_ds(wg_avg_wage, in, usr_wg_HourType, 12,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fID-integer, fCode-string, fDigitCode-string,
    fDescription-string, fIsWorked-integer, fShortName-string,
    fForCalFlex-integer, fForOverTime-integer, fForFlex-integer,
    fAbsentEEIsm-integer
    ]).
% usr_wg_HourType(EmplKey, FirstMoveKey,
%   ID, Code, DigitCode, Description, IsWorked, ShortName,
%   ForCalFlex, ForOverTime, ForFlex, AbsentEEIsm)
get_sql(bogem, usr_wg_HourType/12,
'SELECT \c
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
  ht.USR$ABSENTEEISM \c
FROM \c
  USR$WG_HOURTYPE ht \c
',
[pEmplKey-_, pFirstMoveKey-_]
    ).

gd_pl_ds(wg_avg_wage, in, usr_wg_TblCharge, 5,
    [
    fEmplKey-integer, fFirstMoveKey-integer, fDateBegin-date,
    fDebit-float, fFeeTypeKey-integer
    ]).
% usr_wg_TblCharge(EmplKey, FirstMoveKey, DateBegin, Debit, FeeTypeKey)
get_sql(bogem, usr_wg_TblCharge/5,
'SELECT \c
  tch.USR$EMPLKEY, \c
  tch.USR$FIRSTMOVEKEY, \c
  tch.USR$DATEBEGIN, \c
  tch.USR$DEBIT, \c
  tch.USR$FEETYPEKEY \c
FROM \c
  USR$WG_TBLCHARGE tch \c
WHERE \c
  tch.USR$EMPLKEY = pEmplKey \c
  AND \c
  tch.USR$DEBIT > 0 \c
  AND \c
  tch.USR$DATEBEGIN >= CAST(\'pDateCalcFrom\' AS DATE) \c
  AND \c
  tch.USR$DATEBEGIN < CAST(\'pDateCalcTo\' AS DATE) \c
ORDER BY \c
  tch.USR$EMPLKEY, \c
  tch.USR$DATEBEGIN \c
',
[pEmplKey-_, pFirstMoveKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ).

gd_pl_ds(wg_avg_wage, in, usr_wg_FeeType, 4,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fFeeGroupKey-integer, fFeeTypeKey-integer
    ]).
% usr_wg_FeeType(EmplKey, FeeGroupKey, FeeTypeKey)
get_sql(bogem, usr_wg_FeeType/4,
'SELECT \c
  pEmplKey AS EmplKey,  \c
  pFirstMoveKey AS FirstMoveKey, \c
  ft.USR$WG_FEEGROUPKEY, \c
  ft.USR$WG_FEETYPEKEY \c
FROM \c
  USR$CROSS179_256548741 ft \c
WHERE
  ft.USR$WG_FEEGROUPKEY = pFeeGroupKey \c
',
[pEmplKey-_, pFirstMoveKey-_, pFeeGroupKey-_]
    ).

gd_pl_ds(wg_avg_wage, in, usr_wg_BadHourType, 3,
    [
    fEmplKey-integer, fFirstMoveKey-integer, fID-integer
    ]).
% usr_wg_BadHourType(EmplKey, ID)
get_sql(bogem, usr_wg_BadHourType/3,
'SELECT \c
  pEmplKey AS EmplKey, pFirstMoveKey AS FirstMoveKey, id \c
FROM USR$WG_HOURTYPE \c
WHERE id IN \c
(SELECT id FROM gd_ruid \c
WHERE xid IN (pBadHourType_xid_IN) \c
AND dbid IN (pBadHourType_dbid_IN) \c
) \c
',
[pEmplKey-_, pFirstMoveKey-_, pBadHourType_xid_IN-_, pBadHourType_dbid_IN-_]
    ).

gd_pl_ds(wg_avg_wage, in, usr_wg_BadFeeType, 3,
    [
    fEmplKey-integer, fFirstMoveKey-integer, fID-integer
    ]).
% usr_wg_BadFeeType(EmplKey, ID)
get_sql(bogem, usr_wg_BadFeeType/3,
'SELECT \c
  pEmplKey AS EmplKey, pFirstMoveKey AS FirstMoveKey, id \c
FROM USR$WG_FEETYPE \c
WHERE id IN \c
(SELECT id FROM gd_ruid \c
WHERE xid IN (pBadFeeType_xid_IN) \c
AND dbid IN (pBadFeeType_dbid_IN) \c
) \c
',
[pEmplKey-_, pFirstMoveKey-_, pBadFeeType_xid_IN-_, pBadFeeType_dbid_IN-_]
    ).

%