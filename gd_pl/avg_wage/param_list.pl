param_list(wg_avg_wage_vacation,in,[pConnection-gsdb,pMonthQty-12,pAvgDays-29.7,pFeeGroupKey_xid-147071456,pFeeGroupKey_dbid-274788016,pFeeGroupKeyNoCoef_xid-0,pFeeGroupKeyNoCoef_dbid-0,pBadHourType_xid_IN-'147650804, 147650786, 147650802',pBadHourType_dbid-119619099,pBadFeeType_xid_IN-'151000730',pBadFeeType_dbid-2109681374]).
param_list(wg_avg_wage_vacation,in,[pEmplKey-154226364,pFirstMoveKey-154226368,pDateCalc-'2013-11-01',pMonthOffset-0,pCoefOption-fc_fcratesum]).
param_list(wg_avg_wage_vacation,run,[pEmplKey-154226364,pFirstMoveKey-154226368,pDateCalc-'2013-11-01',pMonthOffset-0,pCoefOption-fc_fcratesum,pDateCalcFrom-'2012-11-01',pDateCalcTo-'2013-11-01',pDateNormFrom-'2013-01-01',pDateNormTo-'2014-01-01',pConnection-gsdb,pMonthQty-12,pAvgDays-29.7,pFeeGroupKey_xid-147071456,pFeeGroupKey_dbid-274788016,pFeeGroupKeyNoCoef_xid-0,pFeeGroupKeyNoCoef_dbid-0,pBadHourType_xid_IN-'147650804, 147650786, 147650802',pBadHourType_dbid-119619099,pBadFeeType_xid_IN-'151000730',pBadFeeType_dbid-2109681374]).
param_list(wg_avg_wage_vacation,query,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_MovementLine/9,pSQL-"SELECT ml.USR$EMPLKEY, ml.DOCUMENTKEY, ml.USR$FIRSTMOVE AS FirstMoveKey, ml.USR$DATEBEGIN, ml.USR$SCHEDULEKEY, ml.USR$MOVEMENTTYPE, ml.USR$RATE, ml.USR$LISTNUMBER, ml.USR$MSALARY FROM USR$WG_MOVEMENTLINE ml WHERE ml.USR$EMPLKEY = 154226364 AND ml.USR$FIRSTMOVE = 154226368 ORDER BY ml.USR$EMPLKEY, ml.USR$FIRSTMOVE, ml.USR$DATEBEGIN "]).
param_list(wg_avg_wage_vacation,query,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_FCRate/4,pSQL-"SELECT 154226364 AS EmplKey, 154226368 AS FirstMoveKey, fc.USR$WG_DATE, fc.USR$WG_FCRATESUM FROM USR$WG_FCRATE fc ORDER BY fc.USR$WG_DATE "]).
param_list(wg_avg_wage_vacation,query,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_TblDayNorm/8,pSQL-"SELECT EmplKey, FirstMoveKey, TheDay, WYear, WMonth, WDay, WDuration, WorkDay FROM USR$WG_TBLCALDAY_P(154226364, 154226368, '2012-11-01', '2013-11-01') "]).
param_list(wg_avg_wage_vacation,query,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_TblYearNorm/5,pSQL-"SELECT EmplKey, FirstMoveKey, WYear, SUM(WDuration) AS WHoures, SUM(WorkDay) AS WDays FROM USR$WG_TBLCALDAY_P(154226364, 154226368, '2013-01-01', '2014-01-01') GROUP BY EmplKey, FirstMoveKey, WYear "]).
param_list(wg_avg_wage_vacation,query,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_TblCharge/9,pSQL-"SELECT tch.USR$EMPLKEY, tch.USR$FIRSTMOVEKEY, EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, tch.USR$DATEBEGIN, tch.USR$DEBIT, tch.USR$FEETYPEKEY, tch.USR$DOW, tch.USR$HOW FROM USR$WG_TBLCHARGE tch WHERE tch.USR$EMPLKEY = 154226364 AND tch.USR$DEBIT > 0 AND tch.USR$DATEBEGIN >= '2012-11-01' AND tch.USR$DATEBEGIN < '2013-11-01' ORDER BY tch.USR$EMPLKEY, tch.USR$DATEBEGIN "]).
param_list(wg_avg_wage_vacation,query,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_FeeType/5,pSQL-"SELECT 154226364 AS EmplKey,  154226368 AS FirstMoveKey, ft.USR$WG_FEEGROUPKEY, ft.USR$WG_FEETYPEKEY, ft_avg.USR$AVGDAYHOW FROM USR$CROSS179_256548741 ft JOIN USR$WG_FEETYPE ft_avg ON ft_avg.ID = ft.USR$WG_FEETYPEKEY WHERE ft.USR$WG_FEEGROUPKEY IN (SELECT id FROM gd_ruid WHERE xid = 147071456 AND dbid = 274788016 ) "]).
param_list(wg_avg_wage_vacation,query,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_FeeTypeNoCoef/4,pSQL-"SELECT 154226364 AS EmplKey,  154226368 AS FirstMoveKey, ft.USR$WG_FEEGROUPKEY, ft.USR$WG_FEETYPEKEY FROM USR$CROSS179_256548741 ft JOIN USR$WG_FEETYPE ft_avg ON ft_avg.ID = ft.USR$WG_FEETYPEKEY WHERE ft.USR$WG_FEEGROUPKEY IN (SELECT id FROM gd_ruid WHERE xid = 0 AND dbid = 0 ) "]).
param_list(wg_avg_wage_vacation,query,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_BadHourType/3,pSQL-"SELECT 154226364 AS EmplKey, 154226368 AS FirstMoveKey, id FROM USR$WG_HOURTYPE WHERE id IN (SELECT id FROM gd_ruid WHERE xid IN (147650804, 147650786, 147650802) AND dbid = 119619099 ) "]).
param_list(wg_avg_wage_vacation,query,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_BadFeeType/3,pSQL-"SELECT 154226364 AS EmplKey, 154226368 AS FirstMoveKey, id FROM USR$WG_FEETYPE WHERE id IN (SELECT id FROM gd_ruid WHERE xid IN (151000730) AND dbid = 2109681374 ) "]).
param_list(wg_avg_wage_vacation,data,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_MovementLine/9,pSQL-"SELECT ml.USR$EMPLKEY, ml.DOCUMENTKEY, ml.USR$FIRSTMOVE AS FirstMoveKey, ml.USR$DATEBEGIN, ml.USR$SCHEDULEKEY, ml.USR$MOVEMENTTYPE, ml.USR$RATE, ml.USR$LISTNUMBER, ml.USR$MSALARY FROM USR$WG_MOVEMENTLINE ml WHERE ml.USR$EMPLKEY = 154226364 AND ml.USR$FIRSTMOVE = 154226368 ORDER BY ml.USR$EMPLKEY, ml.USR$FIRSTMOVE, ml.USR$DATEBEGIN "]).
param_list(wg_avg_wage_vacation,data,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_FCRate/4,pSQL-"SELECT 154226364 AS EmplKey, 154226368 AS FirstMoveKey, fc.USR$WG_DATE, fc.USR$WG_FCRATESUM FROM USR$WG_FCRATE fc ORDER BY fc.USR$WG_DATE "]).
param_list(wg_avg_wage_vacation,data,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_TblDayNorm/8,pSQL-"SELECT EmplKey, FirstMoveKey, TheDay, WYear, WMonth, WDay, WDuration, WorkDay FROM USR$WG_TBLCALDAY_P(154226364, 154226368, '2012-11-01', '2013-11-01') "]).
param_list(wg_avg_wage_vacation,data,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_TblYearNorm/5,pSQL-"SELECT EmplKey, FirstMoveKey, WYear, SUM(WDuration) AS WHoures, SUM(WorkDay) AS WDays FROM USR$WG_TBLCALDAY_P(154226364, 154226368, '2013-01-01', '2014-01-01') GROUP BY EmplKey, FirstMoveKey, WYear "]).
param_list(wg_avg_wage_vacation,data,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_TblCharge/9,pSQL-"SELECT tch.USR$EMPLKEY, tch.USR$FIRSTMOVEKEY, EXTRACT(YEAR FROM tch.USR$DATEBEGIN) AS CalYear, EXTRACT(MONTH FROM tch.USR$DATEBEGIN) AS CalMonth, tch.USR$DATEBEGIN, tch.USR$DEBIT, tch.USR$FEETYPEKEY, tch.USR$DOW, tch.USR$HOW FROM USR$WG_TBLCHARGE tch WHERE tch.USR$EMPLKEY = 154226364 AND tch.USR$DEBIT > 0 AND tch.USR$DATEBEGIN >= '2012-11-01' AND tch.USR$DATEBEGIN < '2013-11-01' ORDER BY tch.USR$EMPLKEY, tch.USR$DATEBEGIN "]).
param_list(wg_avg_wage_vacation,data,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_FeeType/5,pSQL-"SELECT 154226364 AS EmplKey,  154226368 AS FirstMoveKey, ft.USR$WG_FEEGROUPKEY, ft.USR$WG_FEETYPEKEY, ft_avg.USR$AVGDAYHOW FROM USR$CROSS179_256548741 ft JOIN USR$WG_FEETYPE ft_avg ON ft_avg.ID = ft.USR$WG_FEETYPEKEY WHERE ft.USR$WG_FEEGROUPKEY IN (SELECT id FROM gd_ruid WHERE xid = 147071456 AND dbid = 274788016 ) "]).
param_list(wg_avg_wage_vacation,data,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_FeeTypeNoCoef/4,pSQL-"SELECT 154226364 AS EmplKey,  154226368 AS FirstMoveKey, ft.USR$WG_FEEGROUPKEY, ft.USR$WG_FEETYPEKEY FROM USR$CROSS179_256548741 ft JOIN USR$WG_FEETYPE ft_avg ON ft_avg.ID = ft.USR$WG_FEETYPEKEY WHERE ft.USR$WG_FEEGROUPKEY IN (SELECT id FROM gd_ruid WHERE xid = 0 AND dbid = 0 ) "]).
param_list(wg_avg_wage_vacation,data,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_BadHourType/3,pSQL-"SELECT 154226364 AS EmplKey, 154226368 AS FirstMoveKey, id FROM USR$WG_HOURTYPE WHERE id IN (SELECT id FROM gd_ruid WHERE xid IN (147650804, 147650786, 147650802) AND dbid = 119619099 ) "]).
param_list(wg_avg_wage_vacation,data,[pEmplKey-154226364,pFirstMoveKey-154226368,pConnection-gsdb,pQuery-usr_wg_BadFeeType/3,pSQL-"SELECT 154226364 AS EmplKey, 154226368 AS FirstMoveKey, id FROM USR$WG_FEETYPE WHERE id IN (SELECT id FROM gd_ruid WHERE xid IN (151000730) AND dbid = 2109681374 ) "]).
