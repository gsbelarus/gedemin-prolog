%% twg_fee_in_params
%  входные параметры для twg_fee
%

%:- ['../gd_pl_state/date', '../common/lib', '../common/params'].

twg_fee_in_params:-
    Type = in, Section = pCommon,
    member(Scope, [
        wg_fee_alimony, wg_fee_fine
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % записать общие входные параметры
    new_param_list(Scope, Type, [
        Section-1,
        pStartDate-'2012-01-01', pNullDate-'2100-01-01',
        pKindOfWork_Basic_ruid-'147017405,119619099',       % Основное место работы
        pPayFormSalary_ruid-'147009181,119619099',          % Форма оплаты Оклад
        pFeeGroupKey_IncomeTax_ruid-'147021000,274788016',  % Облагается ПН
        pDocType_Total_ruid-'147567052,119619099',          % 99. Итоговое начисление
        pTblCal_DocType_Plan_ruid-'147567935,1514418708',   % Календарный график
        pTblCal_DocType_Fact_ruid-'187613422,1596169984',   % Табель мастера
        pBudget_ruid-'147073065,1224850260',                % БПМ
        pMinTransfCharge-10000                 % Минимальная сумма перевода
        ]),
    fail.
twg_fee_in_params:-
    Type = in, Section = pAlimony,
    member(Scope, [
        wg_fee_alimony, wg_fee_fine
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % записать входные параметры
    new_param_list(Scope, Type, [
        Section-1,
        pVar_BV_ruid-'147021364,256548741',           % БВ
        pVar_ForAlimony_ruid-'147068435,453357870',   % ДЛЯАЛИМЕНТОВ
        pVar_ForFine_ruid-'147049304,1011422021',     % ДЛЯШТРАФОВ
        pFeeType_Alimony_ruid-'147567138,119619099',       % Алименты
        pFeeType_Fine_ruid-'147049310,1011422021',         % Штрафы
        pFeeType_HolidayComp_ruid-'147076028,274788016',   % Компенсация отпуска
        pFeeType_IncomeTax_ruid-'147567139,119619099',     % Подоходный
        pFeeType_TransferDed_ruid-'147069035,453357870',   % Расходы по переводу
        pFeeType_AlimonyDebt_ruid-'147067786,453357870',   % Долг по алиментам
        pFeeType_FineDebt_ruid-'147036413,360343892'       % Долг по штрафам
        ]),
    fail.
twg_fee_in_params:-
    Type = in, Section = pAlimony,
    member(Scope, [
        wg_fee_alimony
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % записать входные параметры
    new_param_list(Scope, Type, [
        Section-1,
        pFeeGroupKey_ruid-'147732349,375143752',   % Для алиментов
        pDocType_ruid-'147067079,453357870'        % 04. Алименты
        ]),
    fail.
twg_fee_in_params:-
    Type = in, Section = pAlimony,
    member(Scope, [
        wg_fee_fine
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % записать входные параметры
    new_param_list(Scope, Type, [
        Section-1,
        pFeeGroupKey_ruid-'147049301,1011422021',  % Для штрафов
        pDocType_ruid-'147050774,1011422021'       % 11. Штрафы
        ]),
    fail.
twg_fee_in_params:-
    Type = fit, Section = 1,
    member(Scope, [
        wg_fee_alimony
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % записать входные параметры
    new_param_list(Scope, Type, [
        pRestPercent-0.3,  % Процент остатка
        pPercent-0.2,      % Процент списания долга
        pCalcDelta-100     % Дельта для расчета при нехватке средств
        ]),
    fail.
twg_fee_in_params:-
    Type = fit, Section = 1,
    member(Scope, [
        wg_fee_fine
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % записать входные параметры
    new_param_list(Scope, Type, [
        pRestPercent-0.5,  % Процент остатка
        pPercent-0.2,      % Процент списания долга
        pCalcDelta-100     % Дельта для расчета при нехватке средств
        ]),
    fail.
twg_fee_in_params:-
    Type = fit, Section = 2,
    member(Scope, [
        wg_fee_alimony
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
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
