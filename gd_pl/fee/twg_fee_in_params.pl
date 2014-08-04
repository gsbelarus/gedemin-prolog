%% twg_fee_in_params
%  входные параметры для twg_fee
%

%:- ['../common/lib', '../common/params'].

twg_fee_in_params:-
    Type = in, Section = pCommon,
    member(Scope, [
        wg_fee_alimony
        ]),
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % записать общие входные параметры
    new_param_list(Scope, Type, [
        Section-1,
        pStartDate-'2012-01-01',
        pKindOfWork_Basic_ruid-'147017405,119619099',
        pPayFormSalary_ruid-'147009181,119619099',
        pFeeGroupKey_IncomeTax_ruid-'147021000,274788016',  % Облагается ПН
        pDocType_Total_ruid-'147567052,119619099',
        pTblCal_DocType_Plan_ruid-'147567935,1514418708',
        pTblCal_DocType_Fact_ruid-'187613422,1596169984'
        ]),
    fail.
twg_fee_in_params:-
    Type = in, Section = pAlimony,
    member(Scope, [
        wg_fee_alimony
        ]),
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % записать входные параметры
    new_param_list(Scope, Type, [
        Section-1,
        pFeeGroupKey_ruid-'147732349,375143752',           % Для алиментов
        pDocType_Alimony_ruid-'147067079,453357870',       % 04. Алименты
        pVar_BV_ruid-'147021364,256548741',           % БВ
        pVar_ForAlimony_ruid-'147068435,453357870',   % ДЛЯАЛИМЕНТОВ
        pBudget_ruid-'147073065,1224850260', % БПМ
        pFeeType_Alimony_ruid-'147567138,119619099',     % Алименты
        pFeeType_HolidayComp_ruid-'147076028,274788016', % Компенсация отпуска
        pFeeType_IncomeTax_ruid-'147567139,119619099',   % Подоходный
        pFeeType_TransferDed_ruid-'147069035,453357870', % Расходы по переводу
        pFeeType_AlimonyDebt_ruid-'147067786,453357870'  % Долг по алиментам
        ]),
    fail.
twg_fee_in_params:-
    Type = fit, Section = 1,
    member(Scope, [
        wg_fee_alimony
        ]),
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % записать входные параметры
    new_param_list(Scope, Type, [
        pRestPercent-0.3, % Процент остатка
        pPercent-1.0,     % Процент списания долга
        pCalcDelta-100    % Дельта для расчета при нехватке средств
        ]),
    fail.
twg_fee_in_params:-
    Type = fit, Section = 2,
    member(Scope, [
        wg_fee_alimony
        ]),
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % Процент от БПМ (не менее) от количества детей
    member([ChildQtyCmp, LivingWagePerc],
        [ ['=:=0', 0.0], ['=1', 0.5], ['=2', 0.75], ['>=3', 1.0] ]),
    % записать входные параметры
    new_param_list(Scope, Type,
        [pChildQtyCmp-ChildQtyCmp, pLivingWagePerc-LivingWagePerc]),
    fail.
twg_fee_in_params.

:- twg_fee_in_params.

 %
%%
