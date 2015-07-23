%% twg_pu_in_params
%  входные параметры для twg_pu
%

%:- ['../gd_pl_state/date', '../common/lib', '../common/params'].

twg_pu_in_params:-
    Type = in, Section = pCommon,
    member(Scope, [
        wg_pu_3
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % записать общие входные параметры
    new_param_list(Scope, Type, [
        Section,
        pStartDate-'2012-01-01', pNullDate-'2100-01-01',
        pAvgSalaryRB_ruid-'147105585,1224850260',
        pAvgSalaryRB_Coef-4,
        pKindOfWork_Basic_ruid-'147017405,119619099',       % Основное место работы
        pKindOfWork_ByWork_ruid-'147017406,119619099',      % Внутр. совмещение
        pKindOfWork_ByWorkOuter_ruid-'147041907,453357870', % Внешн. совмещение
        pFeeGroupKey_ruid-'147021001,274788016',          % Начисляются СВ
        pFeeParentSick_ruid-'147025974,403876601',        % Пособия
        pFeeType_JobIll_ruid-'575315331,99701464',        % Травма на производстве
        pFeeType_SocInsurance_ruid-'147653395,119619099', % Пенсионный
        pTblCal_DocType_Fact_ruid-'187613422,1596169984',     % Табель мастера
        pHourType_Sick_ruid-'147650801,119619099',      % Больничные (Б)
        pHourType_CareOf_ruid-'147650788,119619099',    % Отпуск по уходу за ребенком (ОЖ)
        pHourType_Pregnancy_ruid-'147650787,119619099', % Отпуска по беременности и родам (Р)
        pHourType_MotherDay_ruid-'147650798,119619099'  % День матери (ДМ)
        ]),
    fail.
twg_pu_in_params:-
    Type = dict, Section = pEDoc,
    member(Scope, [
        wg_pu_3
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % Тип формы
    member([EDocType, EDocCode, EDocName],
        [ [0, "И", "Исходная"],
          [1, "К", "Корректирующая"],
          [2, "О", "Отменяющая"],
          [3, "П", "Назначение пенсии"]
        ]),
    % записать входные параметры
    new_param_list(Scope, Type, [
        Section,
        pEDocType-EDocType, pEDocCode-EDocCode, pEDocName-EDocName
        ]),
    fail.
twg_pu_in_params:-
    Type = dict, Section = pCategory,
    member(Scope, [
        wg_pu_3
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % Код категории
    member([CatType, CatAlias, CatCode],
        [ [1, catRate, "01"],
          [3, catContract, "03"]
        ]),
    % записать входные параметры
    new_param_list(Scope, Type, [
        Section,
        pCatType-CatType, pCatAlias-CatAlias, pCatCode-CatCode
        ]),
    fail.
twg_pu_in_params:-
    Type = dict, Section = pExperience,
    member(Scope, [
        wg_pu_3
        ]),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % Вид деятельности
    member([ExpType, ExpAlias, ExpCode],
        [ [-1, expNone, "-"],
          [0, expSkip, " "],
          [1, expPayTemp, "ВЗНОСЫВРЕМ"],
          [2, expAllowance, "ПОСОБИЕ"],
          [3, expChildren, "ДЕТИ"],
          [4, expBonus, "ПРЕМИЯ"],
          [5, expContract, "ДОГОВОР"],
          [6, expPension, "ПЕНСИЯ"]
        ]),
    % записать входные параметры
    new_param_list(Scope, Type, [
        Section,
        pExpType-ExpType, pExpAlias-ExpAlias, pExpCode-ExpCode
        ]),
    fail.
twg_pu_in_params.

:- twg_pu_in_params.

 %
%%
