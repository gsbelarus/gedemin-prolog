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
            usr_wg_TblCharge/11,
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
  (SELECT id FROM GD_P_GETID(pPayFormSalary_ruid)) AS SalaryKey, \c
  COALESCE(ml.USR$TSALARY, 0) AS TSalary, \c
  8 * COALESCE(USR$THOURRATE, 0) AS AvgWageRate \c
FROM \c
  USR$WG_MOVEMENTLINE ml \c
JOIN \c
  USR$WG_KINDOFWORK kw \c
    ON kw.ID = ml.USR$KINDOFWORKKEY \c
WHERE \c
  ml.USR$EMPLKEY = pEmplKey \c
  AND \c
  ml.USR$KINDOFWORKKEY = \c
    (SELECT id FROM GD_P_GETID(pKindOfWork_Basic_ruid)) \c
ORDER BY \c
  ml.USR$EMPLKEY, \c
  ml.USR$FIRSTMOVE, \c
  ml.USR$DATEBEGIN \c
",
    [
    pEmplKey-_, pPayFormSalary_ruid-_, pKindOfWork_Basic_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblCharge, 11, [
    fDocKey-integer, fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fDebit-float, fCredit-float, fFeeTypeKey-integer,
    fDOW-float, fHOW-float
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).
% usr_wg_TblCharge(DocKey, EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, Debit, Credit, FeeTypeKey, DOW, HOW)
get_sql(Scope, kb, usr_wg_TblCharge/11,
"SELECT \c
  tch.USR$DOCUMENTKEY, \c
  tch.USR$EMPLKEY, \c
  tch.USR$FIRSTMOVEKEY, \c
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, \c
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, \c
  tch.USR$DATEBEGIN, \c
  tch.USR$DEBIT, \c
  tch.USR$CREDIT, \c
  tch.USR$FEETYPEKEY, \c
  tch.USR$DOW, \c
  tch.USR$HOW \c
FROM \c
  USR$WG_TBLCHARGE tch \c
WHERE \c
  tch.USR$EMPLKEY = pEmplKey \c
  AND \c
  tch.USR$TOTALDOCKEY = pTotalDocKey \c
",
    [
    pEmplKey-_, pTotalDocKey-_
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
"SELECT \c
  tch.USR$DOCUMENTKEY, \c
  tch.USR$EMPLKEY, \c
  tch.USR$FIRSTMOVEKEY, \c
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, \c
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, \c
  tch.USR$DATEBEGIN, \c
  tch.USR$DEBIT, \c
  tch.USR$CREDIT, \c
  tch.USR$FEETYPEKEY \c
FROM \c
  USR$WG_TBLCHARGE tch \c
WHERE \c
  tch.USR$EMPLKEY = pEmplKey \c
  AND \c
  tch.USR$DATEBEGIN < \'pDateCalcFrom\' \c
  AND \c
  tch.USR$FEETYPEKEY = \c
    (SELECT id FROM GD_P_GETID(pFeeType_AlimonyDebt_ruid)) \c
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
"SELECT \c
  pEmplKey AS EmplKey,  \c
  ft.USR$WG_FEEGROUPKEY, \c
  ft.USR$WG_FEETYPEKEY, \c
  ft_avg.USR$AVGDAYHOW \c
FROM \c
  USR$CROSS179_256548741 ft \c
JOIN \c
  USR$WG_FEETYPE ft_avg \c
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY \c
WHERE \c
  ft.USR$WG_FEEGROUPKEY = \c
    (SELECT id FROM GD_P_GETID(pFeeGroupKey_ruid)) \c
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
"SELECT \c
  pEmplKey AS EmplKey,  \c
  ft.USR$WG_FEEGROUPKEY, \c
  ft.USR$WG_FEETYPEKEY \c
FROM \c
  USR$CROSS179_256548741 ft \c
JOIN \c
  USR$WG_FEETYPE ft_avg \c
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY \c
WHERE \c
  ft.USR$WG_FEEGROUPKEY = \c
    (SELECT id FROM GD_P_GETID(pFeeGroupKey_IncomeTax_ruid)) \c
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
"SELECT \c
  ft.ID, \c
  CASE ft.ID \c
    WHEN \c
      (SELECT id FROM GD_P_GETID(pFeeType_Alimony_ruid)) \c
        THEN \'ftAlimony\' \c
    WHEN \c
      (SELECT id FROM GD_P_GETID(pFeeType_HolidayComp_ruid)) \c
        THEN \'ftHolidayComp\' \c
    WHEN \c
      (SELECT id FROM GD_P_GETID(pFeeType_IncomeTax_ruid)) \c
        THEN \'ftIncomeTax\' \c
    WHEN \c
      (SELECT id FROM GD_P_GETID(pFeeType_TransferDed_ruid)) \c
        THEN \'ftTransferDed\' \c
    WHEN \c
      (SELECT id FROM GD_P_GETID(pFeeType_AlimonyDebt_ruid)) \c
        THEN \'ftAlimonyDebt\' \c
    ELSE \c
        \'unknown\' \c
  END \c
    AS Alias, \c
  USR$NAME, \c
  USR$ROUNDBYFEETYPE, \c
  USR$ROUNDTYPE, \c
  USR$ROUNDVALUE \c
FROM \c
  USR$WG_FEETYPE ft \c
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
  tcl.USR$DATE >= \'pDateCalcFrom\' \c
  AND \c
  tcl.USR$DATE < \'pDateCalcTo\' \c
ORDER BY \c
  tc.USR$EMPLKEY, \c
  tc.USR$FIRSTMOVEKEY, \c
  tcl.USR$DATE \c
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
"SELECT \c
  CASE gd.DOCUMENTTYPEKEY \c
    WHEN \c
      (SELECT id FROM GD_P_GETID(pTblCal_DocType_Plan_ruid)) \c
        THEN \'plan\' \c
    WHEN \c
      (SELECT id FROM GD_P_GETID(pTblCal_DocType_Fact_ruid)) \c
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
  t.USR$DATEBEGIN >= \'pDateCalcFrom\' \c
  AND \c
  t.USR$DATEBEGIN < \'pDateCalcTo\' \c
 ORDER BY \c
   tcfl.USR$EMPLKEY, \c
   tcfl.USR$FIRSTMOVEKEY, \c
   t.USR$DATEBEGIN \c
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
"SELECT \c
  fc.USR$WG_DATE, \c
  fc.USR$WG_MINWAGE \c
FROM \c
  USR$WG_FCRATE fc \c
WHERE \c
  fc.USR$WG_DATE >= \'pStartDate\' \c
ORDER BY \c
  fc.USR$WG_DATE \c
",
    [
    pStartDate-_
    ]).

gd_pl_ds(wg_fee_alimony, kb, gd_const_budget, 2, [
    fConstDate-date, fBudget-float
    ]).
% gd_const_budget(ConstDate, Budget)
get_sql(wg_fee_alimony, kb, gd_const_budget/2,
"SELECT \c
  cv.CONSTDATE, \c
  CAST(cv.CONSTVALUE AS DECIMAL(15,4)) AS Budget \c
FROM \c
  GD_CONSTVALUE cv \c
JOIN \c
  GD_CONST c \c
    ON c.ID  =  cv.CONSTKEY \c
WHERE \c
  cv.CONSTDATE >= \'pStartDate\' \c
  AND \c
  cv.CONSTKEY = \c
    (SELECT id FROM GD_P_GETID(pBudget_ruid)) \c
ORDER BY \c
  cv.CONSTDATE \c
",
    [
    pStartDate-_, pBudget_ruid-_
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_Variables, 2, [
    fAlias-string, fName-string
    ]).
% usr_wg_Varuables(Alias, Name)
get_sql(wg_fee_alimony, kb, usr_wg_Variables/2,
"SELECT \c
  \'vBV\' AS Alias, \c
  USR$NAME \c
FROM \c
  USR$WG_VARIABLES \c
WHERE \c
  ID = (SELECT id FROM GD_P_GETID(pVar_BV_ruid)) \c
UNION ALL \c
SELECT \c
  \'vForAlimony\' AS Alias, \c
  USR$NAME \c
FROM \c
  USR$WG_VARIABLES \c
WHERE \c
  ID = (SELECT id FROM GD_P_GETID(pVar_ForAlimony_ruid)) \c
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
"SELECT \c
  calc.DOCUMENTKEY, \c
  calc.USR$EMPLKEY, \c
  calc.USR$DATEBEGIN, \c
  COALESCE(calc.USR$DATEEND, CAST(\'2100-01-01\' AS DATE)) AS DateEnd, \c
  calc.USR$DEBTSUM, \c
  calc.USR$FORMULA, \c
  calc.USR$TRANSFERTYPEKEY, \c
  calc.USR$RECIPIENT, \c
  calc.USR$RESTPERCENT, \c
  calc.USR$CHILDCOUNT, \c
  calc.USR$PERCENT, \c
  calc.USR$LIVINGWAGEPERC \c
FROM \c
  USR$WG_ALIMONY calc \c
JOIN \c
  GD_DOCUMENT d
    ON calc.DOCUMENTKEY = d.ID \c
WHERE \c
  d.COMPANYKEY = <COMPANYKEY/> \c
  AND \c
  d.DOCUMENTTYPEKEY = (SELECT id FROM GD_P_GETID(pDocType_Alimony_ruid)) \c
  AND \c
  calc.USR$EMPLKEY = pEmplKey \c
  AND \c
  calc.USR$DATEBEGIN < \'pDateCalcTo\' \c
  AND \c
  COALESCE(calc.USR$DATEEND, '2100-01-01') >= \'pDateCalcFrom\' \c
  AND \c
  COALESCE(calc.USR$CHILDCOUNT, 0) > 0 \c
ORDER BY \c
  calc.USR$DATEBEGIN \c
",
    [
    pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_, pDocType_Alimony_ruid-_
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_TransferType, 4, [
    fID-integer, fParent-integer,
    fDateBegin-date, fName-string
    ]).
% usr_wg_TransferType(ID, Parent, DateBegin, Name)
get_sql(wg_fee_alimony, kb, usr_wg_TransferType/4,
"SELECT \c
  tt.ID, \c
  COALESCE(tt.PARENT, 0) AS Parent, \c
  COALESCE(tt.USR$DATE, current_date) AS DateBegin, \c
  tt.USR$NAME \c
FROM \c
  USR$WG_TRANSFERTYPE tt \c
ORDER BY \c
  Parent, DateBegin, tt.ID \c
",
    [
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_TransferScale, 3, [
    fTranferTypeKey-integer,
    fStartSum-float, fPercent-float
    ]).
% usr_wg_TransferScale(TranferTypeKey, StartSum, Percent)
get_sql(wg_fee_alimony, kb, usr_wg_TransferScale/3,
"SELECT \c
  ts.USR$TRANSFERTYPEKEY, \c
  COALESCE(ts.USR$STARTSUM, 0) AS StartSum, \c
  COALESCE(ts.USR$PERCENT, 0) AS Percent \c
FROM \c
  USR$WG_TRANSFERSCALE ts \c
ORDER BY \c
  ts.USR$TRANSFERTYPEKEY, StartSum \c
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
"SELECT \c
  aldebt.DOCUMENTKEY, \c
  al.USR$EMPLKEY, \c
  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS CalYear, \c
  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS CalMonth, \c
  t.USR$DATEBEGIN, \c
  aldebt.USR$ALIMONYKEY, \c
  aldebt.USR$TOTALDOCKEY, \c
  aldebt.USR$DEBTSUM \c
FROM \c
  USR$WG_ALIMONYDEBT aldebt \c
JOIN \c
  USR$WG_ALIMONY al \c
    ON al.DOCUMENTKEY = aldebt.USR$ALIMONYKEY \c
JOIN \c
  USR$WG_TOTAL t \c
    ON t.DOCUMENTKEY = aldebt.USR$TOTALDOCKEY \c
WHERE \c
  al.USR$EMPLKEY = pEmplKey \c
  AND \c
  t.USR$DATEBEGIN < \'pDateCalcFrom\' \c
ORDER BY \c
  t.USR$DATEBEGIN \c
",
    [
    pEmplKey-_, pDateCalcFrom-_
    ]).

/* удаление данных */

gd_pl_ds(wg_fee_alimony, cmd, usr_wg_AlimonyDebt_delete, 0, []).
% usr_wg_AlimonyDebt_delete
get_sql(wg_fee_alimony, cmd, usr_wg_AlimonyDebt_delete/0,
"DELETE \c
FROM \c
  USR$WG_ALIMONYDEBT aldebt \c
WHERE \c
  aldebt.USR$TOTALDOCKEY = pTotalDocKey \c
  AND \c
  aldebt.USR$ALIMONYKEY IN \c
    (SELECT al.DOCUMENTKEY FROM USR$WG_ALIMONY al WHERE al.USR$EMPLKEY = pEmplKey) \c
",
    [
    pEmplKey-_, pTotalDocKey-_
    ]).

/**/

 %
%%
