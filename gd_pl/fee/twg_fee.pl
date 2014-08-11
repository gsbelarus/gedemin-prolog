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
    usr_wg_TblCharge_Prev,
    usr_wg_TblCharge_Extra,
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
    Scope = wg_fee_alimony, Type = temp, Section = PK,
    % первичный ключ
    PK = [pEmplKey-EmplKey],
    % записать отладочную информацию
    param_list_debug(Scope, begin-Section),
    % удалить временные данные по расчету
    forall( get_param(Scope, Type, pEmplKey-EmplKey, Pairs),
            dispose_param_list(Scope, Type, Pairs) ),
    % расчет табеля
    calc_tab(Scope, EmplKey),
    % расчет суммы
    calc_amount(Scope, EmplKey),
    % расчет формулы
    calc_formula(Scope, EmplKey),
    % расчет расходов по переводу
    calc_transf(Scope, EmplKey, 1),
    % контроль остатка
    check_rest(Scope, EmplKey),
    % начисление долгов
    add_debt(Scope, EmplKey),
    % списание долгов
    drop_debt(Scope, EmplKey),
    % расчет итога
    calc_total(Scope, EmplKey),
    % записать отладочную информацию
    param_list_debug(Scope, end-Section),
    !.

% расчет табеля
calc_tab(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCalcTab,
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
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
              catch( TCoef is AHoures / THoures, _, TCoef = 1),
              % добавить временные данные
              new_param_list(Scope, Type, AlimonyPairs)
            )
          ),
    !.

% расчет суммы
calc_amount(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCalcAmount,
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % спецификация Начислений по Предыдущему периоду
    SpecTblChargePrev = [
                fDocKey-AlimonyKey, fEmplKey-EmplKey,
                fDebit-Debit, fCredit-Credit,
                fFeeTypeKey-FeeTypeKey ],
    % спецификация временных данных
    AmountPaidPairs = [
                Section-4, pEmplKey-EmplKey,
                pAlimonyAmountPaid-AlimonyAmountPaid,
                pAlimonyAmount-AlimonyAmount, pAlimonyCoef-AlimonyCoef ],
    SumPaidPairs = [
                Section-5, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonySumPaid-AlimonySumPaid,
                pAlimonySum-AlimonySum, pAlimonyCoef-AlimonyCoef ],
    % сумма по Предыдущему периоду
    calc_amount(Scope, EmplKey, 1),
    get_param_list(Scope, Type, [
                    Section-1, pEmplKey-EmplKey,
                    pForAlimony-ForAlimony1 ]),
    % сумма по Предыдущему периоду
    % где дата Зачисления соответствует Текущему периоду
    calc_amount(Scope, EmplKey, 2),
    get_param_list(Scope, Type, [
                    Section-2, pEmplKey-EmplKey,
                    pForAlimony-ForAlimony2 ]),
    % Коэффициент для Переходящего начисления
    catch( AlimonyCoef is ForAlimony1 / ForAlimony2, _, AlimonyCoef = 0),
    % начислено Алиментов по Предыдущему периоду
    get_data(Scope, kb, usr_wg_FeeType_Dict, [
                fID-FeeTypeKey, fAlias-"ftAlimony" ]),
    findall( AlimonySum,
             ( get_data(Scope, kb, usr_wg_TblCharge_Prev, SpecTblChargePrev),
               AlimonySum is Credit - Debit
             ),
    AlimonySumList),
    sum_list(AlimonySumList, AlimonyAmount),
    % Оплачено по Предыдущему периоду
    AlimonyAmountPaid is round(AlimonyAmount * AlimonyCoef) * 1.0,
    % сумма по Текущему периоду
    calc_amount(Scope, EmplKey, 3),
    % добавить временные данные
    new_param_list(Scope, Type, AmountPaidPairs),
    forall( get_data(Scope, kb, usr_wg_TblCharge_Prev, SpecTblChargePrev),
            ( AlimonySum is Credit - Debit,
              AlimonySumPaid is round(AlimonySum * AlimonyCoef) * 1.0,
              % добавить временные данные
              new_param_list(Scope, Type, SumPaidPairs)
            )
          ),
    !.
%
calc_amount(Scope, EmplKey, Shape) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCalcAmount,
    % собрать начисления по Группе начислений
    fee_group_charges(Scope, EmplKey, Charges, Shape),
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
    ( AmountTaxable =:= 0, IncomeTaxCoef = 0
    ; IncomeTaxCoef is IncomeTax / AmountTaxable
    ),
    % Облагаемая ПН Исключаемая сумма
    charges_sum(ChargesExcl, [debit(1), credit(0)], TaxableFeeTypeList, AmountTaxableExcl),
    % Исключаемый ПН
    IncomeTaxExcl is AmountTaxableExcl * IncomeTaxCoef,
    % Расчетная сумма = Общая сумма - Исключаемая сумма - Исключаемый ПН
    ForAlimony0 is AmountAll - AmountExcl - IncomeTaxExcl,
    to_currency(ForAlimony0, ForAlimony, 0),
    % спецификация временных данных
    AmountPairs = [
                Section-Shape, pEmplKey-EmplKey, pForAlimony-ForAlimony,
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
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % спецификация алиментов
    SpecAlimony = [
                fDocKey-AlimonyKey, fEmplKey-EmplKey, fFormula-Formula,
                fChildCount-_, fLivingWagePerc-_ ],
    % спецификации временных данных
    FormulaPairs = [
                Section-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCharge-_,
                pAlimonySum-_,  pByBudget-_,
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
                pAlimonyCharge-AlimonySum,
                pAlimonySum-AlimonySum, pByBudget-ByBudget,
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
                    pCalcAmount-3, pEmplKey-EmplKey, pForAlimony-ForAlimony ]),
    replace_all(Formula1, Var_ForAlimony, ForAlimony, Formula2),
    % Результат
    replace_all(Formula2, ",", ".", Formula3),
    ( catch( term_to_atom(Expr, Formula3), _, fail ),
      catch( Eval is Expr, _, fail), FormulaError = 0
    ; Eval = 0, FormulaError = 1
    ),
    get_param_list(Scope, Type, [
                    pCalcTab-2, pAlimonyKey-AlimonyKey, pTCoef-TCoef ]),
    Result is Eval * TCoef,
    % Часть БПМ
    ( ChildCount > 0 ->
      get_budget(Scope, DateCalcTo, BudgetConst),
      BudgetPart is BudgetConst * LivingWagePerc
    ; BudgetPart = 0
    ),
    % Оплачено по Предыдущему периоду
    once( ( get_param_list(Scope, Type, [
                            pCalcAmount-5, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                            pAlimonySumPaid-AlimonySumPaid ])
          ; AlimonySumPaid = 0
          )
        ),
    % сумма Удержания c Контролем от БПМ
    ( FormulaError = 0, Result + AlimonySumPaid < BudgetPart ->
      AlimonySum0 is BudgetPart - AlimonySumPaid,
      ByBudget = 1
    ; AlimonySum0 = Result,
      ByBudget = 0
    ),
    get_round_data(Scope, EmplKey, "ftAlimony", RoundType, RoundValue),
    round_sum(AlimonySum0, AlimonySum, RoundType, RoundValue),
    !.

% расчет расходов по переводу
calc_transf(Scope, EmplKey, Stage) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pCalcTransf,
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % спецификация алиментов
    SpecAlimony = [
                fEmplKey-EmplKey, fDocKey-AlimonyKey,
                fTransferTypeKey-TransferTypeKey0, fRecipient-Recipient0 ],
    % спецификация параметров алиментов
    AlimonyParams = [
                pCalcFormula-1, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pAlimonyCharge-AlimonyCharge ],
    % спецификация параметров списания долгов алиментов
    DropDebtParams = [
                pDropDebt-5, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pDropDebtCharge-DropDebtCharge ],
    % спецификация временных данных
    TransfPairs = [
                Section-Stage, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey1,
                pTransfCharge-TransfCharge, pTransfByGroup-TransfByGroup,
                pTransferTypeKey-TransferTypeKey, pRecipient-Recipient,
                pForTransfAmount-ForTransfAmount, pTransfPercent-TransfPercent ],
    % спецификации данных для расходов по переводу
    AlimonyData = [
                AlimonyKey, TransferTypeKey0, Recipient0, AlimonyCharge ],
    DropDebtData = [
                AlimonyKey, TransferTypeKey0, Recipient0, DropDebtCharge ],
    AggrTransfData = [
                AlimonyKey1, TransfByGroup, TransferTypeKey, Recipient,
                ForTransfAmount, TransfPercent, TransfCharge ],
    % собрать данные для расходов по переводу
    findall( AlimonyData,
             ( get_data(Scope, kb, usr_wg_Alimony, SpecAlimony),
               TransferTypeKey0 > 0,
               get_param_list(Scope, Type, AlimonyParams)
             ),
    AlimonyDataList ),
    findall( DropDebtData,
             ( get_data(Scope, kb, usr_wg_Alimony, SpecAlimony),
               TransferTypeKey0 > 0,
               get_param_list(Scope, Type, DropDebtParams)
             ),
    DropDebtDataList ),
    append(AlimonyDataList, DropDebtDataList, TransfDataList),
    % агрегировать суммы расходов по переводам
    aggr_fransf(Scope, EmplKey, TransfDataList, AggrTransfDataList),
    % удалить временные данные по переводам
    forall( get_param_list(Scope, Type, [Section-_, pEmplKey-EmplKey], Pairs),
            dispose_param_list(Scope, Type, Pairs) ),
    % для всех расходов по переводам
    forall( ( member(AggrTransfData, AggrTransfDataList),
              TransfCharge > 0
            ),
            % добавить временные данные
            new_param_list(Scope, Type, TransfPairs)
          ),
    !.

% агрегировать суммы расходов по переводам
aggr_fransf(_, _, [], []) :-
    !.
aggr_fransf(Scope, EmplKey, [TransfData|TransfDataList], [TransfAggrData|TransfAggrDataList]) :-
    aggr_fransf(Scope, EmplKey, TransfData, [TransfData|TransfDataList], TransfDataList1, TransfAggrData),
    !,
    aggr_fransf(Scope, EmplKey, TransfDataList1, TransfAggrDataList).
%
aggr_fransf(Scope, EmplKey, TransfData, TransfDataList, TransfDataList1, TransfAggrData) :-
    % спецификации данных для расходов по переводу
    TransfData = [AlimonyKey, TransferTypeKey, Recipient, _],
    TransfAggrData = [
                AlimonyKey, TransfByGroup, TransferTypeKey, Recipient,
                ForTransfAmount, TransfPercent, TransfCharge ],
    % собрать суммы по Группе [Документ, Вид перевода, Получатель]
    findall( AlimonyCharge,
             member([AlimonyKey, TransferTypeKey, Recipient, AlimonyCharge],
                     TransfDataList),
    AlimonyChargeList),
    % Итог по группе
    sum_list(AlimonyChargeList, ForTransfAmount),
    % Признак группы
    ( length(AlimonyChargeList, 1),
      TransfByGroup = 0
    ;
      TransfByGroup = 1
    ),
    % Процент для расхода на перевод
    get_transf_percent(Scope, EmplKey, TransferTypeKey, ForTransfAmount, TransfPercent),
    % Сумма расхода по переводу
    TransfCharge0 is ForTransfAmount * TransfPercent / 100,
    get_round_data(Scope, EmplKey, "ftTransferDed", RoundType, RoundValue),
    round_sum(TransfCharge0, TransfCharge, RoundType, RoundValue),
    % если есть Группа
    ( TransfByGroup = 1,
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
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % спецификация алиментов
    SpecAlimony = [
                fDocKey-AlimonyKey, fEmplKey-EmplKey, fRestPercent-RestPercent0 ],
    % спецификация параметров алиментов
    AlimonyParams = [
                pCalcFormula-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonySum-AlimonySum ],
    % спецификация параметров контроля
    CheckParams = [
                pCalcAmount-3, pEmplKey-EmplKey,
                pAmountAll-AmountAll ],
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
    CheckAmount is round(AmountAll - RestAmount) * 1.0,
    % добавить временные данные
    new_param_list(Scope, Type, CheckPairs),
    % для всех алиментов
    forall( get_data(Scope, kb, usr_wg_Alimony, SpecAlimony),
            ( get_param_list(Scope, Type, AlimonyParams),
              % вычислить коеффициент от Итога
              catch( AlimonyCoef is AlimonySum / AlimonyAmount, _, AlimonyCoef = 1),
              % добавить временные данные
              new_param_list(Scope, Type, AlimonyPairs)
            )
          ),
    % Дельта для расчета при нехватке средств
    get_param(Scope, fit, pCalcDelta-CalcDelta), CalcDelta > 0,
    % контроль остатка по сумме Контроля
    check_rest(Scope, EmplKey, CheckAmount, 0, CalcDelta, 0),
    !.
check_rest(_, _) :-
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
                pCalcTransf-_, pEmplKey-EmplKey, pTransfCharge-TransfCharge ],
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
    findall( TransfCharge,
             get_param_list(Scope, Type, TransfParams),
    TransfChargeList),
    sum_list(TransfChargeList, TransfAmount),
    ChargeAmount is AlimonyChargeAmount + TransfAmount,
    % сумма Контроля не меньше суммы к Удержанию
    \+ CheckAmount < ChargeAmount,
    % сумма Баланса
    Balance is round(CheckAmount - ChargeAmount) * 1.0,
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
    % распределить суммы по Коэффициентам от суммы Резерва
    charge_by_coef(Scope, EmplKey, ReserveAmount),
    % пересчитать расходы по Переводу
    calc_transf(Scope, EmplKey, 2),
    !,
    check_rest(Scope, EmplKey, CheckAmount, CalcDelta1, CalcDelta, 1).

% распределить суммы по Коэффициентам от суммы Резерва
charge_by_coef(Scope, EmplKey, ReserveAmount) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp,
    % спецификации параметров алиментов
    AlimonyParams1 = [
                pCalcFormula-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCharge-_ ],
    AlimonyParams2 = [
                pCheckRest-2, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCoef-AlimonyCoef ],
    % параметры Округления
    get_round_data(Scope, EmplKey, "ftAlimony", RoundType, RoundValue),
    % для всех Алиментов
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
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % спецификации параметров алиментов
    AlimonyParams = [
                pCalcFormula-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyCharge-AlimonyCharge, pAlimonySum-AlimonySum,
                pChildCount-ChildCount ],
    % спецификация временных данных
    DebtPairs = [
                Section-1, pEmplKey-EmplKey, pAlimonyKey-AlimonyKey,
                pAlimonyDebt-AlimonyDebt,
                pAlimonyCharge-AlimonyCharge, pAlimonySum-AlimonySum ],
    % параметры Округления
    get_round_data(Scope, EmplKey, "ftAlimonyDebt", RoundType, RoundValue),
    % для всех Алиментов с заполненным Количеством детей
    forall( ( get_param_list(Scope, Type, AlimonyParams), ChildCount > 0 ),
            ( % рассчитать сумму Долга по алиментам
              AlimonyDebt0 is AlimonySum - AlimonyCharge,
                      % при наличии Долга по алиментам
              once( ( round_sum(AlimonyDebt0, AlimonyDebt, RoundType, RoundValue),
                      AlimonyDebt > 0,
                      % добавить временные данные
                      new_param_list(Scope, Type, DebtPairs)
                    ; % иначе продолжить
                      true
                    )
                  )
             )
          ),
    !.

% списание долгов
drop_debt(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pDropDebt,
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    % нет новых долгов
    \+ get_param_list(Scope, Type, [pAddDebt-1, pEmplKey-EmplKey]),
    % последний прием на работу
    PK = [pEmplKey-EmplKey, pFirstMoveKey-_],
    get_last_hire(Scope, PK, DateIn),
    % есть данные по долгам
    once( ( get_data(Scope, kb, usr_wg_AlimonyDebt, [
                        fEmplKey-EmplKey, fDateBegin-DebtDate ]),
            DebtDate @>= DateIn
          )
        ),
    % спецификация параметров Контроля
    CheckParams = [
                pCheckRest-3, pEmplKey-EmplKey, pBalance-Balance ],
    % Контроль Баланса
    get_param_list(Scope, Type, CheckParams),
    Balance > 0,
    % Подготовка данных по Cписанию долгов
    drop_debt_prep_data(Scope, EmplKey, DateIn, Balance),
    % Списание долгов
    drop_debt_charge(Scope, EmplKey),
    % Контроль остатка после Списания долгов
    %drop_debt_check_rest(Scope, EmplKey),
    !.
drop_debt(Scope, _) :-
    % - для алиментов
    Scope = wg_fee_alimony,
    !.

% Подготовка данных по Cписанию долгов
drop_debt_prep_data(Scope, EmplKey, DateIn, Balance) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pDropDebt,
    CutRoundType = 3,
    % спецификация Алиментов
    SpecAlimony = [
                fDocKey-AlimonyKey, fEmplKey-EmplKey,
                fPercent-Percent ],
    % спецификация Долгов по алиментам
    SpecAlimonyDebt = [
                fDocKey-AlimonyDebtKey, fEmplKey-EmplKey,
                fCalYear-Y, fCalMonth-M, fDateBegin-DateBegin,
                fAlimonyKey-AlimonyKey, fDebtSum-DebtSum ],
    % спецификация Списания долгов по алиментам
    SpecAlimonyPaid = [
                fDocKey-AlimonyDebtKey, fEmplKey-EmplKey,
                fDebit-Debit, fCredit-Credit ],
    % спецификации временных данных
    RestDebtPairs = [
                Section-1, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pAlimonyDebtKey-AlimonyDebtKey,
                pRestSum-RestSum, pDebtSum-DebtSum, pPaidSum-PaidSum,
                pYM-Y-M, pDateBegin-DateBegin ],
    DropDebtPairs = [
                Section-2, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pDropDebtAmount-DropDebtAmount,
                pRestDebtAmount-RestDebtAmount, pEvalDebtAmount-EvalDebtAmount,
                pForAlimony-ForAlimony, pDebtPercent-DebtPercent ],
    TotalDebtPairs = [
                Section-3, pEmplKey-EmplKey,
                pDropDeptBalance-DropDeptBalance,
                pDropDebtTotal-DropDebtTotal, pRestDebtTotal-RestDebtTotal ],
    CoefDebtPairs = [
                Section-4, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pDropDebtCoef-DropDebtCoef ],
    % параметры Округления
    get_round_data(Scope, EmplKey, "ftAlimonyDebt", RoundType, RoundValue),
    % сумма Баланса для Cписания долгов по алиментам
    round_sum(Balance, DropDeptBalance, CutRoundType, RoundValue),
    DropDeptBalance > 0,
    % для всех Долгов по алиментам
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
              RestSum0 is DebtSum - PaidSum,
              round_sum(RestSum0, RestSum, CutRoundType, RoundValue),
              % добавить временные данные
              once( ( RestSum > 0,
                      new_param_list(Scope, Type, RestDebtPairs)
                    ; true
                    )
                  )
            )
          ),
    % Общая сумма Остатков по долгам
    findall( RestSum,
             get_param_list(Scope, Type, RestDebtPairs),
    RestSumList ),
    sum_list(RestSumList, RestDebtTotal),
    RestDebtTotal > 0,
    % для всех Алиментов
    forall( get_data(Scope, kb, usr_wg_Alimony, SpecAlimony),
            ( % суммировать Остатки по долгам
              findall( RestSum,
                       get_param_list(Scope, Type, RestDebtPairs),
              RestDebtList ),
              sum_list(RestDebtList, RestDebtAmount),
              % сумма Для алиментов
              get_param_list(Scope, Type, [
                    pCalcAmount-3, pEmplKey-EmplKey, pForAlimony-ForAlimony ]),
              % Процент Списания долга
              Percent1 is Percent / 100,
              fit_data(Scope, [pPercent-Percent1], [pPercent-DebtPercent]),
              % расчет Списания долга
              EvalDebtAmount0 is ForAlimony * DebtPercent,
              round_sum(EvalDebtAmount0, EvalDebtAmount, RoundType, RoundValue),
              % сумма Списания долга
              ( EvalDebtAmount < RestDebtAmount ->
                DropDebtAmount = EvalDebtAmount
              ; DropDebtAmount = RestDebtAmount
              ),
              % добавить временные данные
              once( ( DropDebtAmount > 0,
                      new_param_list(Scope, Type, DropDebtPairs)
                    ; true
                    )
                  )
            )
          ),
    % Общая сумма Списания долга
    findall( DropDebtAmount,
             get_param_list(Scope, Type, DropDebtPairs),
    DropDebtAmountList ),
    sum_list(DropDebtAmountList, DropDebtTotal),
    DropDebtTotal > 0,
    % добавить временные данные
    new_param_list(Scope, Type, TotalDebtPairs),
    % для всех Списаний долгов по Алиментам
    forall( get_param_list(Scope, Type, DropDebtPairs),
            ( % рассчитать Пропорцию
              DropDebtCoef is DropDebtAmount / DropDebtTotal,
              % добавить временные данные
              new_param_list(Scope, Type, CoefDebtPairs)
            )
          ),
    !.

% Списание долгов
drop_debt_charge(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pDropDebt,
    % Итоги для Списания долгов
    TotalDebtParams = [
                Section-3, pEmplKey-EmplKey,
                pDropDeptBalance-DropDeptBalance, pDropDebtTotal-DropDebtTotal ],
    get_param_list(Scope, Type, TotalDebtParams),
    ( DropDeptBalance < DropDebtTotal,
      ByDropDebtCoef = 1
    ; ByDropDebtCoef = 0
    ),
    % Списание долгов по Балансу
    drop_debt_charge(Scope, EmplKey, DropDeptBalance, ByDropDebtCoef),
    !.
% Списание долгов по Балансу
drop_debt_charge(Scope, EmplKey, DropDeptBalance, ByDropDebtCoef) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, Section = pDropDebt,
    % спецификации параметров Долгов по алиментам
    RestDebtParams = [
                Section-1, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pAlimonyDebtKey-AlimonyDebtKey,
                pRestSum-RestSum, pDateBegin-DateBegin ],
    DropDebtPairs = [
                Section-2, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pDropDebtAmount-DropDebtAmount ],
    CoefDebtParams = [
                Section-4, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pDropDebtCoef-DropDebtCoef ],
    % спецификация временных данных по Списанию долгов
    DropDebtChargePairs = [
                Section-5, pEmplKey-EmplKey,
                pAlimonyKey-AlimonyKey, pAlimonyDebtKey-AlimonyDebtKey,
                pDropDebtCharge-_, pByDropDebtCoef-ByDropDebtCoef ],
    % удалить временные данные по Списанию долгов
    forall( get_param_list(Scope, Type, [Section-5, pEmplKey-EmplKey], Pairs),
            dispose_param_list(Scope, Type, Pairs) ),
    % параметры Округления
    get_round_data(Scope, EmplKey, "ftAlimonyDebt", RoundType, RoundValue),
    % для всех Долгов по алиментам
    forall( get_param_list(Scope, Type, DropDebtPairs),
            ( % собрать Остатки долгов
              findall( DateBegin-AlimonyDebtKey-RestSum,
                       get_param_list(Scope, Type, RestDebtParams),
              RestDebtDataList0 ),
              % в порядке их образования
              msort(RestDebtDataList0, RestDebtDataList),
              % определить Баланс для Списания долгов
              ( ByDropDebtCoef = 0 ->
                DropDeptBalance1 is DropDeptBalance
              ; get_param_list(Scope, Type, CoefDebtParams),
                DropDeptBalance1 is DropDeptBalance * DropDebtCoef
              ),
              round_sum(DropDeptBalance1, DropDeptBalance2, RoundType, RoundValue),
              % списать Остатки долгов
              drop_debt_charge(Scope, RestDebtDataList, DropDebtChargePairs, DropDebtAmount, DropDeptBalance2, RoundType, RoundValue)
            )
          ),
    % пересчитать расходы по Переводу
    calc_transf(Scope, EmplKey, 3),
    !.

% списать Остатки долгов
drop_debt_charge(Scope, RestDebtDataList, _, DropDebtAmount, DropDeptBalance, _, _) :-
    % - для алиментов
    Scope = wg_fee_alimony,
    ( RestDebtDataList = [] ; DropDebtAmount =< 0 ; DropDeptBalance =< 0 ),
    !.
drop_debt_charge(Scope, [_-AlimonyDebtKey-RestSum|RestDebtDataList], DropDebtChargePairs, DropDebtAmount, DropDeptBalance, RoundType, RoundValue) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp,
    % определить сумму Списания
    ( RestSum < DropDebtAmount  ->
      DropDebtCharge0 is RestSum
    ; DropDebtCharge0 is DropDebtAmount
    ),
    ( DropDebtCharge0 < DropDeptBalance  ->
      DropDebtCharge1 is DropDebtCharge0
    ; DropDebtCharge1 is DropDeptBalance
    ),
    round_sum(DropDebtCharge1, DropDebtCharge, RoundType, RoundValue),
    member_list([pAlimonyDebtKey-AlimonyDebtKey, pDropDebtCharge-DropDebtCharge],
                    DropDebtChargePairs),
    % добавить временные данные
    new_param_list(Scope, Type, DropDebtChargePairs),
    % новая спецификация временных данных
    replace_list(DropDebtChargePairs,
                    [pAlimonyDebtKey-AlimonyDebtKey, pDropDebtCharge-DropDebtCharge],
                    [pAlimonyDebtKey-_, pDropDebtCharge-_],
                        DropDebtChargePairs1),
    % новый Баланс для Списания долгов
    DropDebtAmount1 is DropDebtAmount - DropDebtCharge,
    DropDeptBalance1 is DropDeptBalance - DropDebtCharge,
    !,
    drop_debt_charge(Scope, RestDebtDataList, DropDebtChargePairs1, DropDebtAmount1, DropDeptBalance1, RoundType, RoundValue).

% расчет итога
calc_total(Scope, EmplKey) :-
    % - для алиментов
    Scope = wg_fee_alimony, Type = temp, NextType = out, Section = pCalcTotal,
    % записать отладочную информацию
    param_list_debug(Scope, NextType-Section),
    % спецификации параметров
    AlimonyChargeParams = [
                pCheckRest-3, pEmplKey-EmplKey,
                pAlimonyChargeAmount-AlimonyChargeAmount ],
    DropDebtChargeParams = [
                pDropDebt-5, pEmplKey-EmplKey,
                pDropDebtCharge-DropDebtCharge ],
    TransfChargeParams = [
                pCalcTransf-_, pEmplKey-EmplKey,
                pTransfCharge-TransfCharge ],
    % спецификация временных данных
    TotalPairs = [
                Section-1, pEmplKey-EmplKey,
                pAllChargeTotal-AllChargeTotal,
                pAlimonyChargeTotal-AlimonyChargeAmount,
                pDropDebtChargeTotal-DropDebtChargeTotal,
                pTransfChargeTotal-TransfChargeTotal ],
    % Итог по Алиментам
    once( ( get_param_list(Scope, Type, AlimonyChargeParams)
          ; AlimonyChargeAmount = 0
          )
        ),
    % Итог по Списанию Долгов
    findall( DropDebtCharge,
             get_param_list(Scope, Type, DropDebtChargeParams),
    DropDebtChargeList),
    sum_list(DropDebtChargeList, DropDebtChargeTotal),
    % Итог по Расходам на переводы
    findall( TransfCharge,
             get_param_list(Scope, Type, TransfChargeParams),
    TransfChargeList),
    sum_list(TransfChargeList, TransfChargeTotal),
    % Общий итог
    AllChargeTotal is AlimonyChargeAmount + DropDebtChargeTotal + TransfChargeTotal,
    % удалить выходные данные по расчету
    forall( get_param(Scope, NextType, pEmplKey-EmplKey, Pairs),
            dispose_param_list(Scope, NextType, Pairs) ),
    % добавить выходные данные
    new_param_list(Scope, NextType, TotalPairs),
    !.

/* реализация - сервис */

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

% Процент для расхода на перевод
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
fee_group_charges(Scope, EmplKey, Charges, Shape) :-
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
    % текущее Итоговое начисление
    get_param_list(Scope, run, [
                    pEmplKey-EmplKey, pDateBegin-DateBegin0 ]),
    atom_date(DateBegin0, date(Y0, M0, _)),
    % выбор набора данных по виду расчета
    memberchk(Shape-DatasetName, [
                    1-usr_wg_TblCharge_Prev,
                    2-usr_wg_TblCharge_Prev,
                    3-usr_wg_TblCharge ]),
    % взять данные
    findall( ChargeData,
              % по начислениям
            ( get_data(Scope, kb, DatasetName, SpecTblCharge),
              % соответствующего типа
              get_data(Scope, kb, usr_wg_FeeType, SpecFeeType),
              % с фильтром для вида расчета
              ( Shape = 1, Y-M = Y0-M0 ; \+ Shape = 1 ),
              % и контролем суммы
              ( \+ Debit =:= 0 ; \+ Credit =:= 0 )
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
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
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
    % записать отладочную информацию
    param_list_debug(Scope, Type-TypeNextStep),
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
    date_add(DateBegin, -1, month, DateBegin0),
    atom_date(DateBegin0, date(Y0, M0, _)),
    atom_date(DatePrevCalcFrom, date(Y0, M0, 1)),
    atom_date(DateBegin, date(Y, M, _)),
    atom_date(DateCalcFrom, date(Y, M, 1)),
    date_add(DateBegin, 1, month, DateBegin1),
    atom_date(DateBegin1, date(Y1, M1, _)),
    atom_date(DateCalcTo, date(Y1, M1, 1)),
    % записать данные выполнения
    append([ Pairs,
             [
               pDatePrevCalcFrom-DatePrevCalcFrom, pDatePrevCalcTo-DateCalcFrom,
               pDateCalcFrom-DateCalcFrom, pDateCalcTo-DateCalcTo
             ],
             PairsNextStep0
           ],
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
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
    true.

% формирование SQL-запросов по сотруднику
fee_calc_sql(Scope, EmplKey, PredicateName, Arity, SQL) :-
    Scope = wg_fee_alimony, Type = run, TypeNextStep = query,
    % записать отладочную информацию
    param_list_debug(Scope, Type-TypeNextStep),
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
    % записать отладочную информацию
    param_list_debug(Scope, Type-TypeNextStep),
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
    append([[pCalcTotal-1], PK, [pAllChargeTotal-Result]], OutPairs),
    % взять выходные данные
    get_param_list(Scope, Type, OutPairs),
    % записать отладочную информацию
    param_list_debug(Scope, Type-Section),
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
                pDropDebt-5, pEmplKey-EmplKey,
                pDropDebtCharge-ChargeSum, pAlimonyDebtKey-DocKey ],
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
                pCalcTransf-_, pEmplKey-EmplKey,
                pTransfCharge-ChargeSum, pAlimonyKey-DocKey ],
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
