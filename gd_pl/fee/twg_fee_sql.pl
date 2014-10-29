%% twg_fee_sql
%  спецификации и sql-шаблоны для базы знаний twg_fee
%

:-  style_check(-atom),
    GetSQL = [gd_pl_ds/5, get_sql/5],
    %dynamic(GetSQL),
    multifile(GetSQL),
    discontiguous(GetSQL).

%
wg_valid_sql(
            [
            usr_wg_MovementLine/15,
            gd_contact/2,
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
  8 * COALESCE(USR$THOURRATE, 0) AS AvgWageRate
FROM
  USR$WG_MOVEMENTLINE ml
JOIN
  USR$WG_KINDOFWORK kw
    ON kw.ID = ml.USR$KINDOFWORKKEY
WHERE
  ml.USR$EMPLKEY = pEmplKey
  AND
  ml.USR$KINDOFWORKKEY =
    (SELECT id FROM GD_P_GETID(pKindOfWork_Basic_ruid))
ORDER BY
  ml.USR$EMPLKEY,
  ml.USR$FIRSTMOVE,
  ml.USR$DATEBEGIN
",
    [
    pEmplKey-_, pPayFormSalary_ruid-_, pKindOfWork_Basic_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).

gd_pl_ds(Scope, kb, gd_contact, 2, [
    fID-integer, fName-string
    ]) :-
    memberchk(Scope, [
        wg_fee_alimony
        ]).
% gd_contact(ID, Name)
get_sql(Scope, kb, gd_contact/2,
"
SELECT
  c.ID, c.NAME
FROM
  GD_CONTACT c
WHERE
  c.ID = pEmplKey
UNION ALL
SELECT
  c.ID, c.NAME
FROM
  GD_CONTACT c
JOIN
  USR$WG_ALIMONY al
    ON al.USR$RECIPIENT = c.ID
WHERE
  al.USR$EMPLKEY = pEmplKey
",
    [
    pEmplKey-_
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
"
SELECT
  tch.USR$DOCUMENTKEY,
  tch.USR$EMPLKEY,
  tch.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear,
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth,
  tch.USR$DATEBEGIN,
  tch.USR$DEBIT,
  tch.USR$CREDIT,
  tch.USR$FEETYPEKEY,
  tch.USR$DOW,
  tch.USR$HOW,
  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS TotalYear,
  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS TotalMonth,
  t.USR$DATEBEGIN AS TotalDateBegin
FROM
  USR$WG_TBLCHARGE tch
JOIN
  USR$WG_TOTAL t
    ON t.DOCUMENTKEY = tch.USR$TOTALDOCKEY
WHERE
  tch.USR$EMPLKEY = pEmplKey
  AND
  tch.USR$TOTALDOCKEY = pTotalDocKey
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
"
SELECT
  tch.USR$DOCUMENTKEY,
  tch.USR$EMPLKEY,
  tch.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear,
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth,
  tch.USR$DATEBEGIN,
  tch.USR$DEBIT,
  tch.USR$CREDIT,
  tch.USR$FEETYPEKEY,
  EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS TotalYear,
  EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS TotalMonth,
  t.USR$DATEBEGIN AS TotalDateBegin
FROM
  USR$WG_TBLCHARGE tch
JOIN
  USR$WG_TOTAL t
    ON t.DOCUMENTKEY = tch.USR$TOTALDOCKEY
WHERE
  tch.USR$EMPLKEY = pEmplKey
  AND
  t.USR$DATEBEGIN >= 'pDatePrevCalcFrom'
  AND
  t.USR$DATEBEGIN < 'pDatePrevCalcTo'
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
"
SELECT
  tch.USR$DOCUMENTKEY,
  tch.USR$EMPLKEY,
  tch.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear,
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth,
  tch.USR$DATEBEGIN,
  tch.USR$DEBIT,
  tch.USR$CREDIT,
  tch.USR$FEETYPEKEY
FROM
  USR$WG_TBLCHARGE tch
WHERE
  tch.USR$EMPLKEY = pEmplKey
  AND
  tch.USR$DATEBEGIN < 'pDateCalcFrom'
  AND
  tch.USR$FEETYPEKEY =
    (SELECT id FROM GD_P_GETID(pFeeType_AlimonyDebt_ruid))
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
"
SELECT
  pEmplKey AS EmplKey,
  ft.USR$WG_FEEGROUPKEY,
  ft.USR$WG_FEETYPEKEY,
  ft_avg.USR$AVGDAYHOW
FROM
  USR$CROSS179_256548741 ft
JOIN
  USR$WG_FEETYPE ft_avg
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY
WHERE
  ft.USR$WG_FEEGROUPKEY =
    (SELECT id FROM GD_P_GETID(pFeeGroupKey_ruid))
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
"
SELECT
  pEmplKey AS EmplKey,
  ft.USR$WG_FEEGROUPKEY,
  ft.USR$WG_FEETYPEKEY
FROM
  USR$CROSS179_256548741 ft
JOIN
  USR$WG_FEETYPE ft_avg
    ON ft_avg.ID = ft.USR$WG_FEETYPEKEY
WHERE
  ft.USR$WG_FEEGROUPKEY =
    (SELECT id FROM GD_P_GETID(pFeeGroupKey_IncomeTax_ruid))
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
"
SELECT
  ft.ID,
  CASE ft.ID
    WHEN
      (SELECT id FROM GD_P_GETID(pFeeType_Alimony_ruid))
        THEN 'ftAlimony'
    WHEN
      (SELECT id FROM GD_P_GETID(pFeeType_HolidayComp_ruid))
        THEN 'ftHolidayComp'
    WHEN
      (SELECT id FROM GD_P_GETID(pFeeType_IncomeTax_ruid))
        THEN 'ftIncomeTax'
    WHEN
      (SELECT id FROM GD_P_GETID(pFeeType_TransferDed_ruid))
        THEN 'ftTransferDed'
    WHEN
      (SELECT id FROM GD_P_GETID(pFeeType_AlimonyDebt_ruid))
        THEN 'ftAlimonyDebt'
    ELSE
        'unknown'
  END
    AS Alias,
  USR$NAME,
  USR$ROUNDBYFEETYPE,
  USR$ROUNDTYPE,
  USR$ROUNDVALUE
FROM
  USR$WG_FEETYPE ft
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
"
SELECT
  tc.USR$EMPLKEY,
  tc.USR$FIRSTMOVEKEY,
  EXTRACT(YEAR FROM tcl.USR$DATE) AS CalYear,
  EXTRACT(MONTH FROM tcl.USR$DATE) AS CalMonth,
  tcl.USR$DATE,
  tcl.USR$DURATION,
  tcl.USR$HOURTYPE
FROM
  USR$WG_TBLCAL tc
JOIN
  USR$WG_TBLCALLINE tcl
    ON tcl.MASTERKEY = tc.DOCUMENTKEY
WHERE
  tc.USR$EMPLKEY = pEmplKey
  AND
  tcl.USR$DATE >= 'pDateCalcFrom'
  AND
  tcl.USR$DATE < 'pDateCalcTo'
ORDER BY
  tc.USR$EMPLKEY,
  tc.USR$FIRSTMOVEKEY,
  tcl.USR$DATE
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
"
SELECT
  CASE gd.DOCUMENTTYPEKEY
    WHEN
      (SELECT id FROM GD_P_GETID(pTblCal_DocType_Plan_ruid))
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
  t.USR$DATEBEGIN >= 'pDateCalcFrom'
  AND
  t.USR$DATEBEGIN < 'pDateCalcTo'
 ORDER BY
   tcfl.USR$EMPLKEY,
   tcfl.USR$FIRSTMOVEKEY,
   t.USR$DATEBEGIN
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
"
SELECT
  fc.USR$WG_DATE,
  fc.USR$WG_MINWAGE
FROM
  USR$WG_FCRATE fc
WHERE
  fc.USR$WG_DATE >= 'pStartDate'
ORDER BY
  fc.USR$WG_DATE
",
    [
    pStartDate-_
    ]).

gd_pl_ds(wg_fee_alimony, kb, gd_const_budget, 2, [
    fConstDate-date, fBudget-float
    ]).
% gd_const_budget(ConstDate, Budget)
get_sql(wg_fee_alimony, kb, gd_const_budget/2,
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
  cv.CONSTDATE >= 'pStartDate'
  AND
  cv.CONSTKEY =
    (SELECT id FROM GD_P_GETID(pBudget_ruid))
ORDER BY
  cv.CONSTDATE
",
    [
    pStartDate-_, pBudget_ruid-_
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_Variables, 2, [
    fAlias-string, fName-string
    ]).
% usr_wg_Varuables(Alias, Name)
get_sql(wg_fee_alimony, kb, usr_wg_Variables/2,
"
SELECT
  'vBV' AS Alias,
  USR$NAME
FROM
  USR$WG_VARIABLES
WHERE
  ID = (SELECT id FROM GD_P_GETID(pVar_BV_ruid))
UNION ALL
SELECT
  'vForAlimony' AS Alias,
  USR$NAME
FROM
  USR$WG_VARIABLES
WHERE
  ID = (SELECT id FROM GD_P_GETID(pVar_ForAlimony_ruid))
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
"
SELECT
  calc.DOCUMENTKEY,
  calc.USR$EMPLKEY,
  calc.USR$DATEBEGIN,
  COALESCE(calc.USR$DATEEND, CAST('pNullDate' AS DATE)) AS DateEnd,
  calc.USR$DEBTSUM,
  calc.USR$FORMULA,
  calc.USR$TRANSFERTYPEKEY,
  calc.USR$RECIPIENT,
  calc.USR$RESTPERCENT,
  calc.USR$CHILDCOUNT,
  calc.USR$PERCENT,
  calc.USR$LIVINGWAGEPERC
FROM
  USR$WG_ALIMONY calc
JOIN
  GD_DOCUMENT d
    ON calc.DOCUMENTKEY = d.ID
WHERE
  d.COMPANYKEY = <COMPANYKEY/>
  AND
  d.DOCUMENTTYPEKEY = (SELECT id FROM GD_P_GETID(pDocType_Alimony_ruid))
  AND
  calc.USR$EMPLKEY = pEmplKey
  AND
  calc.USR$DATEBEGIN < 'pDateCalcTo'
  AND
  COALESCE(calc.USR$DATEEND, 'pNullDate') >= 'pDateCalcFrom'
ORDER BY
  calc.USR$DATEBEGIN
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
"
SELECT
  tt.ID,
  COALESCE(tt.PARENT, 0) AS Parent,
  COALESCE(tt.USR$DATE, current_date) AS DateBegin,
  tt.USR$NAME
FROM
  USR$WG_TRANSFERTYPE tt
ORDER BY
  Parent, DateBegin, tt.ID
",
    [
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_TransferScale, 3, [
    fTranferTypeKey-integer,
    fStartSum-float, fPercent-float
    ]).
% usr_wg_TransferScale(TranferTypeKey, StartSum, Percent)
get_sql(wg_fee_alimony, kb, usr_wg_TransferScale/3,
"
SELECT
  ts.USR$TRANSFERTYPEKEY,
  COALESCE(ts.USR$STARTSUM, 0) AS StartSum,
  COALESCE(ts.USR$PERCENT, 0) AS Percent
FROM
  USR$WG_TRANSFERSCALE ts
ORDER BY
  ts.USR$TRANSFERTYPEKEY, StartSum
",
    [
    ]).

gd_pl_ds(wg_fee_alimony, kb, usr_wg_AlimonyDebt, 8, [
    fDocKey-integer, fEmplKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateDebt-date,
    fAlimonyKey-integer, fTotalDocKey-integer, fDebtSum-float
    ]).
% usr_wg_AlimonyDebt(DocKey, EmplKey, CalYear, CalMonth, DateDebt, AlimonyKey, TotalDocKey, DebtSum)
get_sql(wg_fee_alimony, kb, usr_wg_AlimonyDebt/8,
"
SELECT
  aldebt.DOCUMENTKEY,
  al.USR$EMPLKEY,
  EXTRACT(YEAR FROM aldebt.USR$DATEDEBT) AS CalYear,
  EXTRACT(MONTH FROM aldebt.USR$DATEDEBT) AS CalMonth,
  aldebt.USR$DATEDEBT,
  aldebt.USR$ALIMONYKEY,
  aldebt.USR$TOTALDOCKEY,
  aldebt.USR$DEBTSUM
FROM
  USR$WG_ALIMONYDEBT aldebt
JOIN
  USR$WG_ALIMONY al
    ON al.DOCUMENTKEY = aldebt.USR$ALIMONYKEY
WHERE
  al.USR$EMPLKEY = pEmplKey
  AND
  aldebt.USR$DATEDEBT < 'pDateCalcTo'
  AND
  aldebt.USR$DATEDEBT >=
    (SELECT FIRST 1
       ml.USR$DATEBEGIN
     FROM
       USR$WG_MOVEMENTLINE ml
     WHERE
       ml.USR$EMPLKEY = pEmplKey
       AND
       ml.DOCUMENTKEY = ml.USR$FIRSTMOVE
       AND
       ml.USR$MOVEMENTTYPE = 1
     ORDER BY
       ml.USR$DATEBEGIN DESC
    )
ORDER BY
  aldebt.USR$DATEDEBT
",
    [
    pEmplKey-_, pDateCalcTo-_
    ]).

/* удаление данных */

gd_pl_ds(wg_fee_alimony, cmd, usr_wg_AlimonyDebt_delete, 0, []).
% usr_wg_AlimonyDebt_delete
get_sql(wg_fee_alimony, cmd, usr_wg_AlimonyDebt_delete/0,
"
DELETE
FROM
  USR$WG_ALIMONYDEBT aldebt
WHERE
  COALESCE(aldebt.USR$MANUALDEBT, 0) = 0
  AND
  aldebt.USR$DATEDEBT >= 'pDateCalcFrom'
  AND
  aldebt.USR$DATEDEBT < 'pDateCalcTo'
  AND
  aldebt.USR$ALIMONYKEY IN
    (SELECT al.DOCUMENTKEY FROM USR$WG_ALIMONY al WHERE al.USR$EMPLKEY = pEmplKey)
  AND
  aldebt.USR$DATEDEBT >=
    (SELECT FIRST 1
       ml.USR$DATEBEGIN
     FROM
       USR$WG_MOVEMENTLINE ml
     WHERE
       ml.USR$EMPLKEY = pEmplKey
       AND
       ml.DOCUMENTKEY = ml.USR$FIRSTMOVE
       AND
       ml.USR$MOVEMENTTYPE = 1
     ORDER BY
       ml.USR$DATEBEGIN DESC
    )
",
    [
    pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_
    ]).

/**/

 %
%%
