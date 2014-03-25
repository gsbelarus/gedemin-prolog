% twg_struct_sql

:-
    GetSQL = [gd_pl_ds/5, get_sql/5],
    %dynamic(GetSQL),
    multifile(GetSQL),
    discontiguous(GetSQL).

%
wg_valid_sql(
            [
            wg_holiday/1,
            wg_vacation_slice/2,
            gd_const_budget/2,
            usr_wg_TblDayNorm/8
            ]).

%
is_valid_sql(Functor/Arity) :-
    wg_valid_sql(ValidSQL),
    member(Functor/Arity, ValidSQL),
    !.

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

%
