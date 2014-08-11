%% twg_fee_sql
%  спецификации и sql-шаблоны для базы знаний twg_fee
%

:-
    GetSQL = [gd_pl_ds/5, get_sql/5],
    %dynamic(GetSQL),
    multifile(GetSQL),
    discontiguous(GetSQL).

%
wg_valid_sql(
            [
            usr_wg_MovementLine/15,
            usr_wg_TblCharge/14,
            usr_wg_TblCharge_Prev/12,
            usr_wg_TblCharge_AlimonyDebt/9,
            usr_wg_FeeType/4,
            usr_wg_FeeType_Taxable/3,
            usr_wg_FeeType_Dict/6,
            usr_wg_TblCalLine/7,
            usr_wg_TblCal_FlexLine/68,
            usr_wg_FCRate/2,
            gd_const_budget/2,
            usr_wg_Variables/2,
            usr_wg_Alimony/12,
            usr_wg_TransferType/4,
            usr_wg_TransferScale/3,
            usr_wg_AlimonyDebt/8,
            usr_wg_AlimonyDebt_delete/0,
            -
            ]).

%
is_valid_sql(Functor/Arity) :-
    wg_valid_sql(ValidSQL),
    member(Functor/Arity, ValidSQL),
    !.

/* база знаний */

gd_pl_ds(Scope, kb, usr_wg_MovementLine, 15, [
    fEmplKey-integer, fDocumentKey-integer, fFirstMoveKey-integer,
    fMoveYear-integer, fMoveMonth-integer, fDateBegin-date,
    fScheduleKey-integer, fMovementType-integer,
    fRate-float, fListNumber-string, fMSalary-float,
    fPayFormKey-integer, fSalaryKey-integer, fTSalary-float, fAvgWageRate-float
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).
% usr_wg_MovementLine(EmplKey, DocumentKey, FirstMoveKey,
%   MoveYear, MoveMonth, DateBegin,
%   ScheduleKey, MovementType, Rate, ListNumber, MSalary,
%   PayFormKey, SalaryKey, TSalary, AvgWageRate)
get_sql(Scope, kb, usr_wg_MovementLine/15,
"\n SELECT \n \c
  ml.USR$EMPLKEY, \n \c
  ml.DOCUMENTKEY, \n \c
  ml.USR$FIRSTMOVE AS FirstMoveKey, \n \c
  EXTRACT(YEAR FROM ml.USR$DATEBEGIN) AS MoveYear, \n \c
  EXTRACT(MONTH FROM ml.USR$DATEBEGIN) AS MoveMonth, \n \c
  ml.USR$DATEBEGIN, \n \c
  ml.USR$SCHEDULEKEY, \n \c
  ml.USR$MOVEMENTTYPE, \n \c
  COALESCE(ml.USR$RATE, 0) AS Rate, \n \c
  ml.USR$LISTNUMBER, \n \c
  COALESCE(ml.USR$MSALARY, 0) AS MSalary, \n \c
  COALESCE(ml.USR$PAYFORMKEY, 0) AS PayFormKey, \n \c
  (SELECT id FROM GD_P_GETID(pPayFormSalary_ruid)) AS SalaryKey, \n \c
  COALESCE(ml.USR$TSALARY, 0) AS TSalary, \n \c
  8 * COALESCE(USR$THOURRATE, 0) AS AvgWageRate \n \c
FROM \n \c
  USR$WG_MOVEMENTLINE ml \n \c
JOIN \n \c
  USR$WG_KINDOFWORK kw \n \c
    ON kw.ID = ml.USR$KINDOFWORKKEY \n \c
WHERE \n \c
  ml.USR$EMPLKEY = pEmplKey \n \c
  AND \n \c
  ml.USR$KINDOFWORKKEY = \n \c
    (SELECT id FROM GD_P_GETID(pKindOfWork_Basic_ruid)) \n \c
ORDER BY \n \c
  ml.USR$EMPLKEY, \n \c
  ml.USR$FIRSTMOVE, \n \c
  ml.USR$DATEBEGIN \n \c
",
    [
    pEmplKey-_, pPayFormSalary_ruid-_, pKindOfWork_Basic_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblCharge, 14, [
    fDocKey-integer, fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fDebit-float, fCredit-float, fFeeTypeKey-integer,
    fDOW-float, fHOW-float,
    fTotalYear-integer, fTotalMonth-integer, fTotalDateBegin-date
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).
% usr_wg_TblCharge(DocKey, EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, Debit, Credit, FeeTypeKey, DOW, HOW, TotalYear, TotalMonth, TotalDateBegin)
get_sql(Scope, kb, usr_wg_TblCharge/14,
"\n SELECT \n \c
  tch.USR$DOCUMENTKEY, \n \c
  tch.USR$EMPLKEY, \n \c
  tch.USR$FIRSTMOVEKEY, \n \c
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, \n \c
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, \n \c
  tch.USR$DATEBEGIN, \n \c
  tch.USR$DEBIT, \n \c
  tch.USR$CREDIT, \n \c
  tch.USR$FEETYPEKEY, \n \c
  tch.USR$DOW, \n \c
  tch.USR$HOW, \n \c
  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS TotalYear, \n \c
  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS TotalMonth, \n \c
  t.USR$DATEBEGIN AS TotalDateBegin \n \c
FROM \n \c
  USR$WG_TBLCHARGE tch \n \c
JOIN \n \c
  USR$WG_TOTAL t \n \c
    ON t.DOCUMENTKEY = tch.USR$TOTALDOCKEY \n \c
WHERE \n \c
  tch.USR$EMPLKEY = pEmplKey \n \c
  AND \n \c
  tch.USR$TOTALDOCKEY = pTotalDocKey \n \c
",
    [
    pEmplKey-_, pTotalDocKey-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblCharge_Prev, 12, [
    fDocKey-integer, fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fDebit-float, fCredit-float, fFeeTypeKey-integer,
    fTotalYear-integer, fTotalMonth-integer, fTotalDateBegin-date
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).
% usr_wg_TblCharge_Prev(DocKey, EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, Debit, Credit, FeeTypeKey, TotalYear, TotalMonth, TotalDateBegin)
get_sql(Scope, kb, usr_wg_TblCharge_Prev/12,
"\n SELECT \n \c
  tch.USR$DOCUMENTKEY, \n \c
  tch.USR$EMPLKEY, \n \c
  tch.USR$FIRSTMOVEKEY, \n \c
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, \n \c
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, \n \c
  tch.USR$DATEBEGIN, \n \c
  tch.USR$DEBIT, \n \c
  tch.USR$CREDIT, \n \c
  tch.USR$FEETYPEKEY, \n \c
  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS TotalYear, \n \c
  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS TotalMonth, \n \c
  t.USR$DATEBEGIN AS TotalDateBegin \n \c
FROM \n \c
  USR$WG_TBLCHARGE tch \n \c
JOIN \n \c
  USR$WG_TOTAL t \n \c
    ON t.DOCUMENTKEY = tch.USR$TOTALDOCKEY \n \c
WHERE \n \c
  tch.USR$EMPLKEY = pEmplKey \n \c
  AND \n \c
  t.USR$DATEBEGIN >= 'pDatePrevCalcFrom' \n \c
  AND \n \c
  t.USR$DATEBEGIN < 'pDatePrevCalcTo' \n \c
",
    [
    pEmplKey-_,
    pDatePrevCalcFrom-_, pDatePrevCalcTo-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblCharge_AlimonyDebt, 9, [
    fDocKey-integer, fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fDebit-float, fCredit-float, fFeeTypeKey-integer
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).
% usr_wg_TblCharge_AlimonyDebt(DocKey, EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, Debit, Credit, FeeTypeKey)
get_sql(Scope, kb, usr_wg_TblCharge_AlimonyDebt/9,
"\n SELECT \n \c
  tch.USR$DOCUMENTKEY, \n \c
  tch.USR$EMPLKEY, \n \c
  tch.USR$FIRSTMOVEKEY, \n \c
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, \n \c
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, \n \c
  tch.USR$DATEBEGIN, \n \c
  tch.USR$DEBIT, \n \c
  tch.USR$CREDIT, \n \c
  tch.USR$FEETYPEKEY \n \c
FROM \n \c
  USR$WG_TBLCHARGE tch \n \c
WHERE \n \c
  tch.USR$EMPLKEY = pEmplKey \n \c
  AND \n \c
  tch.USR$DATEBEGIN < 'pDateCalcFrom' \n \c
  AND \n \c
  tch.USR$FEETYPEKEY = \n \c
    (SELECT id FROM GD_P_GETID(pFeeType_AlimonyDebt_ruid)) \n \c
",
    [
    pEmplKey-_, pDateCalcFrom-_, pFeeType_AlimonyDebt_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).

gd_pl_ds(Scope, kb, usr_wg_FeeType, 4, [
    fEmplKey-integer,
    fFeeGroupKey-integer, fFeeTypeKey-integer, fAvgDayHOW-integer
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).
% usr_wg_FeeType(EmplKey, FeeGroupKey, FeeTypeKey, AvgDayHOW)
get_sql(Scope, kb, usr_wg_FeeType/4,
"\n SELECT \n \c
  pEmplKey AS EmplKey,  \n \c
  ft.USR$WG_FEEGROUPKEY, \n \c
  ft.USR$WG_FEETYPEKEY, \n \c
  ft_avg.USR$AVGDAYHOW \n \c
FROM \n \c
  USR$CROSS179_256548741 ft \n \c
JOIN \n \c
  USR$WG_FEETYPE ft_avg \n \c
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY \n \c
WHERE \n \c
  ft.USR$WG_FEEGROUPKEY = \n \c
    (SELECT id FROM GD_P_GETID(pFeeGroupKey_ruid)) \n \c
",
    [
    pEmplKey-_, pFeeGroupKey_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).

gd_pl_ds(Scope, kb, usr_wg_FeeType_Taxable, 3, [
    fEmplKey-integer,
    fFeeGroupKey-integer, fFeeTypeKey-integer
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).
% usr_wg_FeeType_Taxable(EmplKey, FeeGroupKey, FeeTypeKey)
get_sql(Scope, kb, usr_wg_FeeType_Taxable/3,
"\n SELECT \n \c
  pEmplKey AS EmplKey,  \n \c
  ft.USR$WG_FEEGROUPKEY, \n \c
  ft.USR$WG_FEETYPEKEY \n \c
FROM \n \c
  USR$CROSS179_256548741 ft \n \c
JOIN \n \c
  USR$WG_FEETYPE ft_avg \n \c
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY \n \c
WHERE \n \c
  ft.USR$WG_FEEGROUPKEY = \n \c
    (SELECT id FROM GD_P_GETID(pFeeGroupKey_IncomeTax_ruid)) \n \c
",
    [
    pEmplKey-_, pFeeGroupKey_IncomeTax_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).

gd_pl_ds(Scope, kb, usr_wg_FeeType_Dict, 6, [
    fID-integer, fAlias-string, fName-string,
    fRoundByFeeType-integer, fRoundType-integer, fRoundValue-float
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).
% usr_wg_FeeType_Dict(ID, Alias, Name, RoundByFeeType, RoundType, RoundValue)
get_sql(Scope, kb, usr_wg_FeeType_Dict/6,
"\n SELECT \n \c
  ft.ID, \n \c
  CASE ft.ID \n \c
    WHEN \n \c
      (SELECT id FROM GD_P_GETID(pFeeType_Alimony_ruid)) \n \c
        THEN 'ftAlimony' \n \c
    WHEN \n \c
      (SELECT id FROM GD_P_GETID(pFeeType_HolidayComp_ruid)) \n \c
        THEN 'ftHolidayComp' \n \c
    WHEN \n \c
      (SELECT id FROM GD_P_GETID(pFeeType_IncomeTax_ruid)) \n \c
        THEN 'ftIncomeTax' \n \c
    WHEN \n \c
      (SELECT id FROM GD_P_GETID(pFeeType_TransferDed_ruid)) \n \c
        THEN 'ftTransferDed' \n \c
    WHEN \n \c
      (SELECT id FROM GD_P_GETID(pFeeType_AlimonyDebt_ruid)) \n \c
        THEN 'ftAlimonyDebt' \n \c
    ELSE \n \c
        'unknown' \n \c
  END \n \c
    AS Alias, \n \c
  USR$NAME, \n \c
  USR$ROUNDBYFEETYPE, \n \c
  USR$ROUNDTYPE, \n \c
  USR$ROUNDVALUE \n \c
FROM \n \c
  USR$WG_FEETYPE ft \n \c
",
    [
    pFeeType_Alimony_ruid-_,
    pFeeType_HolidayComp_ruid-_,
    pFeeType_IncomeTax_ruid-_,
    pFeeType_TransferDed_ruid-_,
    pFeeType_AlimonyDebt_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblCalLine, 7, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDate-date,
    fDuration-float, fHoureType-integer
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).
% usr_wg_TblCalLine(EmplKey, FirstMoveKey, CalYear, CalMonth, Date, Duration, HoureType)
get_sql(Scope, kb, usr_wg_TblCalLine/7,
"\n SELECT \n \c
  tc.USR$EMPLKEY, \n \c
  tc.USR$FIRSTMOVEKEY, \n \c
  EXTRACT(YEAR FROM tcl.USR$DATE) AS CalYear, \n \c
  EXTRACT(MONTH FROM tcl.USR$DATE) AS CalMonth, \n \c
  tcl.USR$DATE, \n \c
  tcl.USR$DURATION, \n \c
  tcl.USR$HOURTYPE \n \c
FROM \n \c
  USR$WG_TBLCAL tc \n \c
JOIN \n \c
  USR$WG_TBLCALLINE tcl \n \c
    ON tcl.MASTERKEY = tc.DOCUMENTKEY \n \c
WHERE \n \c
  tc.USR$EMPLKEY = pEmplKey \n \c
  AND \n \c
  tcl.USR$DATE >= 'pDateCalcFrom' \n \c
  AND \n \c
  tcl.USR$DATE < 'pDateCalcTo' \n \c
ORDER BY \n \c
  tc.USR$EMPLKEY, \n \c
  tc.USR$FIRSTMOVEKEY, \n \c
  tcl.USR$DATE \n \c
",
    [
    pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
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
        wg_fee_alimony
        ]).
% usr_wg_TblCal_FlexLine(FlexType, EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, S1, H1, ..., S31, H31)
get_sql(Scope, kb, usr_wg_TblCal_FlexLine/68,
"\n SELECT \n \c
  CASE gd.DOCUMENTTYPEKEY \n \c
    WHEN \n \c
      (SELECT id FROM GD_P_GETID(pTblCal_DocType_Plan_ruid)) \n \c
        THEN 'plan' \n \c
    WHEN \n \c
      (SELECT id FROM GD_P_GETID(pTblCal_DocType_Fact_ruid)) \n \c
        THEN 'fact' \n \c
    ELSE \n \c
        'unknown' \n \c
  END \n \c
    AS FlexType, \n \c
  tcfl.USR$EMPLKEY, \n \c
  tcfl.USR$FIRSTMOVEKEY, \n \c
  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS CalYear, \n \c
  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS CalMonth, \n \c
  t.USR$DATEBEGIN, \n \c
  tcfl.USR$S1, tcfl.USR$H1, tcfl.USR$S2, tcfl.USR$H2, \n \c
  tcfl.USR$S3, tcfl.USR$H3, tcfl.USR$S4, tcfl.USR$H4, \n \c
  tcfl.USR$S5, tcfl.USR$H5, tcfl.USR$S6, tcfl.USR$H6, \n \c
  tcfl.USR$S7, tcfl.USR$H7, tcfl.USR$S8, tcfl.USR$H8, \n \c
  tcfl.USR$S9, tcfl.USR$H9, tcfl.USR$S10, tcfl.USR$H10, \n \c
  tcfl.USR$S11, tcfl.USR$H11, tcfl.USR$S12, tcfl.USR$H12, \n \c
  tcfl.USR$S13, tcfl.USR$H13, tcfl.USR$S14, tcfl.USR$H14, \n \c
  tcfl.USR$S15, tcfl.USR$H15, tcfl.USR$S16, tcfl.USR$H16, \n \c
  tcfl.USR$S17, tcfl.USR$H17, tcfl.USR$S18, tcfl.USR$H18, \n \c
  tcfl.USR$S19, tcfl.USR$H19, tcfl.USR$S20, tcfl.USR$H20, \n \c
  tcfl.USR$S21, tcfl.USR$H21, tcfl.USR$S22, tcfl.USR$H22, \n \c
  tcfl.USR$S23, tcfl.USR$H23, tcfl.USR$S24, tcfl.USR$H24, \n \c
  tcfl.USR$S25, tcfl.USR$H25, tcfl.USR$S26, tcfl.USR$H26, \n \c
  tcfl.USR$S27, tcfl.USR$H27, tcfl.USR$S28, tcfl.USR$H28, \n \c
  tcfl.USR$S29, tcfl.USR$H29, tcfl.USR$S30, tcfl.USR$H30, \n \c
  tcfl.USR$S31, tcfl.USR$H31 \n \c
FROM \n \c
  GD_DOCUMENT gd \n \c
JOIN \n \c
  USR$WG_TBLCAL_FLEXLINE tcfl \n \c
    ON gd.ID = tcfl.DOCUMENTKEY \n \c
JOIN \n \c
  USR$WG_TBLCAL_FLEX tcf \n \c
    ON tcf.DOCUMENTKEY = tcfl.MASTERKEY \n \c
JOIN \n \c
  USR$WG_TOTAL t \n \c
    ON t.DOCUMENTKEY = tcf.USR$TOTALDOCKEY \n \c
WHERE \n \c
  tcfl.USR$EMPLKEY = pEmplKey \n \c
  AND \n \c
  t.USR$DATEBEGIN >= 'pDateCalcFrom' \n \c
  AND \n \c
  t.USR$DATEBEGIN < 'pDateCalcTo' \n \c
 ORDER BY \n \c
   tcfl.USR$EMPLKEY, \n \c
   tcfl.USR$FIRSTMOVEKEY, \n \c
   t.USR$DATEBEGIN \n \c
",
    [
    pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_,
    pTblCal_DocType_Plan_ruid-_, pTblCal_DocType_Fact_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_FCRate, 2, [
    fDate-date, fMinWage-float
    ]).
% usr_wg_FCRate(Date, MinWage)
get_sql(wg_fee_alimony, kb, usr_wg_FCRate/2,
"\n SELECT \n \c
  fc.USR$WG_DATE, \n \c
  fc.USR$WG_MINWAGE \n \c
FROM \n \c
  USR$WG_FCRATE fc \n \c
WHERE \n \c
  fc.USR$WG_DATE >= 'pStartDate' \n \c
ORDER BY \n \c
  fc.USR$WG_DATE \n \c
",
    [
    pStartDate-_
    ]).

gd_pl_ds(wg_fee_alimony, kb, gd_const_budget, 2, [
    fConstDate-date, fBudget-float
    ]).
% gd_const_budget(ConstDate, Budget)
get_sql(wg_fee_alimony, kb, gd_const_budget/2,
"\n SELECT \n \c
  cv.CONSTDATE, \n \c
  CAST(cv.CONSTVALUE AS DECIMAL(15,4)) AS Budget \n \c
FROM \n \c
  GD_CONSTVALUE cv \n \c
JOIN \n \c
  GD_CONST c \n \c
    ON c.ID  =  cv.CONSTKEY \n \c
WHERE \n \c
  cv.CONSTDATE >= 'pStartDate' \n \c
  AND \n \c
  cv.CONSTKEY = \n \c
    (SELECT id FROM GD_P_GETID(pBudget_ruid)) \n \c
ORDER BY \n \c
  cv.CONSTDATE \n \c
",
    [
    pStartDate-_, pBudget_ruid-_
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_Variables, 2, [
    fAlias-string, fName-string
    ]).
% usr_wg_Varuables(Alias, Name)
get_sql(wg_fee_alimony, kb, usr_wg_Variables/2,
"\n SELECT \n \c
  'vBV' AS Alias, \n \c
  USR$NAME \n \c
FROM \n \c
  USR$WG_VARIABLES \n \c
WHERE \n \c
  ID = (SELECT id FROM GD_P_GETID(pVar_BV_ruid)) \n \c
UNION ALL \n \c
SELECT \n \c
  'vForAlimony' AS Alias, \n \c
  USR$NAME \n \c
FROM \n \c
  USR$WG_VARIABLES \n \c
WHERE \n \c
  ID = (SELECT id FROM GD_P_GETID(pVar_ForAlimony_ruid)) \n \c
",
    [
    pVar_BV_ruid-_, pVar_ForAlimony_ruid-_
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_Alimony, 12, [
    fDocKey-integer, fEmplKey-integer,
    fDateBegin-date, fDateEnd-date,
    fDebtSum-float, fFormula-string,
    fTransferTypeKey-integer, fRecipient-integer,
    fRestPercent-float, fChildCount-integer,
    fPercent-float, fLivingWagePerc-float
    ]).
% usr_wg_Alimony(DocKey, EmplKey, DateBegin, DateEnd, DebtSum, Formula, TransferTypeKey, Recipient, RestPercent, ChildCount, Percent, LivingWagePerc)
get_sql(wg_fee_alimony, kb, usr_wg_Alimony/12,
"\n SELECT \n \c
  calc.DOCUMENTKEY, \n \c
  calc.USR$EMPLKEY, \n \c
  calc.USR$DATEBEGIN, \n \c
  COALESCE(calc.USR$DATEEND, CAST('pNullDate' AS DATE)) AS DateEnd, \n \c
  calc.USR$DEBTSUM, \n \c
  calc.USR$FORMULA, \n \c
  calc.USR$TRANSFERTYPEKEY, \n \c
  calc.USR$RECIPIENT, \n \c
  calc.USR$RESTPERCENT, \n \c
  calc.USR$CHILDCOUNT, \n \c
  calc.USR$PERCENT, \n \c
  calc.USR$LIVINGWAGEPERC \n \c
FROM \n \c
  USR$WG_ALIMONY calc \n \c
JOIN \n \c
  GD_DOCUMENT d
    ON calc.DOCUMENTKEY = d.ID \n \c
WHERE \n \c
  d.COMPANYKEY = <COMPANYKEY/> \n \c
  AND \n \c
  d.DOCUMENTTYPEKEY = (SELECT id FROM GD_P_GETID(pDocType_Alimony_ruid)) \n \c
  AND \n \c
  calc.USR$EMPLKEY = pEmplKey \n \c
  AND \n \c
  calc.USR$DATEBEGIN < 'pDateCalcTo' \n \c
  AND \n \c
  COALESCE(calc.USR$DATEEND, 'pNullDate') >= 'pDateCalcFrom' \n \c
ORDER BY \n \c
  calc.USR$DATEBEGIN \n \c
",
    [
    pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_, pDocType_Alimony_ruid-_,
    pNullDate-_
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_TransferType, 4, [
    fID-integer, fParent-integer,
    fDateBegin-date, fName-string
    ]).
% usr_wg_TransferType(ID, Parent, DateBegin, Name)
get_sql(wg_fee_alimony, kb, usr_wg_TransferType/4,
"\n SELECT \n \c
  tt.ID, \n \c
  COALESCE(tt.PARENT, 0) AS Parent, \n \c
  COALESCE(tt.USR$DATE, current_date) AS DateBegin, \n \c
  tt.USR$NAME \n \c
FROM \n \c
  USR$WG_TRANSFERTYPE tt \n \c
ORDER BY \n \c
  Parent, DateBegin, tt.ID \n \c
",
    [
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_TransferScale, 3, [
    fTranferTypeKey-integer,
    fStartSum-float, fPercent-float
    ]).
% usr_wg_TransferScale(TranferTypeKey, StartSum, Percent)
get_sql(wg_fee_alimony, kb, usr_wg_TransferScale/3,
"\n SELECT \n \c
  ts.USR$TRANSFERTYPEKEY, \n \c
  COALESCE(ts.USR$STARTSUM, 0) AS StartSum, \n \c
  COALESCE(ts.USR$PERCENT, 0) AS Percent \n \c
FROM \n \c
  USR$WG_TRANSFERSCALE ts \n \c
ORDER BY \n \c
  ts.USR$TRANSFERTYPEKEY, StartSum \n \c
",
    [
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_AlimonyDebt, 8, [
    fDocKey-integer, fEmplKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fAlimonyKey-integer, fTotalDocKey-integer, fDebtSum-float
    ]).
% usr_wg_AlimonyDebt(DocKey, EmplKey, CalYear, CalMonth, DateBegin, AlimonyKey, TotalDocKey, DebtSum)
get_sql(wg_fee_alimony, kb, usr_wg_AlimonyDebt/8,
"\n SELECT \n \c
  aldebt.DOCUMENTKEY, \n \c
  al.USR$EMPLKEY, \n \c
  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS CalYear, \n \c
  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS CalMonth, \n \c
  t.USR$DATEBEGIN, \n \c
  aldebt.USR$ALIMONYKEY, \n \c
  aldebt.USR$TOTALDOCKEY, \n \c
  aldebt.USR$DEBTSUM \n \c
FROM \n \c
  USR$WG_ALIMONYDEBT aldebt \n \c
JOIN \n \c
  USR$WG_ALIMONY al \n \c
    ON al.DOCUMENTKEY = aldebt.USR$ALIMONYKEY \n \c
JOIN \n \c
  USR$WG_TOTAL t \n \c
    ON t.DOCUMENTKEY = aldebt.USR$TOTALDOCKEY \n \c
WHERE \n \c
  al.USR$EMPLKEY = pEmplKey \n \c
  AND \n \c
  t.USR$DATEBEGIN < 'pDateCalcFrom' \n \c
ORDER BY \n \c
  t.USR$DATEBEGIN \n \c
",
    [
    pEmplKey-_, pDateCalcFrom-_
    ]).

/* удаление данных */

gd_pl_ds(wg_fee_alimony, cmd, usr_wg_AlimonyDebt_delete, 0, []).
% usr_wg_AlimonyDebt_delete
get_sql(wg_fee_alimony, cmd, usr_wg_AlimonyDebt_delete/0,
"\n DELETE \n \c
FROM \n \c
  USR$WG_ALIMONYDEBT aldebt \n \c
WHERE \n \c
  aldebt.USR$TOTALDOCKEY = pTotalDocKey \n \c
  AND \n \c
  aldebt.USR$ALIMONYKEY IN \n \c
    (SELECT al.DOCUMENTKEY FROM USR$WG_ALIMONY al WHERE al.USR$EMPLKEY = pEmplKey) \n \c
",
    [
    pEmplKey-_, pTotalDocKey-_
    ]).

/**/

 %
%%
