param_list(wg_avg_wage_vacation,in,[pMonthQty-12,pAvgDays-29.7,pFeeGroupKey_xid-147071456,pFeeGroupKey_dbid-274788016,pFeeGroupKeyNoCoef_xid-147757383,pFeeGroupKeyNoCoef_dbid-84733194,pBadHourType_xid_IN-'147650804, 147650786, 147650802',pBadHourType_dbid-119619099,pBadFeeType_xid_IN-'151000730',pBadFeeType_dbid-2109681374,pPayFormSalary_xid-147009181,pPayFormSalary_dbid-119619099,pTblCal_DocType_Plan_xid-147567935,pTblCal_DocType_Plan_dbid-1514418708,pTblCal_DocType_Fact_xid-187613422,pTblCal_DocType_Fact_dbid-1596169984,pSpecDep_xid-156913837,pSpecDep_dbid-131572570]).
param_list(wg_avg_wage_sick,in,[pMonthQty-6,pFeeGroupKey_xid-147071457,pFeeGroupKey_dbid-274788016,pFeeGroupKeyProp_xid-147119175,pFeeGroupKeyProp_dbid-1354510846,pPayFormSalary_xid-147009181,pPayFormSalary_dbid-119619099,pTblCal_DocType_Plan-522933937,pTblCal_DocType_Fact-522791174,pTblCal_DocType_Plan_xid-147567935,pTblCal_DocType_Plan_dbid-1514418708,pTblCal_DocType_Fact_xid-187613422,pTblCal_DocType_Fact_dbid-1596169984,pAvgSalaryRB_xid-147445419,pAvgSalaryRB_dbid-274788016,pAvgSalaryRB_Coef-3]).
param_list(wg_avg_wage_sick,in,[pEmplKey-202116758,pFirstMoveKey-332469774,pDateCalc-'2014-02-25',pIsAvgWageDoc-0,pIsPregnancy-0]).
param_list(wg_avg_wage_sick,run,[pEmplKey-202116758,pFirstMoveKey-332469774,pDateCalc-'2014-02-25',pIsAvgWageDoc-0,pIsPregnancy-0,pDateCalcFrom-'2013-08-01',pDateCalcTo-'2014-02-01',pMonthQty-6,pFeeGroupKey_xid-147071457,pFeeGroupKey_dbid-274788016,pFeeGroupKeyProp_xid-147119175,pFeeGroupKeyProp_dbid-1354510846,pPayFormSalary_xid-147009181,pPayFormSalary_dbid-119619099,pTblCal_DocType_Plan-522933937,pTblCal_DocType_Fact-522791174,pTblCal_DocType_Plan_xid-147567935,pTblCal_DocType_Plan_dbid-1514418708,pTblCal_DocType_Fact_xid-187613422,pTblCal_DocType_Fact_dbid-1596169984,pAvgSalaryRB_xid-147445419,pAvgSalaryRB_dbid-274788016,pAvgSalaryRB_Coef-3]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_MovementLine/15,pSQL-"SELECT ml.USR$EMPLKEY, ml.DOCUMENTKEY, ml.USR$FIRSTMOVE AS FirstMoveKey, EXTRACT(YEAR FROM ml.USR$DATEBEGIN) AS MoveYear, EXTRACT(MONTH FROM ml.USR$DATEBEGIN) AS MoveMonth, ml.USR$DATEBEGIN, ml.USR$SCHEDULEKEY, ml.USR$MOVEMENTTYPE, COALESCE(ml.USR$RATE, 0) AS Rate, ml.USR$LISTNUMBER, COALESCE(ml.USR$MSALARY, 0) AS MSalary, COALESCE(ml.USR$PAYFORMKEY, 0) AS PayFormKey, (SELECT id FROM gd_ruid WHERE xid = 147009181 AND dbid = 119619099) AS SalaryKey, COALESCE(ml.USR$TSALARY, 0) AS TSalary, 8 * COALESCE(USR$THOURRATE, 0) AS AvgWageRate FROM USR$WG_MOVEMENTLINE ml WHERE ml.USR$EMPLKEY = 202116758 AND ml.USR$FIRSTMOVE = 332469774 ORDER BY ml.USR$EMPLKEY, ml.USR$FIRSTMOVE, ml.USR$DATEBEGIN "]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_TblCalLine/7,pSQL-"SELECT tc.USR$EMPLKEY, tc.USR$FIRSTMOVEKEY, EXTRACT(YEAR FROM tcl.USR$DATE) AS CalYear, EXTRACT(MONTH FROM tcl.USR$DATE) AS CalMonth, tcl.USR$DATE, tcl.USR$DURATION, tcl.USR$HOURTYPE FROM USR$WG_TBLCAL tc JOIN USR$WG_TBLCALLINE tcl ON tcl.MASTERKEY = tc.DOCUMENTKEY WHERE tc.USR$EMPLKEY = 202116758 AND tc.USR$FIRSTMOVEKEY = 332469774 AND tcl.USR$DATE >= '2013-08-01' AND tcl.USR$DATE < '2014-02-01' ORDER BY tc.USR$EMPLKEY, tc.USR$FIRSTMOVEKEY, tcl.USR$DATE "]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_TblCal_FlexLine/68,pSQL-"SELECT CASE gd.DOCUMENTTYPEKEY WHEN (SELECT id FROM gd_ruid WHERE xid = 147567935 AND dbid = 1514418708) THEN 'plan' WHEN (SELECT id FROM gd_ruid WHERE xid = 187613422 AND dbid = 1596169984) THEN 'fact' ELSE 'unknown' END AS FlexType, tcfl.USR$EMPLKEY, tcfl.USR$FIRSTMOVEKEY, EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS CalYear, EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS CalMonth, t.USR$DATEBEGIN, tcfl.USR$S1, tcfl.USR$H1, tcfl.USR$S2, tcfl.USR$H2, tcfl.USR$S3, tcfl.USR$H3, tcfl.USR$S4, tcfl.USR$H4, tcfl.USR$S5, tcfl.USR$H5, tcfl.USR$S6, tcfl.USR$H6, tcfl.USR$S7, tcfl.USR$H7, tcfl.USR$S8, tcfl.USR$H8, tcfl.USR$S9, tcfl.USR$H9, tcfl.USR$S10, tcfl.USR$H10, tcfl.USR$S11, tcfl.USR$H11, tcfl.USR$S12, tcfl.USR$H12, tcfl.USR$S13, tcfl.USR$H13, tcfl.USR$S14, tcfl.USR$H14, tcfl.USR$S15, tcfl.USR$H15, tcfl.USR$S16, tcfl.USR$H16, tcfl.USR$S17, tcfl.USR$H17, tcfl.USR$S18, tcfl.USR$H18, tcfl.USR$S19, tcfl.USR$H19, tcfl.USR$S20, tcfl.USR$H20, tcfl.USR$S21, tcfl.USR$H21, tcfl.USR$S22, tcfl.USR$H22, tcfl.USR$S23, tcfl.USR$H23, tcfl.USR$S24, tcfl.USR$H24, tcfl.USR$S25, tcfl.USR$H25, tcfl.USR$S26, tcfl.USR$H26, tcfl.USR$S27, tcfl.USR$H27, tcfl.USR$S28, tcfl.USR$H28, tcfl.USR$S29, tcfl.USR$H29, tcfl.USR$S30, tcfl.USR$H30, tcfl.USR$S31, tcfl.USR$H31 FROM GD_DOCUMENT gd JOIN USR$WG_TBLCAL_FLEXLINE tcfl ON gd.ID = tcfl.DOCUMENTKEY JOIN USR$WG_TBLCAL_FLEX tcf ON tcf.DOCUMENTKEY = tcfl.MASTERKEY JOIN USR$WG_TOTAL t ON t.DOCUMENTKEY = tcf.USR$TOTALDOCKEY WHERE tcfl.USR$EMPLKEY = 202116758 AND tcfl.USR$FIRSTMOVEKEY = 332469774 AND t.USR$DATEBEGIN >= '2013-08-01' AND t.USR$DATEBEGIN < '2014-02-01' ORDER BY tcfl.USR$EMPLKEY, tcfl.USR$FIRSTMOVEKEY, t.USR$DATEBEGIN "]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_HourType/12,pSQL-"SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, ht.ID, ht.USR$CODE, ht.USR$DIGITCODE, ht.USR$DISCRIPTION ,
  ht.USR$ISWORKED, ht.USR$SHORTNAME, ht.USR$FORCALFLEX, ht.USR$FOROVERTIME, ht.USR$FORFLEX, ht.USR$WG_EXCLUDEFORSICKLIST FROM USR$WG_HOURTYPE ht "]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_TblCharge/9,pSQL-"SELECT tch.USR$EMPLKEY, tch.USR$FIRSTMOVEKEY, EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, tch.USR$DATEBEGIN, tch.USR$DEBIT, tch.USR$FEETYPEKEY, tch.USR$DOW, tch.USR$HOW FROM USR$WG_TBLCHARGE tch WHERE tch.USR$EMPLKEY = 202116758 AND NOT tch.USR$DEBIT = 0 AND tch.USR$DATEBEGIN >= '2013-08-01' AND tch.USR$DATEBEGIN < '2014-02-01' ORDER BY tch.USR$EMPLKEY, tch.USR$DATEBEGIN "]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_FeeType/5,pSQL-"SELECT 202116758 AS EmplKey,  332469774 AS FirstMoveKey, ft.USR$WG_FEEGROUPKEY, ft.USR$WG_FEETYPEKEY, ft_avg.USR$AVGDAYHOW FROM USR$CROSS179_256548741 ft JOIN USR$WG_FEETYPE ft_avg ON ft_avg.ID = ft.USR$WG_FEETYPEKEY WHERE ft.USR$WG_FEEGROUPKEY IN (SELECT id FROM gd_ruid WHERE xid = 147071457 AND dbid = 274788016 ) "]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_DbfSums/6,pSQL-"SELECT Z.USR$EMPLKEY, COALESCE(Z.USR$SUMSICK, 0) AS INSUM, COALESCE(Z.USR$MID_HOW, 0) AS INHOURES, EXTRACT(YEAR FROM IDK.USR$DATEBEGIN) AS InYear, EXTRACT(MONTH FROM IDK.USR$DATEBEGIN) AS InMonth, IDK.USR$DATEBEGIN FROM USR$GMK_SUMS Z JOIN USR$WG_TOTAL IDK ON IDK.DOCUMENTKEY  =  Z.USR$INDOCKEY WHERE Z.USR$EMPLKEY = 202116758 AND IDK.USR$DATEBEGIN >= '2013-08-01' AND IDK.USR$DATEBEGIN < '2014-02-01' ORDER BY Z.USR$EMPLKEY, IDK.USR$DATEBEGIN "]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_FeeTypeProp/4,pSQL-"SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, ft.USR$WG_FEEGROUPKEY, ft.USR$WG_FEETYPEKEY FROM USR$CROSS179_256548741 ft JOIN USR$WG_FEETYPE ft_avg ON ft_avg.ID = ft.USR$WG_FEETYPEKEY WHERE ft.USR$WG_FEEGROUPKEY IN (SELECT id FROM gd_ruid WHERE xid = 147119175 AND dbid = 1354510846 ) "]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-wg_holiday/1,pSQL-"SELECT h.holidaydate FROM wg_holiday h WHERE h.holidaydate BETWEEN '2013-08-01' AND '2014-02-01' AND COALESCE(h.disabled, 0) = 0 "]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_ExclDays/6,pSQL-"SELECT EmplKey, FirstMoveKey, ExclType, ExclWeekDay, FromDate, ToDate FROM ( SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, 'LIGHTWORKLINE' AS ExclType, 0 AS ExclWeekDay, CAST( IIF(lw.USR$DATEBEGIN < '2013-08-01', '2013-08-01', lw.USR$DATEBEGIN) AS DATE) AS FromDate, CAST( IIF(lw.USR$DATEEND IS NULL, '2014-02-01', IIF(lw.USR$DATEEND > '2014-02-01', '2014-02-01', lw.USR$DATEEND)) AS DATE) AS ToDate FROM USR$WG_LIGHTWORKLINE lw WHERE lw.USR$FIRSTMOVEKEY = 332469774 AND lw.USR$EMPLKEY = 202116758 AND lw.USR$DATEBEGIN <= '2014-02-01' AND COALESCE(lw.USR$DATEEND, '2014-02-01') >= '2013-08-01' UNION ALL SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, 'LEAVEDOCLINE' AS ExclType, 0 AS ExclWeekDay, CAST( IIF(ld.USR$DATEBEGIN < '2013-08-01', '2013-08-01', ld.USR$DATEBEGIN) AS DATE) AS FromDate, CAST( IIF(ld.USR$DATEEND IS NULL, '2014-02-01', IIF(ld.USR$DATEEND > '2014-02-01', '2014-02-01', ld.USR$DATEEND)) AS DATE) AS ToDate FROM USR$WG_LEAVEDOCLINE ld LEFT JOIN USR$WG_VACATIONTYPE t ON t.ID = ld.USR$VACATIONTYPEKEY WHERE ld.USR$FIRSTMOVEKEY = 332469774 AND ld.USR$EMPLKEY = 202116758 AND ld.USR$DATEBEGIN <= '2014-02-01' AND COALESCE(ld.USR$DATEEND, '2014-02-01') >= '2013-08-01' AND COALESCE(t.USR$EXCLUDEFORSICKLIST, 0) = 1 UNION ALL SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, 'SICKLISTJOURNAL' AS ExclType, 0 AS ExclWeekDay, CAST( IIF(s.USR$DATEBEGIN < '2013-08-01', '2013-08-01', s.USR$DATEBEGIN) AS DATE) AS FromDate, CAST( IIF(s.USR$DATEEND IS NULL, '2014-02-01', IIF(s.USR$DATEEND > '2014-02-01', '2014-02-01', s.USR$DATEEND)) AS DATE) AS ToDate FROM USR$WG_SICKLISTJOURNAL s WHERE s.USR$EMPLKEY = 202116758 AND s.USR$DATEBEGIN <= '2014-02-01' AND COALESCE(s.USR$DATEEND, '2014-02-01') >= '2013-08-01' UNION ALL SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, 'LEAVEEXTDOC' AS ExclType, 0 AS ExclWeekDay, CAST( IIF(ext.USR$DATEBEGIN < '2013-08-01', '2013-08-01', ext.USR$DATEBEGIN) AS DATE) AS FromDate, CAST( IIF(ext.USR$DATEEND IS NULL, '2014-02-01', IIF(ext.USR$DATEEND > '2014-02-01', '2014-02-01', ext.USR$DATEEND)) AS DATE) AS ToDate FROM USR$WG_LEAVEEXTDOC ext WHERE ext.USR$EMPLKEY = 202116758 AND ext.USR$DATEBEGIN <= '2014-02-01' AND COALESCE(ext.USR$DATEEND, '2014-02-01') >= '2013-08-01' UNION ALL SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, 'KINDDAYLINE' AS ExclType, kdl.USR$DAY AS ExclWeekDay, CAST( IIF(kdl.USR$DATEBEGIN < '2013-08-01', '2013-08-01', kdl.USR$DATEBEGIN) AS DATE) AS FromDate, CAST( IIF(kdl.USR$DATEEND IS NULL, '2014-02-01', IIF(kdl.USR$DATEEND > '2014-02-01', '2014-02-01', kdl.USR$DATEEND)) AS DATE) AS ToDate FROM USR$WG_KINDDAYLINE kdl WHERE kdl.USR$EMPLKEY = 202116758 AND kdl.USR$DATEBEGIN <= '2014-02-01' AND COALESCE(kdl.USR$DATEEND, '2014-02-01') >= '2013-08-01' ) ORDER BY ExclWeekDay, FromDate "]).
param_list(wg_avg_wage_sick,query,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-gd_const_AvgSalaryRB/2,pSQL-"SELECT cv.CONSTDATE, CAST(cv.CONSTVALUE AS DECIMAL(15,4)) AS AvgSalaryRB FROM GD_CONSTVALUE cv JOIN GD_CONST c ON c.ID  =  cv.CONSTKEY WHERE cv.CONSTKEY = (SELECT id FROM gd_ruid WHERE xid = 147445419 AND dbid = 274788016) ORDER BY cv.CONSTDATE "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_MovementLine/15,pSQL-"SELECT ml.USR$EMPLKEY, ml.DOCUMENTKEY, ml.USR$FIRSTMOVE AS FirstMoveKey, EXTRACT(YEAR FROM ml.USR$DATEBEGIN) AS MoveYear, EXTRACT(MONTH FROM ml.USR$DATEBEGIN) AS MoveMonth, ml.USR$DATEBEGIN, ml.USR$SCHEDULEKEY, ml.USR$MOVEMENTTYPE, COALESCE(ml.USR$RATE, 0) AS Rate, ml.USR$LISTNUMBER, COALESCE(ml.USR$MSALARY, 0) AS MSalary, COALESCE(ml.USR$PAYFORMKEY, 0) AS PayFormKey, (SELECT id FROM gd_ruid WHERE xid = 147009181 AND dbid = 119619099) AS SalaryKey, COALESCE(ml.USR$TSALARY, 0) AS TSalary, 8 * COALESCE(USR$THOURRATE, 0) AS AvgWageRate FROM USR$WG_MOVEMENTLINE ml WHERE ml.USR$EMPLKEY = 202116758 AND ml.USR$FIRSTMOVE = 332469774 ORDER BY ml.USR$EMPLKEY, ml.USR$FIRSTMOVE, ml.USR$DATEBEGIN "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_TblCalLine/7,pSQL-"SELECT tc.USR$EMPLKEY, tc.USR$FIRSTMOVEKEY, EXTRACT(YEAR FROM tcl.USR$DATE) AS CalYear, EXTRACT(MONTH FROM tcl.USR$DATE) AS CalMonth, tcl.USR$DATE, tcl.USR$DURATION, tcl.USR$HOURTYPE FROM USR$WG_TBLCAL tc JOIN USR$WG_TBLCALLINE tcl ON tcl.MASTERKEY = tc.DOCUMENTKEY WHERE tc.USR$EMPLKEY = 202116758 AND tc.USR$FIRSTMOVEKEY = 332469774 AND tcl.USR$DATE >= '2013-08-01' AND tcl.USR$DATE < '2014-02-01' ORDER BY tc.USR$EMPLKEY, tc.USR$FIRSTMOVEKEY, tcl.USR$DATE "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_TblCal_FlexLine/68,pSQL-"SELECT CASE gd.DOCUMENTTYPEKEY WHEN (SELECT id FROM gd_ruid WHERE xid = 147567935 AND dbid = 1514418708) THEN 'plan' WHEN (SELECT id FROM gd_ruid WHERE xid = 187613422 AND dbid = 1596169984) THEN 'fact' ELSE 'unknown' END AS FlexType, tcfl.USR$EMPLKEY, tcfl.USR$FIRSTMOVEKEY, EXTRACT(YEAR FROM t.USR$DATEBEGIN) AS CalYear, EXTRACT(MONTH FROM t.USR$DATEBEGIN) AS CalMonth, t.USR$DATEBEGIN, tcfl.USR$S1, tcfl.USR$H1, tcfl.USR$S2, tcfl.USR$H2, tcfl.USR$S3, tcfl.USR$H3, tcfl.USR$S4, tcfl.USR$H4, tcfl.USR$S5, tcfl.USR$H5, tcfl.USR$S6, tcfl.USR$H6, tcfl.USR$S7, tcfl.USR$H7, tcfl.USR$S8, tcfl.USR$H8, tcfl.USR$S9, tcfl.USR$H9, tcfl.USR$S10, tcfl.USR$H10, tcfl.USR$S11, tcfl.USR$H11, tcfl.USR$S12, tcfl.USR$H12, tcfl.USR$S13, tcfl.USR$H13, tcfl.USR$S14, tcfl.USR$H14, tcfl.USR$S15, tcfl.USR$H15, tcfl.USR$S16, tcfl.USR$H16, tcfl.USR$S17, tcfl.USR$H17, tcfl.USR$S18, tcfl.USR$H18, tcfl.USR$S19, tcfl.USR$H19, tcfl.USR$S20, tcfl.USR$H20, tcfl.USR$S21, tcfl.USR$H21, tcfl.USR$S22, tcfl.USR$H22, tcfl.USR$S23, tcfl.USR$H23, tcfl.USR$S24, tcfl.USR$H24, tcfl.USR$S25, tcfl.USR$H25, tcfl.USR$S26, tcfl.USR$H26, tcfl.USR$S27, tcfl.USR$H27, tcfl.USR$S28, tcfl.USR$H28, tcfl.USR$S29, tcfl.USR$H29, tcfl.USR$S30, tcfl.USR$H30, tcfl.USR$S31, tcfl.USR$H31 FROM GD_DOCUMENT gd JOIN USR$WG_TBLCAL_FLEXLINE tcfl ON gd.ID = tcfl.DOCUMENTKEY JOIN USR$WG_TBLCAL_FLEX tcf ON tcf.DOCUMENTKEY = tcfl.MASTERKEY JOIN USR$WG_TOTAL t ON t.DOCUMENTKEY = tcf.USR$TOTALDOCKEY WHERE tcfl.USR$EMPLKEY = 202116758 AND tcfl.USR$FIRSTMOVEKEY = 332469774 AND t.USR$DATEBEGIN >= '2013-08-01' AND t.USR$DATEBEGIN < '2014-02-01' ORDER BY tcfl.USR$EMPLKEY, tcfl.USR$FIRSTMOVEKEY, t.USR$DATEBEGIN "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_HourType/12,pSQL-"SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, ht.ID, ht.USR$CODE, ht.USR$DIGITCODE, ht.USR$DISCRIPTION ,
  ht.USR$ISWORKED, ht.USR$SHORTNAME, ht.USR$FORCALFLEX, ht.USR$FOROVERTIME, ht.USR$FORFLEX, ht.USR$WG_EXCLUDEFORSICKLIST FROM USR$WG_HOURTYPE ht "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_TblCharge/9,pSQL-"SELECT tch.USR$EMPLKEY, tch.USR$FIRSTMOVEKEY, EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, tch.USR$DATEBEGIN, tch.USR$DEBIT, tch.USR$FEETYPEKEY, tch.USR$DOW, tch.USR$HOW FROM USR$WG_TBLCHARGE tch WHERE tch.USR$EMPLKEY = 202116758 AND NOT tch.USR$DEBIT = 0 AND tch.USR$DATEBEGIN >= '2013-08-01' AND tch.USR$DATEBEGIN < '2014-02-01' ORDER BY tch.USR$EMPLKEY, tch.USR$DATEBEGIN "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_FeeType/5,pSQL-"SELECT 202116758 AS EmplKey,  332469774 AS FirstMoveKey, ft.USR$WG_FEEGROUPKEY, ft.USR$WG_FEETYPEKEY, ft_avg.USR$AVGDAYHOW FROM USR$CROSS179_256548741 ft JOIN USR$WG_FEETYPE ft_avg ON ft_avg.ID = ft.USR$WG_FEETYPEKEY WHERE ft.USR$WG_FEEGROUPKEY IN (SELECT id FROM gd_ruid WHERE xid = 147071457 AND dbid = 274788016 ) "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_DbfSums/6,pSQL-"SELECT Z.USR$EMPLKEY, COALESCE(Z.USR$SUMSICK, 0) AS INSUM, COALESCE(Z.USR$MID_HOW, 0) AS INHOURES, EXTRACT(YEAR FROM IDK.USR$DATEBEGIN) AS InYear, EXTRACT(MONTH FROM IDK.USR$DATEBEGIN) AS InMonth, IDK.USR$DATEBEGIN FROM USR$GMK_SUMS Z JOIN USR$WG_TOTAL IDK ON IDK.DOCUMENTKEY  =  Z.USR$INDOCKEY WHERE Z.USR$EMPLKEY = 202116758 AND IDK.USR$DATEBEGIN >= '2013-08-01' AND IDK.USR$DATEBEGIN < '2014-02-01' ORDER BY Z.USR$EMPLKEY, IDK.USR$DATEBEGIN "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_FeeTypeProp/4,pSQL-"SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, ft.USR$WG_FEEGROUPKEY, ft.USR$WG_FEETYPEKEY FROM USR$CROSS179_256548741 ft JOIN USR$WG_FEETYPE ft_avg ON ft_avg.ID = ft.USR$WG_FEETYPEKEY WHERE ft.USR$WG_FEEGROUPKEY IN (SELECT id FROM gd_ruid WHERE xid = 147119175 AND dbid = 1354510846 ) "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-wg_holiday/1,pSQL-"SELECT h.holidaydate FROM wg_holiday h WHERE h.holidaydate BETWEEN '2013-08-01' AND '2014-02-01' AND COALESCE(h.disabled, 0) = 0 "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-usr_wg_ExclDays/6,pSQL-"SELECT EmplKey, FirstMoveKey, ExclType, ExclWeekDay, FromDate, ToDate FROM ( SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, 'LIGHTWORKLINE' AS ExclType, 0 AS ExclWeekDay, CAST( IIF(lw.USR$DATEBEGIN < '2013-08-01', '2013-08-01', lw.USR$DATEBEGIN) AS DATE) AS FromDate, CAST( IIF(lw.USR$DATEEND IS NULL, '2014-02-01', IIF(lw.USR$DATEEND > '2014-02-01', '2014-02-01', lw.USR$DATEEND)) AS DATE) AS ToDate FROM USR$WG_LIGHTWORKLINE lw WHERE lw.USR$FIRSTMOVEKEY = 332469774 AND lw.USR$EMPLKEY = 202116758 AND lw.USR$DATEBEGIN <= '2014-02-01' AND COALESCE(lw.USR$DATEEND, '2014-02-01') >= '2013-08-01' UNION ALL SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, 'LEAVEDOCLINE' AS ExclType, 0 AS ExclWeekDay, CAST( IIF(ld.USR$DATEBEGIN < '2013-08-01', '2013-08-01', ld.USR$DATEBEGIN) AS DATE) AS FromDate, CAST( IIF(ld.USR$DATEEND IS NULL, '2014-02-01', IIF(ld.USR$DATEEND > '2014-02-01', '2014-02-01', ld.USR$DATEEND)) AS DATE) AS ToDate FROM USR$WG_LEAVEDOCLINE ld LEFT JOIN USR$WG_VACATIONTYPE t ON t.ID = ld.USR$VACATIONTYPEKEY WHERE ld.USR$FIRSTMOVEKEY = 332469774 AND ld.USR$EMPLKEY = 202116758 AND ld.USR$DATEBEGIN <= '2014-02-01' AND COALESCE(ld.USR$DATEEND, '2014-02-01') >= '2013-08-01' AND COALESCE(t.USR$EXCLUDEFORSICKLIST, 0) = 1 UNION ALL SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, 'SICKLISTJOURNAL' AS ExclType, 0 AS ExclWeekDay, CAST( IIF(s.USR$DATEBEGIN < '2013-08-01', '2013-08-01', s.USR$DATEBEGIN) AS DATE) AS FromDate, CAST( IIF(s.USR$DATEEND IS NULL, '2014-02-01', IIF(s.USR$DATEEND > '2014-02-01', '2014-02-01', s.USR$DATEEND)) AS DATE) AS ToDate FROM USR$WG_SICKLISTJOURNAL s WHERE s.USR$EMPLKEY = 202116758 AND s.USR$DATEBEGIN <= '2014-02-01' AND COALESCE(s.USR$DATEEND, '2014-02-01') >= '2013-08-01' UNION ALL SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, 'LEAVEEXTDOC' AS ExclType, 0 AS ExclWeekDay, CAST( IIF(ext.USR$DATEBEGIN < '2013-08-01', '2013-08-01', ext.USR$DATEBEGIN) AS DATE) AS FromDate, CAST( IIF(ext.USR$DATEEND IS NULL, '2014-02-01', IIF(ext.USR$DATEEND > '2014-02-01', '2014-02-01', ext.USR$DATEEND)) AS DATE) AS ToDate FROM USR$WG_LEAVEEXTDOC ext WHERE ext.USR$EMPLKEY = 202116758 AND ext.USR$DATEBEGIN <= '2014-02-01' AND COALESCE(ext.USR$DATEEND, '2014-02-01') >= '2013-08-01' UNION ALL SELECT 202116758 AS EmplKey, 332469774 AS FirstMoveKey, 'KINDDAYLINE' AS ExclType, kdl.USR$DAY AS ExclWeekDay, CAST( IIF(kdl.USR$DATEBEGIN < '2013-08-01', '2013-08-01', kdl.USR$DATEBEGIN) AS DATE) AS FromDate, CAST( IIF(kdl.USR$DATEEND IS NULL, '2014-02-01', IIF(kdl.USR$DATEEND > '2014-02-01', '2014-02-01', kdl.USR$DATEEND)) AS DATE) AS ToDate FROM USR$WG_KINDDAYLINE kdl WHERE kdl.USR$EMPLKEY = 202116758 AND kdl.USR$DATEBEGIN <= '2014-02-01' AND COALESCE(kdl.USR$DATEEND, '2014-02-01') >= '2013-08-01' ) ORDER BY ExclWeekDay, FromDate "]).
param_list(wg_avg_wage_sick,data,[pEmplKey-202116758,pFirstMoveKey-332469774,pQuery-gd_const_AvgSalaryRB/2,pSQL-"SELECT cv.CONSTDATE, CAST(cv.CONSTVALUE AS DECIMAL(15,4)) AS AvgSalaryRB FROM GD_CONSTVALUE cv JOIN GD_CONST c ON c.ID  =  cv.CONSTKEY WHERE cv.CONSTKEY = (SELECT id FROM gd_ruid WHERE xid = 147445419 AND dbid = 274788016) ORDER BY cv.CONSTDATE "]).
