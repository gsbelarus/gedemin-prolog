%% twg_fee
% Зарплата и Отдел кадров -> Зарплата -> 02. Прочие доходы, расходы, льготы
%    04. Алименты
%    11. Штрафы
%

:- retractall(debug_mode).

% ! при использовании в ТП Гедымин
% ! для begin & end debug mode section
% ! убрать символ процента из первой позиции
%/* %%% begin debug mode section

%% saved state
:- ['../gd_pl_state/load_atom', '../gd_pl_state/date', '../gd_pl_state/dataset'].
%%

%% include
%#INCLUDE lib
%#INCLUDE params
%#INCLUDE wg_data_mix
:- ['../common/lib', '../common/params', '../common/wg_data_mix'].
%#INCLUDE twg_fee_sql
:- [twg_fee_sql].
%#INCLUDE twg_fee_in_params
%:- [twg_fee_in_params].
%%

%% facts
:-  init_data,
    working_directory(_, 'kb'),
    [
    usr_wg_MovementLine,
    usr_wg_TblCharge,
    usr_wg_TblCharge_AlimonyDebt,
    usr_wg_FeeType,
    usr_wg_FeeType_Taxable,
    usr_wg_FeeType_Dict,
    usr_wg_TblCalLine,
    usr_wg_TblCal_FlexLine,
    usr_wg_FCRate,
    gd_const_budget,
    usr_wg_Variables,
    usr_wg_Alimony,
    usr_wg_TransferType,
    usr_wg_TransferScale,
    usr_wg_AlimonyDebt
    ],
    working_directory(_, '..').
%%

%% dynamic state
:- ['kb/param_list'].
%%

%% flag
:- assertz(debug_mode).
%%

% ! при использовании в ТП Гедымин
% ! для begin & end debug mode section
% ! убрать символ процента из первой позиции
%*/ %%% end debug mode section

:- ps32k_lgt(64, 128, 64).

/* реализация - расчет */

% расчет итогового начисления
fee_calc(Scope) :-
    % - для алиментов
    Scope = wg_fee_alimony,
    % для каждого сотрудника
    get_param(Scope, in, pEmplKey-EmplKey),
    % выполнить расчет
    fee_calc(Scope, EmplKey),
    % найти альтернативу
    fail.
fee_calc(_) :-
    % больше альтернатив нет
    !.

% выполнить расчет
fee_calc(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony,
    % удалить временные данные по расчету
    forall( get_param(Scope, temp, pEmplKey-EmplKey, Pairs),
            dispose_param_list(Scope, temp, Pairs) ),
    % расчет табеля
    calc_tab(Scope, EmplKey),
    % расчет суммы
    cacl_amount(Scope, EmplKey),
    % расчет формулы
    calc_formula(Scope, EmplKey),
    % расчет перевода
    cacl_transf(Scope, EmplKey),
    % контроль остатка
    check_rest(Scope, EmplKey),
    % начисление долгов
    add_debt(Scope, EmplKey),
    % списание долгов
    drop_debt(Scope, EmplKey),
    % расчет итога
    calc_total(Scope, EmplKey),
    !.

% расчет табеля
calc_tab(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCalcTab,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % последний прием на работу
    PK = [pEmplKey-EmplKey, pFirstMoveKey-_],
    get_last_hire(Scope, PK, DateIn),
    % начало итогового месяца
    get_param_list(Scope, in, [pEmplKey-EmplKey, pDateBegin-DateBegin]),
    DateBegin @>= DateIn,
    % Общий табель за итоговый месяц
    atom_date(DateBegin, date(Y, M, _)),
    calc_month_tab(Scope, PK, Y-M, TabDays),
    sum_days_houres(TabDays, TDays, THoures),
    % спецификация временных данных
    append([ [Section-1], PK,
             [pYM-Y-M, pTDays-TDays, pTHoures-THoures] ],
                TabPairs),
    % добавить временные данные
    new_param_list(Scope, Type, TabPairs),
    % спецификация алиментов
    SpecAlimony = [
                fDocKey-AlimonyKey, fEmplKey-EmplKey,
                fDateBegin-ADateBegin, fDateEnd-ADateEnd ],
    % спецификация временных данных
    append([ [Section-2], PK,
             [pAlimonyKey-AlimonyKey, pDateBegin-ADateBegin, pDateEnd-ADateEnd],
             [pYM-Y-M, pTDays-ADays, pTHoures-AHoures, pTCoef-TCoef] ],
                AlimonyPairs),
    % для всех алиментов
    forall( get_data(Scope, kb, usr_wg_Alimony, SpecAlimony),
            ( % посчитать Дни и Часы для периода действия алиментов
              sum_days_houres(TabDays, ADays, AHoures, ADateBegin, ADateEnd),
              % вычислить Коеффициент от Общего табеля
              TCoef is AHoures / THoures,
              % добавить временные данные
              new_param_list(Scope, Type, AlimonyPairs)
            )
          ),
    !.

% расчет суммы
cacl_amount(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCalcAmount,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % собрать начисления по Группе начислений
    fee_group_charges(Scope, EmplKey, Charges),
    % Общая сумма
    charges_sum(Charges, AmountAll),
    % Исключаемые начисления
    charges_excl(Scope, EmplKey, Charges, ChargesExcl),
    % Исключаемая сумма
    charges_sum(ChargesExcl, [debit(1), credit(0)], AmountExcl),
    % Подоходный налог (ПН)
    get_data(Scope, kb, usr_wg_FeeType_Dict, [
                fID-IncomeTaxFeeType, fAlias-"ftIncomeTax" ]),
    charges_sum(Charges, [debit(0), credit(1)], [IncomeTaxFeeType], IncomeTax),
    % собрать виды начислений, облагаемые ПН
    findall( TaxableFeeType,
             get_data(Scope, kb, usr_wg_FeeType_Taxable, [
                         fEmplKey-EmplKey, fFeeTypeKey-TaxableFeeType ]),
    TaxableFeeTypeList),
    % Облагаемая ПН сумма
    charges_sum(Charges, [debit(1), credit(0)], TaxableFeeTypeList, AmountTaxable),
    % Коеффициент ПН
    IncomeTaxCoef is IncomeTax / AmountTaxable,
    % Облагаемая ПН Исключаемая сумма
    charges_sum(ChargesExcl, [debit(1), credit(0)], TaxableFeeTypeList, AmountTaxableExcl),
    % Исключаемый ПН
    IncomeTaxExcl is AmountTaxableExcl * IncomeTaxCoef,
    % Расчетная сумма = Общая сумма - Исключаемая сумма - Исключаемый ПН
    ForAlimony0 is AmountAll - AmountExcl - IncomeTaxExcl,
    to_currency(ForAlimony0, ForAlimony, 0),
    % спецификация временных данных
    AmountPairs = [
                Section-1, pEmplKey-EmplKey, pForAlimony-ForAlimony,
                pAmountAll-AmountAll, pAmountExcl-AmountExcl, pIncomeTaxExcl-IncomeTaxExcl,
                pAmountTaxableExcl-AmountTaxableExcl, pIncomeTaxCoef-IncomeTaxCoef,
                pIncomeTax-IncomeTax, pAmountTaxable-AmountTaxable ],
    % добавить временные данные
    new_param_list(Scope, Type, AmountPairs),
    !.

% расчет формулы
calc_formula(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCalcFormula,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % спецификация алиментов
    SpecAlimony = [
                fDocKey-AlimonyKey, fEmplKey-EmplKey, fFormula-Formula,
                fChildCount-_, fLivingWagePerc-_ ],
    % спецификации временных данных
    FormulaPairs = [
                Section-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCharge-_, pAlimonySum-_,  pByBudget-_,
                pFormula-Formula, pForAlimony-_, pBV-_,
                pEval-_, pTCoef-_, pResult-_,
                pChildCount-_, pLivingWagePerc-_,
                pBudgetConst-_, pBudgetPart-_ ],
    % для всех алиментов
    forall( get_data(Scope, kb, usr_wg_Alimony, SpecAlimony),
            ( % получить сумму по формуле
              calc_formula(Scope, EmplKey, SpecAlimony, FormulaPairs),
              % добавить временные данные
              new_param_list(Scope, Type, FormulaPairs)
            )
          ),
    !.

% расчет формулы по спецификациям
calc_formula(Scope, EmplKey, SpecAlimony, FormulaPairs) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCalcFormula,
    get_param_list(Scope, run, [
                    pEmplKey-EmplKey, pDateCalcTo-DateCalcTo ]),
    % спецификация алиментов
    SpecAlimony = [
                fDocKey-AlimonyKey, fEmplKey-EmplKey, fFormula-Formula,
                fChildCount-ChildCount0, fLivingWagePerc-LivingWagePerc0 ],
    % сопоставить с данными по умолчанию
    LivingWagePerc1 is LivingWagePerc0 / 100,
    fit_data(Scope,
                [pChildCount-ChildCount0, pLivingWagePerc-LivingWagePerc1],
                [pChildCount-ChildCount, pLivingWagePerc-LivingWagePerc]),
    % спецификация временных данных
    FormulaPairs = [
                Section-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCharge-AlimonySum, pAlimonySum-AlimonySum, pByBudget-ByBudget,
                pFormula-Formula, pForAlimony-ForAlimony, pBV-BV,
                pEval-Eval, pTCoef-TCoef, pResult-Result,
                pChildCount-ChildCount, pLivingWagePerc-LivingWagePerc,
                pBudgetConst-BudgetConst, pBudgetPart-BudgetPart ],
    % сумма БВ
    get_data(Scope, kb, usr_wg_Variables, [fAlias-"vBV", fName-Var_BV]),
    get_min_wage(Scope, DateCalcTo, BV),
    replace_all(Formula, Var_BV, BV, Formula1),
    % сумма Для алиментов
    get_data(Scope, kb, usr_wg_Variables, [fAlias-"vForAlimony", fName-Var_ForAlimony]),
    get_param_list(Scope, Type, [
                    pCalcAmount-1,
                    pEmplKey-EmplKey, pForAlimony-ForAlimony ]),
    replace_all(Formula1, Var_ForAlimony, ForAlimony, Formula2),
    % Результат
    replace_all(Formula2, ",", ".", Formula3),
    catch( term_to_atom(Expr, Formula3), _, fail ),
    catch( Eval is Expr, _, fail),
    get_param_list(Scope, Type, [
                    pCalcTab-2,
                    pAlimonyKey-AlimonyKey, pTCoef-TCoef ]),
    Result is Eval * TCoef,
    % Часть БПМ
    get_budget(Scope, DateCalcTo, BudgetConst),
    BudgetPart is BudgetConst * LivingWagePerc,
    % сумма Удержания
    ( Result < BudgetPart ->
      AlimonySum0 = BudgetPart, ByBudget = 1
    ; AlimonySum0 = Result, ByBudget = 0
    ),
    get_round_data(Scope, EmplKey, "ftAlimony", RoundType, RoundValue),
    round_sum(AlimonySum0, AlimonySum, RoundType, RoundValue),
    AlimonySum > 0,
    !.

% расчет перевода
cacl_transf(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCalcTransf,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % спецификация алиментов
    SpecAlimony = [
                fEmplKey-EmplKey, fDocKey-AlimonyKey,
                fTransferTypeKey-TransferTypeKey0, fRecipient-Recipient0 ],
    % спецификация параметров алиментов
    AlimonyParams = [
                pCalcFormula-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCharge-AlimonyCharge ],
    % спецификация параметров списания долгов алиментов
    DebtParams4 = [
                pDropDebt-4, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pDebtCharge-DebtCharge ],
    % спецификация временных данных
    TransfPairs = [
                Section-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey1,
                pTransfSum-TransfSum, pTransfByGroup-TransfByGroup,
                pTransferTypeKey-TransferTypeKey, pRecipient-Recipient,
                pForTransfAmount-ForTransfAmount, pTransfPercent-TransfPercent ],
    % спецификации данных для перевода
    TransfData1 = [AlimonyKey, TransferTypeKey0, Recipient0, AlimonyCharge],
    TransfData2 = [AlimonyKey, TransferTypeKey0, Recipient0, DebtCharge],
    TransfAggrData = [
                AlimonyKey1, TransfByGroup, TransferTypeKey, Recipient,
                ForTransfAmount, TransfPercent, TransfSum ],
    % собрать данные для перевода
    findall( TransfData1,
             ( get_data(Scope, kb, usr_wg_Alimony, SpecAlimony),
               TransferTypeKey0 > 0,
               get_param_list(Scope, Type, AlimonyParams)
             ),
    TransfDataList1 ),
    findall( TransfData2,
             ( get_data(Scope, kb, usr_wg_Alimony, SpecAlimony),
               TransferTypeKey0 > 0,
               get_param_list(Scope, Type, DebtParams4)
             ),
    TransfDataList2 ),
    append(TransfDataList1, TransfDataList2, TransfDataList),
    % агрегировать суммы за перевод
    aggr_fransf(Scope, EmplKey, TransfDataList, TransfAggrDataList),
    % для всех переводов
    forall( member(TransfAggrData, TransfAggrDataList),
            % добавить временные данные
            new_param_list(Scope, Type, TransfPairs)
          ),
    !.

% пересчитать суммы переводов
recacl_transf(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCalcTransf,
    % удалить временные данные по переводам
    forall( get_param_list(Scope, Type, [Section-_, pEmplKey-EmplKey], Pairs),
            dispose_param_list(Scope, Type, Pairs) ),
    % расчет перевода
    cacl_transf(Scope, EmplKey),
    !.

% агрегировать суммы за перевод
aggr_fransf(_, _, [], []) :-
    !.
aggr_fransf(Scope, EmplKey, [TransfData|TransfDataList], [TransfAggrData|TransfAggrDataList]) :-
    %
    aggr_fransf(Scope, EmplKey, TransfData, [TransfData|TransfDataList], TransfDataList1, TransfAggrData),
    !,
    aggr_fransf(Scope, EmplKey, TransfDataList1, TransfAggrDataList).
%
aggr_fransf(Scope, EmplKey, TransfData, TransfDataList, TransfDataList1, TransfAggrData) :-
    % спецификации данных за перевод
    TransfData = [AlimonyKey, TransferTypeKey, Recipient, AlimonyCharge0],
    TransfAggrData = [
                AlimonyKey, TransfByGroup, TransferTypeKey, Recipient,
                ForTransfAmount, TransfPercent, TransfSum ],
    % для получателей
    ( Recipient > 0,
      % собрать суммы по Группе [Вид перевода, Получатель]
      findall( AlimonyCharge,
               member([_, TransferTypeKey, Recipient, AlimonyCharge], TransfDataList),
      AlimonyChargeList)
    ; % иначе Исходная сумма
      AlimonyChargeList = [AlimonyCharge0]
    ),
    % Итог
    sum_list(AlimonyChargeList, ForTransfAmount),
    % Признак группы
    ( length(AlimonyChargeList, 1),
      TransfByGroup = 0
    ;
      TransfByGroup = 1
    ),
    % Процент от Итога
    get_transf_percent(Scope, EmplKey, TransferTypeKey, ForTransfAmount, TransfPercent),
    % Сумма за перевод
    TransfSum0 is ForTransfAmount * TransfPercent / 100,
    get_round_data(Scope, EmplKey, "ftTransferDed", RoundType, RoundValue),
    round_sum(TransfSum0, TransfSum, RoundType, RoundValue),
    % для получателей
    ( Recipient > 0, \+ length(AlimonyChargeList, 1),
      % исключить Группу из списка данных
      findall( [AlimonyKey1, TransferTypeKey1, Recipient1, AlimonySum1],
               ( member([AlimonyKey1, TransferTypeKey1, Recipient1, AlimonySum1], TransfDataList),
                 \+ [TransferTypeKey, Recipient] = [TransferTypeKey1, Recipient1]
               ),
      TransfDataList1)
    ; % иначе исключить Текущие данные
      selectchk(TransfData, TransfDataList, TransfDataList1)
    ),
    !.

% контроль остатка
check_rest(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCheckRest,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % спецификация алиментов
    SpecAlimony = [
                fDocKey-AlimonyKey, fEmplKey-EmplKey, fRestPercent-RestPercent0 ],
    % спецификация параметров алиментов
    AlimonyParams = [
                pCalcFormula-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonySum-AlimonySum ],
    % спецификация параметров контроля
    CheckParams = [
                pCalcAmount-1, pEmplKey-EmplKey, pAmountAll-AmountAll ],
    % спецификация временных данных
    CheckPairs = [
                Section-1, pEmplKey-EmplKey,
                pAlimonyAmount-AlimonyAmount, pCheckAmount-CheckAmount,
                pAmountAll-AmountAll, pRestPercent-RestPercent, pRestAmount-RestAmount
                 ],
    AlimonyPairs = [
                Section-2, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCoef-AlimonyCoef,
                pAlimonySum-AlimonySum, pAlimonyAmount-AlimonyAmount ],
    % Итог по алиментам
    findall( AlimonySum,
             get_param_list(Scope, Type, AlimonyParams),
    AlimonySumList),
    sum_list(AlimonySumList, AlimonyAmount),
    % Процент остатка
    findall( RestPercent0,
             get_data(Scope, kb, usr_wg_Alimony, SpecAlimony),
    RestPercentList),
    min_list(RestPercentList, RestPercent0),
    RestPercent1 is RestPercent0 / 100,
    fit_data(Scope, [pRestPercent-RestPercent1], [pRestPercent-RestPercent]),
    % сумма Контроля
    get_param_list(Scope, Type, CheckParams),
    RestAmount is AmountAll * RestPercent,
    CheckAmount is AmountAll - RestAmount,
    % добавить временные данные
    new_param_list(Scope, Type, CheckPairs),
    % для всех алиментов
    forall( get_param_list(Scope, Type, AlimonyParams),
            ( % вычислить коеффициент от Итога
              AlimonyCoef is AlimonySum / AlimonyAmount,
              % добавить временные данные
              new_param_list(Scope, Type, AlimonyPairs)
            )
          ),
    % Дельта для расчета при нехватке средств
    get_param(Scope, fit, pCalcDelta-CalcDelta), CalcDelta > 0,
    % контроль остатка по сумме Контроля
    check_rest(Scope, EmplKey, CheckAmount, 0, CalcDelta, 0),
    !.

% контроль остатка по сумме Контроля
check_rest(Scope, EmplKey, CheckAmount, CalcDelta0, CalcDelta, CalcSwitch) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCheckRest,
    % спецификация параметров алиментов
    AlimonyParams = [
                pCalcFormula-1, pEmplKey-EmplKey, pAlimonyCharge-AlimonyCharge ],
    % спецификация параметров переводов
    TransfParams = [
                pCalcTransf-1, pEmplKey-EmplKey, pTransfSum-TransfSum ],
    % спецификация временных данных
    CheckPairs = [
                Section-3, pEmplKey-EmplKey,
                pBalance-Balance, pChargeAmount-ChargeAmount,
                pAlimonyChargeAmount-AlimonyChargeAmount, pTransfAmount-TransfAmount,
                pReserveAmount-ReserveAmount, pCheckAmount-CheckAmount,
                pCalcDelta-CalcDelta0, pChargeStep-ChargeStep ],
    % сумма к Удержанию
    findall( AlimonyCharge,
             get_param_list(Scope, Type, AlimonyParams),
    AlimonyChargeList),
    sum_list(AlimonyChargeList, AlimonyChargeAmount),
    findall( TransfSum,
             get_param_list(Scope, Type, TransfParams),
    TransfSumList),
    sum_list(TransfSumList, TransfAmount),
    ChargeAmount is AlimonyChargeAmount + TransfAmount,
    % сумма Контроля не меньше суммы к Удержанию
    \+ CheckAmount < ChargeAmount,
    % сумма Баланса
    Balance is CheckAmount - ChargeAmount,
    % сумма Резерва
    ReserveAmount is CheckAmount - CalcDelta0 * CalcSwitch,
    % количество Итераций
    ChargeStep is CalcDelta0 / CalcDelta,
    % добавить временные данные
    new_param_list(Scope, Type, CheckPairs),
    !.
check_rest(Scope, EmplKey, CheckAmount, CalcDelta0, CalcDelta, CalcSwitch) :-
    % - для алиментов
    Scope = wg_fee_alimony,
    % увеличить Дельту
    CalcDelta1 is CalcDelta0 + CalcDelta * CalcSwitch,
    % сумма Резерва
    ReserveAmount0 is CheckAmount - CalcDelta1,
    ( ReserveAmount0 > 0, ReserveAmount = ReserveAmount0
    ; ReserveAmount = 0
    ),
    % распределить суммы по Коэфициентам от суммы Резерва
    charge_by_coef(Scope, EmplKey, ReserveAmount),
    % пересчитать суммы переводов
    recacl_transf(Scope, EmplKey),
    !,
    check_rest(Scope, EmplKey, CheckAmount, CalcDelta1, CalcDelta, 1).

% распределить суммы по Коэфициентам от суммы Резерва
charge_by_coef(Scope, EmplKey, ReserveAmount) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp,
    Section1 = pCalcFormula, Section2 = pCheckRest,
    % спецификации параметров алиментов
    AlimonyParams1 = [
                Section1-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCharge-_ ],
    AlimonyParams2 = [
                Section2-2, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCoef-AlimonyCoef ],
    % параметры Округления
    get_round_data(Scope, EmplKey, "ftAlimony", RoundType, RoundValue),
    % для всех алиментов
    forall( get_param_list(Scope, Type, AlimonyParams1, Pairs),
            ( % вычислить Пропорцию
              get_param_list(Scope, Type, AlimonyParams2),
              AlimonyCharge0 is ReserveAmount * AlimonyCoef,
              round_sum(AlimonyCharge0, AlimonyCharge, RoundType, RoundValue),
              % заменить сумму Удержания
              replace_list(Pairs,
                              [pAlimonyCharge-_],
                              [pAlimonyCharge-AlimonyCharge],
                                  Pairs1),
              dispose_param_list(Scope, Type, Pairs),
              new_param_list(Scope, Type, Pairs1)
            )
          ),
    !.

% начисление долгов
add_debt(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pAddDebt,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % спецификации параметров алиментов
    AlimonyParams = [
                pCalcFormula-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCharge-AlimonyCharge, pAlimonySum-AlimonySum ],
    % спецификация временных данных
    DebtPairs = [
                Section-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyDebt-AlimonyDebt,
                pAlimonyCharge-AlimonyCharge, pAlimonySum-AlimonySum ],
    % параметры Округления
    get_round_data(Scope, EmplKey, "ftAlimonyDebt", RoundType, RoundValue),
    % для всех алиментов
    forall( get_param_list(Scope, Type, AlimonyParams),
            ( AlimonyDebt0 is AlimonySum - AlimonyCharge,
              % при наличии долга по алиментам
              once( ( AlimonyDebt0 > 0,
                      round_sum(AlimonyDebt0, AlimonyDebt, RoundType, RoundValue),
                      % добавить временные данные
                      new_param_list(Scope, Type, DebtPairs)
                    ; % иначе продолжить
                      true
                    ) )
             )
          ),
    !.

% списание долгов
drop_debt(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pDropDebt,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % нет новых долгов
    \+ get_param_list(Scope, Type, [pAddDebt-1, pEmplKey-EmplKey]),
    % последний прием на работу
    PK = [pEmplKey-EmplKey, pFirstMoveKey-_],
    get_last_hire(Scope, PK, DateIn),
    % есть данные по долгам
    once( ( get_data(Scope, kb, usr_wg_AlimonyDebt, [
                        fEmplKey-EmplKey, fDateBegin-DebtDate ]),
            DebtDate @>= DateIn
          ) ),
    % спецификация параметров Контроля
    CheckParams = [
                pCheckRest-3, pEmplKey-EmplKey, pBalance-Balance ],
    % контроль Баланса
    get_param_list(Scope, Type, CheckParams),
    get_param(Scope, fit, pDropDebtLimit-DropDebtLimit),
    Balance > DropDebtLimit,
    % расчет Остатков по долгам
    drop_debt_rest(Scope, EmplKey, DateIn, Balance),
    % списание Долгов
    drop_debt_bal(Scope, EmplKey),
    !.
drop_debt(Scope, _) :-
    % - для алиментов
    Scope = wg_fee_alimony,
    !.

% расчет Остатков по долгам
drop_debt_rest(Scope, EmplKey, DateIn, Balance) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pDropDebt,
    % спецификация алиментов
    SpecAlimony = [
                fDocKey-AlimonyKey, fEmplKey-EmplKey,
                fPercent-Percent ],
    % спецификация долгов по алиментам
    SpecAlimonyDebt = [
                fDocKey-AlimonyDebtKey, fEmplKey-EmplKey,
                fCalYear-Y, fCalMonth-M, fDateBegin-DateBegin,
                fAlimonyKey-AlimonyKey, fDebtSum-DebtSum ],
    % спецификация списания долгов по алиментам
    SpecAlimonyPaid = [
                fDocKey-AlimonyDebtKey, fEmplKey-EmplKey,
                fDebit-Debit, fCredit-Credit ],
    % спецификации временных данных
    DebtPairs1 = [
                Section-1, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pAlimonyDebtKey-AlimonyDebtKey,
                pRestSum-RestSum, pDebtSum-DebtSum, pPaidSum-PaidSum,
                pYM-Y-M, pDateBegin-DateBegin ],
    DebtPairs2 = [
                Section-2, pEmplKey-EmplKey,
                pRestBalance-RestBalance, pRestAmountAll-RestAmountAll ],
    DebtPairs3 = [
                Section-3, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pRestAmount-RestAmount,
                pDebtPercent-DebtPercent, pRestCoef-RestCoef ],
    % для всех долгов по алиментам
    forall( ( get_data(Scope, kb, usr_wg_AlimonyDebt, SpecAlimonyDebt),
              DateBegin @>= DateIn
            ),
            ( % суммировать Cписание долгов
              findall( PaidSum0,
                       ( get_data(Scope, kb, usr_wg_TblCharge_AlimonyDebt, SpecAlimonyPaid),
                         PaidSum0 is Credit - Debit
                       ),
              PaidSumList ),
              sum_list(PaidSumList, PaidSum),
              % вычислить Остаток
              RestSum is DebtSum - PaidSum,
              % добавить временные данные
              new_param_list(Scope, Type, DebtPairs1)
            )
          ),
    % сумма Баланса для остатков по долгам
    get_round_data(Scope, EmplKey, "ftAlimonyDebt", _, RoundValue),
    round_sum(Balance, RestBalance, 3, RoundValue),
    % Общая сумма остатков по долгам
    findall( RestSum,
             get_param_list(Scope, Type, DebtPairs1),
    RestSumAllList ),
    sum_list(RestSumAllList, RestAmountAll),
    % добавить временные данные
    new_param_list(Scope, Type, DebtPairs2),
    % контроль Общей суммы
    RestAmountAll > 0,
    % для всех алиментов
    forall( get_data(Scope, kb, usr_wg_Alimony, SpecAlimony),
            ( % суммировать Остатки долгов
              findall( RestSum,
                       get_param_list(Scope, Type, DebtPairs1),
              RestSumList ),
              sum_list(RestSumList, RestAmount),
              % вычислить Коеффициент от Общей суммы
              RestCoef is RestAmount / RestAmountAll,
              % Процент списания долга
              % сопоставить с данными по умолчанию
              Percent1 is Percent / 100,
              fit_data(Scope, [pPercent-Percent1], [pPercent-DebtPercent]),
              % добавить временные данные
              new_param_list(Scope, Type, DebtPairs3)
            )
          ),
    !.

% списание Долгов
drop_debt_bal(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pDropDebt,
    % спецификации параметров Долгов по алиментам
    DebtParams1 = [
                Section-1, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pAlimonyDebtKey-AlimonyDebtKey,
                pRestSum-RestSum, pDateBegin-DateBegin ],
    DebtParams2 = [
                Section-2, pEmplKey-EmplKey,
                pRestBalance-RestBalance, pRestAmountAll-RestAmountAll ],
    DebtParams3 = [
                Section-3, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey,
                pRestCoef-RestCoef ],
    % спецификации временных данных
    DebtPairs4 = [
                Section-4, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pAlimonyDebtKey-AlimonyDebtKey,
                pDebtCharge-DebtCharge, pByRestCoef-ByRestCoef ],
    DebtPairs5 = [
                Section-5, pEmplKey-EmplKey,
                pDebtChargeAmount-DebtChargeAmount ],
    % признак расчета по Коеффициенту
    get_param_list(Scope, Type, DebtParams2),
    ( RestBalance >= RestAmountAll -> ByRestCoef = 0 ; ByRestCoef = 1 ),
    % параметры Округления
    get_round_data(Scope, EmplKey, "ftAlimonyDebt", RoundType, RoundValue),
    % для всех алиментов
    forall( get_param_list(Scope, Type, DebtParams3),
            ( % собрать Остатки долгов
              findall( DateBegin-AlimonyDebtKey-RestSum,
                       ( get_param_list(Scope, Type, DebtParams1),
                         RestSum > 0
                       ),
              RestDataList0 ),
              % в порядке их образования
              msort(RestDataList0, RestDataList),
              % определить Баланс для Списания долгов
              ( ByRestCoef = 0 ->
                RestBalance1 is RestBalance
              ; RestBalance1 is RestBalance * RestCoef
              ),
              round_sum(RestBalance1, RestBalance2, RoundType, RoundValue),
              % списать Остатки долгов
              drop_debt_charge(Scope, RestDataList, DebtPairs4, RestBalance2)
            )
          ),
    % Итог Списания долгов
    findall( DebtCharge,
             get_param_list(Scope, Type, DebtPairs4),
    DebtChargeList ),
    sum_list(DebtChargeList, DebtChargeAmount),
    % добавить временные данные
    new_param_list(Scope, Type, DebtPairs5),
    !.

% списать Остатки долгов
drop_debt_charge(Scope, RestDataList, _, RestBalance) :-
    % - для алиментов
    Scope = wg_fee_alimony,
    ( RestDataList = [] ; RestBalance =< 0 ),
    !.
drop_debt_charge(Scope, [_-AlimonyDebtKey-RestSum|RestDataList], DebtPairs4, RestBalance) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp,
    % определить сумму Списания
    member_list([pAlimonyDebtKey-AlimonyDebtKey, pDebtCharge-DebtCharge], DebtPairs4),
    ( RestBalance > RestSum ->
      DebtCharge is RestSum
    ; DebtCharge is RestBalance
    ),
    % добавить временные данные
    new_param_list(Scope, Type, DebtPairs4),
    % новая спецификация временных данных
    replace_list(DebtPairs4,
                    [pAlimonyDebtKey-AlimonyDebtKey, pDebtCharge-DebtCharge],
                    [pAlimonyDebtKey-_, pDebtCharge-_],
                        DebtPairs41),
    % новый Баланс для Списания долгов
    RestBalance1 is RestBalance - DebtCharge,
    !,
    drop_debt_charge(Scope, RestDataList, DebtPairs41, RestBalance1).

% расчет итога
calc_total(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, NextType = out, Section = pCalcTotal,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-NextType-Section-DT]),
    % спецификации параметров
    CheckParams = [
                pCheckRest-3, pEmplKey-EmplKey,
                pChargeAmount-ChargeAmount,
                pAlimonyChargeAmount-AlimonyChargeAmount,
                pTransfAmount-TransfAmount ],
    DebtParams = [
                pDropDebt-5, pEmplKey-EmplKey,
                pDebtChargeAmount-DebtChargeAmount ],
    % спецификация временных данных
    TotalPairs = [
                Section-1, pEmplKey-EmplKey,
                pTotalChargeAmount-TotalChargeAmount,
                pChargeAmount-ChargeAmount,
                pAlimonyChargeAmount-AlimonyChargeAmount,
                pDebtChargeAmount-DebtChargeAmount,
                pTransfAmount-TransfAmount ],
    % Итог
    get_param_list(Scope, Type, CheckParams),
    ( get_param_list(Scope, Type, DebtParams)
    ; DebtChargeAmount = 0.0
    ),
    TotalChargeAmount is ChargeAmount + DebtChargeAmount,
    % добавить временные данные
    new_param_list(Scope, NextType, TotalPairs),
    !.

% взять параметры Округления
get_round_data(Scope, _, Alias, RoundType, RoundValue) :-
    get_data(Scope, kb, usr_wg_FeeType_Dict, [
                fAlias-Alias, fRoundByFeeType-1,
                fRoundType-RoundType, fRoundValue-RoundValue ]),
    !.
get_round_data(Scope, EmplKey, _, RoundType, RoundValue) :-
    get_param_list(Scope, in, [
                pEmplKey-EmplKey,
                pRoundType-RoundType, pRoundValue-RoundValue ]),
    !.

% Процент перевода
get_transf_percent(Scope, EmplKey, TransferTypeKey, Sum, Percent) :-
    get_param_list(Scope, run, [pEmplKey-EmplKey, pDateCalcTo-DateCalcTo]),
    findall( TransferData,
             get_transf_type(Scope, DateCalcTo, TransferTypeKey, TransferData),
    TransferDataList),
    msort(TransferDataList, TransferDataList1),
    last(TransferDataList1, _-TransferTypeKey1),
    get_transf_scale(Scope, TransferTypeKey1, Sum, Percent),
    !.
get_transf_percent(_, _, _, _, 0.0) :-
    !.

% Расценки на перевод
get_transf_type(Scope, DateCalcTo, TransferTypeKey0, DateBegin-TransferTypeKey) :-
    get_data(Scope, kb, usr_wg_TransferType, [
                fID-TransferTypeKey, fParent-TransferTypeKey0,
                fDateBegin-DateBegin ]),
    \+ get_data(Scope, kb, usr_wg_TransferType, [
                    fParent-TransferTypeKey]),
    DateBegin @< DateCalcTo.
get_transf_type(Scope, DateCalcTo, TransferTypeKey0, TransferData) :-
    get_data(Scope, kb, usr_wg_TransferType, [
                fID-TransferTypeKey1, fParent-TransferTypeKey0 ]),
    get_transf_type(Scope, DateCalcTo, TransferTypeKey1, TransferData).

% Шкала расценок
get_transf_scale(Scope, TransferTypeKey, Sum, Percent) :-
    findall( StartSum-Percent0,
             ( get_data(Scope, kb, usr_wg_TransferScale, [
                         fTranferTypeKey-TransferTypeKey,
                         fStartSum-StartSum, fPercent-Percent0 ]),
               Sum >= StartSum ),
    ScaleDataList),
    msort(ScaleDataList, ScaleDataList1),
    last(ScaleDataList1, _-Percent),
    !.
get_transf_scale(_, _, _, 0.0) :-
    !.

% собрать начисления по Группе начислений
fee_group_charges(Scope, EmplKey, Charges) :-
    % спецификация для начислений
    SpecTblCharge =  [
        fEmplKey-EmplKey,
        fCalYear-Y, fCalMonth-M, fDateBegin-DateBegin,
        fDebit-Debit, fCredit-Credit,
        fFeeTypeKey-FeeTypeKey ],
    % спецификация для группы начислений
    SpecFeeType =  [
        fEmplKey-EmplKey, fFeeTypeKey-FeeTypeKey ],
    % спецификация данных начисления
    ChargeData = [
        Y-M, DateBegin, Debit, Credit, FeeTypeKey ],
    % взять данные
    findall( ChargeData,
              % по начислениям
            ( get_data(Scope, kb, usr_wg_TblCharge, SpecTblCharge),
              % с наличием суммы
              once( ( \+ Debit =:= 0 ; \+ Credit =:= 0 ) ),
              % и соответствующего типа
              get_data(Scope, kb, usr_wg_FeeType, SpecFeeType)
            ),
    % в список
    Charges ),
    !.

% исключаемые начисления
charges_excl(Scope, EmplKey, Charges, ChargesExcl) :-
    % спецификация данных начисления
    ChargeData = [
        _-_, DateBegin, _, _, FeeTypeKey ],
    % собрать исключаемые начисления
    findall( ChargeData,
             ( member(ChargeData, Charges),
               is_fee_type_excl(Scope, EmplKey, DateBegin, FeeTypeKey)
             ),
    ChargesExcl ),
    !.

% сумма начислений
charges_sum(Charges, Amount) :-
    charges_sum(Charges, [], [], 0, Amount),
    !.
%
charges_sum(Charges, Options, Amount) :-
    charges_sum(Charges, Options, [], 0, Amount),
    !.
%
charges_sum(Charges, Options, ValidFeeTypes, Amount) :-
    charges_sum(Charges, Options, ValidFeeTypes, 0, Amount),
    !.
%
charges_sum([], _, _, Amount, Amount) :-
    !.
charges_sum([Charge|Charges], Options, ValidFeeTypes, Amount0, Amount) :-
    charge_acc(Charge, Options, ValidFeeTypes, Amount0, Amount1),
    !,
    charges_sum(Charges, Options, ValidFeeTypes, Amount1, Amount).

% накопление суммы начислений
charge_acc(ChargeData, Options, ValidFeeTypes, Amount0, Amount1) :-
    % спецификация данных
    ChargeData = [
        _-_, _, Debit, Credit, FeeTypeKey ],
    % если тип начисления дейсвителен
    ( ValidFeeTypes = [] ; memberchk(FeeTypeKey, ValidFeeTypes) ),
    % установить опции
    ( memberchk(debit(InclDebit), Options) ; InclDebit = 1 ),
    ( memberchk(credit(InclCredit), Options) ; InclCredit = 1 ),
    % и произвести накопление
    Amount1 is Amount0 + Debit * InclDebit - Credit * InclCredit,
    !.
charge_acc(_, _, _, Amount, Amount) :-
    !.

% тип начисления исключается из расчета
is_fee_type_excl(Scope, EmplKey, DateBegin, FeeTypeKey) :-
    % - для алиментов
    Scope = wg_fee_alimony,
    % если вид начисления "Компенсация отпуска"
    get_data(Scope, kb, usr_wg_FeeType_Dict, [
                fID-FeeTypeKey, fAlias-Alias ]),
    memberchk(Alias, ["ftHolidayComp"]),
    % и сотрудник уволен в месяце текущей даты
    is_fired(Scope, EmplKey, DateBegin),
    !.

% сотрудник уволен в месяце текущей даты
is_fired(Scope, EmplKey, DateBegin) :-
    atom_date(DateBegin, date(Y, M, _)),
    get_data(Scope, kb, usr_wg_MovementLine, [
                fEmplKey-EmplKey,
                fMoveYear-Y, fMoveMonth-M,
                fMovementType-3 ]),
    !.

% сопоставить с данными по умолчанию
fit_data(Scope, [Name-Value0], [Name-Value]) :-
    % - для алиментов (Процент остатка)
    Scope = wg_fee_alimony, Type = fit,
    Name = pRestPercent,
    get_param(Scope, Type, Name-Value1),
    ( Value0 < Value1, Value = Value1
    ; Value = Value0
    ),
    !.
% сопоставить с данными по умолчанию
fit_data(Scope, [Name-Value0], [Name-Value]) :-
    % - для алиментов ( Процент списания долга)
    Scope = wg_fee_alimony, Type = fit,
    Name = pPercent,
    ( Value0 > 0, Value = Value0
    ; get_param(Scope, Type, Name-Value)
    ),
    !.
fit_data(Scope, Pairs0, Pairs) :-
    % - для алиментов (Процент от БПМ)
    Scope = wg_fee_alimony, Type = fit,
    Pairs0 = [pChildCount-ChildCount, pLivingWagePerc-LivingWagePerc0],
    Pairs = [pChildCount-ChildCount, pLivingWagePerc-LivingWagePerc],
    Pairs1 = [pChildQtyCmp-ChildQtyCmp, pLivingWagePerc-LivingWagePerc1],
    %
    get_param_list(Scope, Type, Pairs1),
    catch( atomic_concat(ChildCount, ChildQtyCmp, Atom), _, fail ),
    catch( term_to_atom(Term, Atom), _, fail),
    catch( Term, _, fail),
    %
    ( LivingWagePerc0 < LivingWagePerc1, LivingWagePerc = LivingWagePerc1
    ; LivingWagePerc = LivingWagePerc0
    ),
    !.
fit_data(_, Pairs, Pairs) :-
    !.

/* реализация - расширение для клиента */

% загрузка входных данных по сотруднику
fee_calc_in(Scope, EmplKey, DateBegin, TotalDocKey, FeeTypeKey, RoundType, RoundValue) :-
    Scope = wg_fee_alimony, Type = in, Section = PK,
    % первичный ключ
    PK = [pEmplKey-EmplKey],
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    % записать входные параметры
    new_param_list(Scope, Type, [
        pEmplKey-EmplKey, pDateBegin-DateBegin,
        pTotalDocKey-TotalDocKey, pFeeTypeKey-FeeTypeKey,
        pRoundType-RoundType, pRoundValue-RoundValue
        ]),
    !.

% подготовка данных выполнения
fee_calc_prep(Scope) :-
    Scope = wg_fee_alimony, Type = in, TypeNextStep = run,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-TypeNextStep-DT]),
    % для каждого сотрудника
    get_param_list(Scope, Type, [pEmplKey-_, pDateBegin-DateBegin], Pairs),
    % собрать входные данные
    findall( Pairs0,
             ( member(Template, [pCommon-1, pAlimony-1]),
               get_param_list(Scope, Type, [Template], Pairs0)
             ),
    PairsList ),
    append(PairsList, PairsNextStep0),
    % сформировать данные выполнения
    atom_date(DateBegin, date(Y, M, _)),
    atom_date(DateCalcFrom, date(Y, M, 1)),
    date_add(DateBegin, 1, month, DateBegin1),
    atom_date(DateBegin1, date(Y1, M1, _)),
    atom_date(DateCalcTo, date(Y1, M1, 1)),
    % записать данные выполнения
    append([Pairs,
            [pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo],
            PairsNextStep0],
                PairsNextStep),
    new_param_list(Scope, TypeNextStep, PairsNextStep),
    % найти альтернативу
    fail.
fee_calc_prep(_) :-
    % больше альтернатив нет
    !.

% выгрузка данных выполнения по сотруднику
fee_calc_run(Scope, EmplKey) :-
    Scope = wg_fee_alimony, Type = run, Section = PK,
    % первичный ключ
    PK = [pEmplKey-EmplKey],
    % взять данные выполнения
    get_param_list(Scope, Type, PK),
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    true.

% формирование SQL-запросов по сотруднику
fee_calc_sql(Scope, EmplKey, PredicateName, Arity, SQL) :-
    Scope = wg_fee_alimony, Type = run, TypeNextStep = query,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-TypeNextStep-DT]),
    % взять данные выполнения для подстановки параметров
    get_param_list(Scope, Type, [pEmplKey-EmplKey], Pairs),
    % для каждой спецификации набора данных
    gd_pl_ds(Scope, kb, PredicateName, Arity, _),
    Query = PredicateName/Arity,
    is_valid_sql(Query),
    % взять SQL-строку с параметрами
    get_sql(Scope, kb, Query, SQL0, Params),
    % сопоставить параметры с данными выполнения
    member_list(Params, Pairs),
    % подготовить SQL-запрос
    prepare_sql(SQL0, Params, SQL),
    % записать данные по SQL-запросу
    PairsNextStep = [pEmplKey-EmplKey, pQuery-Query, pSQL-SQL],
    new_param_list(Scope, TypeNextStep, PairsNextStep),
    true.

% формирование SQL-команд по сотруднику
fee_calc_cmd(Scope, EmplKey, PredicateName, Arity, SQL) :-
    Scope = wg_fee_alimony, Type = run, TypeNextStep = cmd,
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-TypeNextStep-DT]),
    % взять данные выполнения для подстановки параметров
    get_param_list(Scope, Type, [pEmplKey-EmplKey], Pairs),
    % для каждой спецификации набора данных
    gd_pl_ds(Scope, cmd, PredicateName, Arity, _),
    Query = PredicateName/Arity,
    is_valid_sql(Query),
    % взять SQL-строку с параметрами
    get_sql(Scope, cmd, Query, SQL0, Params),
    % сопоставить параметры с данными выполнения
    member_list(Params, Pairs),
    % подготовить SQL-запрос
    prepare_sql(SQL0, Params, SQL),
    % записать данные по SQL-команде
    PairsNextStep = [pEmplKey-EmplKey, pCmd-Query, pSQL-SQL],
    new_param_list(Scope, TypeNextStep, PairsNextStep),
    true.

% выгрузка выходных данных по сотруднику
fee_calc_out(Scope, EmplKey, Result) :-
    Scope = wg_fee_alimony, Type = out, Section = PK,
    % первичный ключ
    PK = [pEmplKey-EmplKey],
    % спецификация параметров выходных данных
    append([[pCalcTotal-1], PK, [pTotalChargeAmount-Result]], OutPairs),
    % взять выходные данные
    get_param_list(Scope, Type, OutPairs),
    % взять локальное время
    get_local_stamp(DT),
    % записать отладочную информацию
    new_param_list(Scope, debug, [Scope-Type-Section-DT]),
    true.

% выгрузка выходных данных по начислениям по сотруднику
fee_calc_charge(Scope, EmplKey, ChargeSum, FeeTypeKey, DocKey, AccountKeyIndex) :-
    % - начисление алиментов
    Scope = wg_fee_alimony, Type = temp, AccountKeyIndex = 0,
    get_data(Scope, kb, usr_wg_FeeType_Dict, [
                fID-FeeTypeKey, fAlias-"ftAlimony" ]),
    % спецификация параметров алиментов
    AlimonyParams = [
                pCalcFormula-1, pEmplKey-EmplKey,
                pAlimonyCharge-ChargeSum, pAlimonyKey-DocKey ],
    % взять данные по алиментам
    get_param_list(Scope, Type, AlimonyParams),
    ChargeSum > 0,
    true.
fee_calc_charge(Scope, EmplKey, ChargeSum, FeeTypeKey, DocKey, AccountKeyIndex) :-
    % - списание долгов по алиментам
    Scope = wg_fee_alimony, Type = temp, AccountKeyIndex = 1,
    get_data(Scope, kb, usr_wg_FeeType_Dict, [
                fID-FeeTypeKey, fAlias-"ftAlimonyDebt" ]),
    % спецификация параметров списания долгов
    DebtParams = [
                pDropDebt-4, pEmplKey-EmplKey,
                pDebtCharge-ChargeSum, pAlimonyDebtKey-DocKey ],
    % взять данные по списанию долгов
    get_param_list(Scope, Type, DebtParams),
    ChargeSum > 0,
    true.
fee_calc_charge(Scope, EmplKey, ChargeSum, FeeTypeKey, DocKey, AccountKeyIndex) :-
    % - пересылка алиментов
    Scope = wg_fee_alimony, Type = temp, AccountKeyIndex = 2,
    get_data(Scope, kb, usr_wg_FeeType_Dict, [
                fID-FeeTypeKey, fAlias-"ftTransferDed" ]),
    % спецификация параметров перевода
    TransfParams = [
                pCalcTransf-1, pEmplKey-EmplKey,
                pTransfSum-ChargeSum, pAlimonyKey-DocKey ],
    % взять данные по переводу
    get_param_list(Scope, Type, TransfParams),
    ChargeSum > 0,
    true.

% выгрузка выходных данных по долгам по сотруднику
fee_calc_debt(Scope, EmplKey, AlimonyKey, DebtSum) :-
    % - долги по алиментам
    Scope = wg_fee_alimony, Type = temp,
    % спецификация параметров долга
    DebtParams = [
                pAddDebt-1, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pAlimonyDebt-DebtSum ],
    % взять данные по списанию долгу
    get_param_list(Scope, Type, DebtParams),
    DebtSum > 0,
    true.

/**/

 %
%%
