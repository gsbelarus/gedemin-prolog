% Author:
% Date: 31.07.2013

%%
    % заработок за проверяемый месяц
    usr_wg_TotalLine(EmplKey, Y, M, Wage),
    % заработок по расчетным месяцам
    findall( Wage1,
        (
        % за расчетный месяц
        wg_month_incl(EmplKey, Y1, M1, Variant1),
        % по варианту полного месяца
        wg_full_month_rules(Rules),
        member(Variant1, Rules),
        % взять заработок
        usr_wg_TotalLine(EmplKey, Y1, M1, Wage1)
        ),
        % в список заработков
             Wages1 ),
    % максимальный заработок из расчетных месяцев
    max_member(MaxWage1, Wages1),
    % заработок за проверяемый покрывает максимальный
    Wage >= MaxWage1,

%%
    % заработок за проверяемый покрывает каждый из расчетных месяцев
    over_list(Wage, Wages1),