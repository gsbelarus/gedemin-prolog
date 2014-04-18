% twg_avg_wage_in_params

%:- [lib, params].

twg_avg_wage_in_params:-
    member(Scope,
    [
    wg_avg_wage_vacation,
    wg_avg_wage_sick,
    wg_struct_sick
    ]),
    new_param_list(Scope, in,
    [
    pCommon-1,
    pPayFormSalary_xid-147009181,
    pPayFormSalary_dbid-119619099,
    pTblCal_DocType_Plan_xid-147567935,
    pTblCal_DocType_Plan_dbid-1514418708,
    pTblCal_DocType_Fact_xid-187613422,
    pTblCal_DocType_Fact_dbid-1596169984
    ]),
    fail.
twg_avg_wage_in_params:-
    new_param_list(wg_avg_wage_vacation, in,
    [
    pMonthQty-12, pAvgDays-29.7,
    pFeeGroupKey_xid-147071456,
    pFeeGroupKey_dbid-274788016,
    pFeeGroupKeyNoCoef_xid-147757383,
    pFeeGroupKeyNoCoef_dbid-84733194,
    pBadHourType_xid_IN-'147650804, 147650786, 147650802',
    pBadHourType_dbid-119619099,
    pBadFeeType_xid_IN-'151000730',
    pBadFeeType_dbid-2109681374,
    pSpecDep_xid-156913837,
    pSpecDep_dbid-131572570
    ]),
    fail.
twg_avg_wage_in_params:-
    new_param_list(wg_avg_wage_sick, in,
    [
    pMonthQty-6,
    pFeeGroupKey_xid-147071457,
    pFeeGroupKey_dbid-274788016,
    pFeeGroupKeyProp_xid-147119175,
    pFeeGroupKeyProp_dbid-1354510846,
    pAvgSalaryRB_xid-147445419,
    pAvgSalaryRB_dbid-274788016,
    pAvgSalaryRB_Coef-3
    ]),
    fail.
twg_avg_wage_in_params:-
    new_param_list(wg_struct_vacation, in,
    [
    ]),
    fail.
twg_avg_wage_in_params:-
    new_param_list(wg_struct_sick, in,
    [
    pBudgetPart-0.5,
    pFirstCalcType-0, pFirstDuration-12, pFirstPart-0.8,
    pJobIllType_ruid-'154855944,2105943061',
    pBudget_xid-147073065,
    pBudget_dbid-1224850260
    ]),
    fail.
twg_avg_wage_in_params.

:- twg_avg_wage_in_params.

%
