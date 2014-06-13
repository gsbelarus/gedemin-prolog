%% twg_avg_wage_in_params
%  входные параметры для twg_avg_wage
%

%:- ['../common/lib', '../common/params'].

twg_avg_wage_in_params:-
    member(Scope, [
        wg_avg_wage_vacation,
        wg_avg_wage_sick,
        wg_avg_wage_avg,
        wg_struct_sick
        ]),
    new_param_list(Scope, in, [
        pCommon-1,
        pPayFormSalary_ruid-'147009181,119619099',
        pTblCal_DocType_Plan_ruid-'147567935,1514418708',
        pTblCal_DocType_Fact_ruid-'187613422,1596169984'
        ]),
    fail.
twg_avg_wage_in_params:-
    new_param_list(wg_avg_wage_vacation, in, [
        pMonthQty-12, pAvgDays-29.7,
        pFeeGroupKey_ruid-'147071456,274788016',
        pFeeGroupKeyNoCoef_ruid-'147757383,84733194',
        % А, УБЗ, Т
        pBadHourType_xid_IN-'147650804, 147650786, 147650802',
        pBadHourType_dbid-119619099,
        % Больничный (80%)
        pBadFeeType_xid_IN-'151000730',
        pBadFeeType_dbid-2109681374,
        % Ненормированный график
        pSpecDep_ruid-'156913837,131572570'
        ]),
    fail.
twg_avg_wage_in_params:-
    new_param_list(wg_avg_wage_sick, in, [
        pMonthQty-6,
        pFeeGroupKey_ruid-'147071457,274788016',
        pFeeGroupKeyProp_ruid-'147119175,1354510846',
        pKindDayHourType_ruid-'147650798,119619099'
        ]),
    fail.
twg_avg_wage_in_params:-
    new_param_list(wg_avg_wage_avg, in, [
        pMonthQty-2, pMonthBonusQty-12, pMonthLimitQty-2,
        pFeeGroupKey_ruid-'147113780,1354510846'
        ]),
    fail.
twg_avg_wage_in_params:-
    new_param_list(wg_struct_vacation, in, [
        ]),
    fail.
twg_avg_wage_in_params:-
    new_param_list(wg_struct_sick, in, [
        pBudgetPart-0.5,
        pFirstCalcType-0, pFirstDuration-12, pFirstPart-0.8,
        pJobIllType_ruid-'147036273,151520244',
        pBudget_ruid-'147073065,1224850260',
        pAvgSalaryRB_ruid-'147445419,274788016',
        pAvgSalaryRB_Coef-3
        ]),
    fail.
twg_avg_wage_in_params :-
    member([CutCalcType, CutDuration, CutPart], [[2, 6, 0.5], [3, 0, 0.5]]),
    new_param_list(wg_struct_sick, in,
        [pCutCalcType-CutCalcType, pCutDuration-CutDuration, pCutPart-CutPart]),
    fail.
twg_avg_wage_in_params.

:- twg_avg_wage_in_params.

 %
%%
