% twg_fee_sql

:-
    GetSQL = [gd_pl_ds/5, get_sql/5],
    %dynamic(GetSQL),
    multifile(GetSQL),
    discontiguous(GetSQL).

%
wg_valid_sql(
            [
            usr_wg_FeeType/4,
            usr_wg_alimony/11,
            usr_wg_FCRate/2,
            gd_const_budget/2,
            usr_wg_Variables/2
            ]).

%
is_valid_sql(Functor/Arity) :-
    wg_valid_sql(ValidSQL),
    member(Functor/Arity, ValidSQL),
    !.

gd_pl_ds(Scope, in, usr_wg_TblCharge, 9,
    [
    fEmplKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fCredit-float, fDebit-float, fFeeTypeKey-integer
    ]) :-
    once( member(Scope, [wg_fee_alimony]) ).
% usr_wg_TblCharge(EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, Credit, Debit, FeeTypeKey)
get_sql(Scope, in, usr_wg_TblCharge/9,
"SELECT \c
  tch.USR$EMPLKEY, \c
  tch.USR$FIRSTMOVEKEY, \c
  EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, \c
  EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, \c
  tch.USR$DATEBEGIN, \c
  COALESCE(tch.USR$CREDIT, 0) AS Credit, \c
  COALESCE(tch.USR$DEBIT, 0) AS Debit, \c
  tch.USR$FEETYPEKEY \c
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
[pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_]
    ) :-
    once( member(Scope, [wg_fee_alimony]) ).

gd_pl_ds(wg_fee_alimony, in, usr_wg_FeeType, 4,
    [
    fEmplKey-integer, fFirstMoveKey-integer,
    fFeeGroupKey-integer, fFeeTypeKey-integer
    ]).
% usr_wg_FeeType(EmplKey, FeeGroupKey, FeeTypeKey)
get_sql(wg_fee_alimony, in, usr_wg_FeeType/4,
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
  ft.USR$WG_FEEGROUPKEY = \c
    (SELECT id FROM GD_P_GETID(pFeeGroupKey_ruid)) \c
",
[pEmplKey-_, pFirstMoveKey-_, pFeeGroupKey_ruid-_]
    ).

gd_pl_ds(wg_fee_alimony, in, gd_const_budget, 2, [fConstDate-date, fBudget-float]).
% gd_const_budget(ConstDate, Budget)
get_sql(wg_fee_alimony, in, gd_const_budget/2,
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
[pBudget_ruid-_]
    ).

gd_pl_ds(wg_fee_alimony, in, usr_wg_FCRate, 2, [fDate-date, fMinWage-float]).
% usr_wg_FCRate(Date, MinWage)
get_sql(wg_fee_alimony, in, usr_wg_FCRate/2,
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
[pStartDate-_]
    ).

gd_pl_ds(wg_fee_alimony, in, usr_wg_Variables, 2, [fAlias-string, fName-string]).
% usr_wg_Varuables(Alias, Name)
get_sql(wg_fee_alimony, in, usr_wg_Variables/2,
"SELECT \c
  'vBV' AS Alias, \c
  USR$NAME \c
FROM \c
  USR$WG_VARIABLES \c
WHERE \c
  ID = (SELECT id FROM GD_P_GETID(pBV_ruid)) \c
UNION ALL \c
SELECT \c
  'vForAlimony' AS Alias, \c
  USR$NAME \c
FROM \c
  USR$WG_VARIABLES \c
WHERE \c
  ID = (SELECT id FROM GD_P_GETID(pForAlimony_ruid)) \c
",
[pBV_ruid-_, pForAlimony_ruid-_]
    ).

gd_pl_ds(wg_fee_alimony, in, usr_wg_alimony, 11,
    [
    fEmplKey-integer,
    fDateBegin-date, fDateEnd-date,
    fDebtSum-float, fFormula-string,
    fTransferTypeKey-integer, fRecipient-integer,
    fRestPercent-float, fChildeCount-integer, fPercent-float
    ]).
% usr_wg_alimony(EmplKey, DateBegin, DateEnd, DebtSum, Formula, TransferTypeKey, Recipient, RestPercent, ChildeCount, Percent)
get_sql(wg_fee_alimony, in, usr_wg_alimony/11,
"SELECT \c
  calc.USR$EMPLKEY, \c
  calc.USR$DATEBEGIN, \c
  calc.USR$DATEEND, \c
  calc.USR$DEBTSUM, \c
  calc.USR$FORMULA, \c
  calc.USR$TRANSFERTYPEKEY, \c
  calc.USR$RECIPIENT, \c
  calc.USR$RESTPERCENT, \c
  calc.USR$CHILDCOUNT, \c
  calc.USR$PERCENT, \c
  calc.USR$LIVINGWAGEPERC \c
FROM USR$WG_ALIMONY calc \c
  JOIN GD_DOCUMENT d
    ON calc.DOCUMENTKEY = d.ID \c
WHERE \c
  d.COMPANYKEY = <COMPANYKEY/> \c
  AND \c
  calc.USR$EMPLKEY = \'pEmplKey\' \c
  AND \c
  calc.USR$DATEBEGIN <= \'pDateCalcTo\' \c
  AND \c
  (calc.USR$DATEEND >= \'pDateCalcFrom\' OR calc.USR$DATEEND is NULL) \c
  AND
  d.DocumentTypeKey = (SELECT id FROM GD_P_GETID(pDocType_ruid)) \c
ORDER BY \c
  calc.USR$DATEBEGIN \c
",
[pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_, pDocType_ruid-_]
    ).

%
