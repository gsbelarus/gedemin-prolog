%% twg_pu_sql
%  спецификации и sql-шаблоны для базы знаний twg_pu
%

:-  style_check(-atom),
    GetSQL = [gd_pl_ds/5, get_sql/5],
    %dynamic(GetSQL),
    multifile(GetSQL),
    discontiguous(GetSQL).

%
wg_valid_sql([
            usr_wg_MovementLine/10,
            usr_wg_KindOfWork/4,
            usr_wg_PersonalCard/7,
            gd_people/7,
            usr_wg_Contract/6,
            usr_wg_TblCharge/11,
            usr_wg_FeeType/2,
            usr_wg_FeeTypeSick/1,
            usr_wg_FeeType_Dict/3,
            usr_wg_TblCalLine/7,
            usr_wg_TblCal_FlexLine/68,
            usr_wg_HourType/8,
            usr_wg_ExclDays/8,
            gd_const_AvgSalaryRB/2,
            -
            ]).

%
is_valid_sql(Functor/Arity) :-
    wg_valid_sql(ValidSQL),
    memberchk(Functor/Arity, ValidSQL),
    !.

gd_pl_ds(Scope, kb, usr_wg_MovementLine, 10, [
    fEmplKey-integer, fDocumentKey-integer, fFirstMoveKey-integer,
    fMoveYear-integer, fMoveMonth-integer, fDateBegin-date,
    fMovementType-integer, fKindOfWorkKey-integer,
    fIsContract-boolean, fIsPractice-boolean
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% usr_wg_MovementLine(
%     EmplKey, DocumentKey, FirstMoveKey, MoveYear, MoveMonth, DateBegin,
%     MovementType, KindOfWorkKey, IsContract, IsPractice)
get_sql(Scope, kb, usr_wg_MovementLine/10,
"
SELECT
  ml.USR$EMPLKEY,
  ml.DOCUMENTKEY,
  ml.USR$FIRSTMOVE AS FirstMoveKey,
  EXTRACT(YEAR FROM ml.USR$DATEBEGIN) AS MoveYear,
  EXTRACT(MONTH FROM ml.USR$DATEBEGIN) AS MoveMonth,
  ml.USR$DATEBEGIN,
  ml.USR$MOVEMENTTYPE,
  ml.USR$KINDOFWORKKEY,
  ml.USR$ISCONTRACT,
  m.USR$ISPRACTICE
FROM
  USR$WG_MOVEMENTLINE ml
JOIN
  USR$WG_MOVEMENT m
  ON m.DOCUMENTKEY = ml.MASTERKEY
WHERE
  ml.USR$EMPLKEY = pEmplKey
ORDER BY
  ml.USR$EMPLKEY,
  ml.USR$FIRSTMOVE,
  ml.USR$DATEBEGIN
",
    [
    pEmplKey-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, usr_wg_KindOfWork, 4, [
    fID-integer, fAlias-string,
    fCode-string, fName-string
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% usr_wg_KindOfWork(ID, Alias, Code, Name)
get_sql(Scope, kb, usr_wg_KindOfWork/4,
"
SELECT
  kw.ID,
  CASE kw.ID
    WHEN
      (SELECT id FROM GD_P_GETID(pKindOfWork_Basic_ruid))
        THEN 'kwBasic'
    WHEN
      (SELECT id FROM GD_P_GETID(pKindOfWork_ByWork_ruid))
        THEN 'kwByWork'
    WHEN
      (SELECT id FROM GD_P_GETID(pKindOfWork_ByWorkOuter_ruid))
        THEN 'kwByWorkOuter'
    ELSE
        'unknown'
  END
    AS Alias,
  kw.USR$CODE,
  kw.USR$NAME
FROM
  USR$WG_KINDOFWORK kw
",
    [
    pKindOfWork_Basic_ruid-_,
    pKindOfWork_ByWork_ruid-_,
    pKindOfWork_ByWorkOuter_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, usr_wg_PersonalCard, 7, [
    fEmplKey-integer, fF-string, fI-string, fO-string, fSex-string,
    fPersonalNumber-string, fPensionerDate-date
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% usr_wg_PersonalCard(EmplKey, F, I, O, Sex, PersonalNumber, PensionerDate)
get_sql(Scope, kb, usr_wg_PersonalCard/7,
"
SELECT FIRST(1)
  pc.USR$EMPLKEY,
  REPLACE( UPPER(pc.USR$SURNAME), 'Ё', 'Е' ) AS F,
  UPPER( LEFT(pc.USR$FIRSTNAME, 1) ) AS I,
  UPPER( LEFT(pc.USR$MIDDLENAME, 1) ) AS O,
  pc.USR$SEX,
  pc.USR$INSURANCENUMBER AS PersonalNumber,
  COALESCE(pc.USR$PENSIONERDATE, CAST('pNullDate' AS DATE)) AS PensionerDate
FROM
  USR$WG_PERSONALCARD pc
WHERE
  pc.USR$EMPLKEY = pEmplKey
ORDER BY
  pc.USR$FILLDATE DESC
",
    [
    pEmplKey-_, pNullDate-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, gd_people, 7, [
    fEmplKey-integer, fF-string, fI-string, fO-string, fSex-string,
    fPersonalNumber-string, fBirthDay-date
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% gd_people(EmplKey, F, I, O, Sex, PersonalNumber, BirthDay)
get_sql(Scope, kb, gd_people/7,
"
SELECT
  p.CONTACTKEY AS EmplKey,
  REPLACE( UPPER(p.SURNAME), 'Ё', 'Е' ) AS F,
  UPPER( LEFT(p.FIRSTNAME, 1) ) AS I,
  UPPER( LEFT(p.MIDDLENAME, 1) ) AS O,
  p.SEX,
  p.PERSONALNUMBER,
  p.BIRTHDAY
FROM
  GD_PEOPLE p
WHERE
  p.CONTACTKEY = pEmplKey
",
    [
    pEmplKey-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, usr_wg_Contract, 6, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fDateBegin-date, fDateEnd-date,
    fDocumentDate-date, fNumber-string
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% usr_wg_Contract(EmplKey, FirstMoveKey, DateBegin, DateEnd, DocumentDate, Number)
get_sql(Scope, kb, usr_wg_Contract/6,
"
SELECT
  c.USR$EMPLKEY,
  c.USR$FIRSTMOVEKEY,
  c.USR$DATEBEGIN,
  c.USR$DATEEND,
  d.DOCUMENTDATE,
  d.NUMBER
FROM
  USR$WG_CONTRACT c
JOIN
  GD_DOCUMENT d
    ON d.ID = c.DOCUMENTKEY
WHERE
  c.USR$EMPLKEY = pEmplKey
",
    [
    pEmplKey-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblCharge, 11, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDateBegin-date,
    fDebit-float, fCredit-float, fFeeTypeKey-integer,
    fDOW-float, fHOW-float, fPayPeriod-integer
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% usr_wg_TblCharge(EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, Debit, Credit, FeeTypeKey, DOW, HOW, PayPeriod)
get_sql(Scope, kb, usr_wg_TblCharge/11,
"
SELECT
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
  COALESCE(ft.USR$PAYPERIOD, 0) AS PayPeriod
FROM
  USR$WG_TBLCHARGE tch
JOIN
  USR$WG_FEETYPE ft
    ON ft.ID = tch.USR$FEETYPEKEY
WHERE
  tch.USR$EMPLKEY = pEmplKey
  AND
  tch.USR$DATEBEGIN >= 'pDateCalcFrom'
  AND
  tch.USR$DATEBEGIN < 'pDateCalcTo'
  AND
  COALESCE(ft.USR$PAYPERIOD, 0) >= 0
ORDER BY
  tch.USR$EMPLKEY,
  tch.USR$FIRSTMOVEKEY,
  tch.USR$DATEBEGIN
",
    [
    pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, usr_wg_FeeType, 2, [
    fFeeGroupKey-integer, fFeeTypeKey-integer
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% usr_wg_FeeType(FeeGroupKey, FeeTypeKey)
get_sql(Scope, kb, usr_wg_FeeType/2,
"
SELECT
  ft.USR$WG_FEEGROUPKEY,
  ft.USR$WG_FEETYPEKEY
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
    pFeeGroupKey_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, usr_wg_FeeTypeSick, 1, [
    fID-integer
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% usr_wg_FeeTypeSick(ID)
get_sql(Scope, kb, usr_wg_FeeTypeSick/1,
"
SELECT
  ft.ID
FROM
  USR$WG_FEETYPE ft
WHERE
  ft.PARENT =
    (SELECT id FROM GD_P_GETID(pFeeParentSick_ruid))
  AND
  NOT ft.ID = (SELECT id FROM GD_P_GETID(pFeeType_JobIll_ruid))
",
    [
    pFeeParentSick_ruid-_, pFeeType_JobIll_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, usr_wg_FeeType_Dict, 3, [
    fID-integer, fAlias-string, fName-string
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% usr_wg_FeeType_Dict(ID, Alias, Name)
get_sql(Scope, kb, usr_wg_FeeType_Dict/3,
"
SELECT
  ft.ID,
  CASE ft.ID
    WHEN
      (SELECT id FROM GD_P_GETID(pFeeType_SocInsurance_ruid))
        THEN 'ftSocInsurance'
    ELSE
        'unknown'
  END
    AS Alias,
  USR$NAME
FROM
  USR$WG_FEETYPE ft
",
    [
    pFeeType_SocInsurance_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, usr_wg_TblCalLine, 7, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fCalYear-integer, fCalMonth-integer, fDate-date,
    fDuration-float, fHoureType-integer
    ]) :-
    memberchk(Scope, [
        wg_pu_3
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
        wg_pu_3
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
        wg_pu_3
        ]).
% usr_wg_TblCal_FlexLine(FlexType, EmplKey, FirstMoveKey, CalYear, CalMonth, DateBegin, S1, H1, ..., S31, H31)
get_sql(Scope, kb, usr_wg_TblCal_FlexLine/68,
"
SELECT
  CASE gd.DOCUMENTTYPEKEY
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
    pTblCal_DocType_Fact_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, usr_wg_HourType, 8, [
    fID-integer, fCode-string, fDigitCode-string,
    fDiscription-string, fIsWorked-integer, fShortName-string,
    fAlias-string, fForPU3-boolean
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% usr_wg_HourType(ID, Code, DigitCode, Description, IsWorked, ShortName, Alias, ForPU3)
get_sql(Scope, kb, usr_wg_HourType/8,
"
SELECT
  ht.ID,
  ht.USR$CODE,
  ht.USR$DIGITCODE,
  ht.USR$DISCRIPTION,
  ht.USR$ISWORKED,
  ht.USR$SHORTNAME,
  CASE ht.ID
    WHEN
      (SELECT id FROM GD_P_GETID(pHourType_Sick_ruid))
        THEN 'htSick'
    WHEN
      (SELECT id FROM GD_P_GETID(pHourType_CareOf_ruid))
        THEN 'htCareOf'
    WHEN
      (SELECT id FROM GD_P_GETID(pHourType_Pregnancy_ruid))
        THEN 'htPregnancy'
    WHEN
      (SELECT id FROM GD_P_GETID(pHourType_MotherDay_ruid))
        THEN 'htMotherDay'
    ELSE
        'unknown'
  END
    AS Alias,
  ht.USR$FORPU3
FROM
  USR$WG_HOURTYPE ht
",
    [
    pHourType_Sick_ruid-_,
    pHourType_CareOf_ruid-_,
    pHourType_Pregnancy_ruid-_,
    pHourType_MotherDay_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, usr_wg_ExclDays, 8, [
    fEmplKey-integer, fFirstMoveKey-integer,
    fExclType-string, fOrderType-integer, fHourType-integer,
    fExclWeekDay-integer,
    fFromDate-date, fToDate-date
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).
% usr_wg_ExclDays(EmplKey, FirstMoveKey, ExclType, OrderType, HourType, ExclWeekDay, FromDate, ToDate)
get_sql(Scope, kb, usr_wg_ExclDays/8,
"
SELECT
  EmplKey, FirstMoveKey, ExclType, OrderType, HourType, ExclWeekDay, FromDate, ToDate
FROM (
SELECT
  ld.USR$EMPLKEY AS EmplKey,
  ld.USR$FIRSTMOVEKEY AS FirstMoveKey,
  'LEAVEDOCLINE' AS ExclType,
  t.USR$TYPE AS OrderType,
  t.USR$HOURTYPE AS HourType,
  0 AS ExclWeekDay,
  CAST( IIF(ld.USR$DATEBEGIN < 'pDateCalcFrom', 'pDateCalcFrom', ld.USR$DATEBEGIN) AS DATE) AS FromDate,
  CAST( IIF(ld.USR$DATEEND IS NULL, 'pDateCalcTo', IIF(ld.USR$DATEEND > 'pDateCalcTo', 'pDateCalcTo', ld.USR$DATEEND)) AS DATE) AS ToDate
FROM USR$WG_LEAVEDOCLINE ld
JOIN USR$WG_VACATIONTYPE t ON t.ID = ld.USR$VACATIONTYPEKEY
WHERE ld.USR$EMPLKEY = pEmplKey
  AND ld.USR$DATEBEGIN <= 'pDateCalcTo'
  AND COALESCE(ld.USR$DATEEND, 'pDateCalcTo') >= 'pDateCalcFrom'
UNION ALL
SELECT
  s.USR$EMPLKEY AS EmplKey,
  0 AS FirstMoveKey,
  'SICKLIST' AS ExclType,
  t.USR$CALCTYPE AS OrderType,
  (SELECT id FROM GD_P_GETID(pHourType_Sick_ruid)) AS HourType,
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
  kdl.USR$EMPLKEY AS EmplKey,
  0 AS FirstMoveKey,
  'KINDDAYLINE' AS ExclType,
  0 AS OrderType,
  (SELECT id FROM GD_P_GETID(pHourType_MotherDay_ruid)) AS HourType,
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
    pEmplKey-_, pDateCalcFrom-_, pDateCalcTo-_,
    pHourType_Sick_ruid-_, pHourType_MotherDay_ruid-_
    ]) :-
    memberchk(Scope, [
        wg_pu_3
        ]).

gd_pl_ds(Scope, kb, gd_const_AvgSalaryRB, 2, [
    fConstDate-date, fAvgSalaryRB-float
    ]) :-
    memberchk(Scope, [
        wg_pu_3
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
        wg_pu_3
        ]).

 %
%%
