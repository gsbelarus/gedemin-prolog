% twg_fee

% расчет начислений/удержаний
% - алименты
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
:- ['../common/lib'].
%#INCLUDE params
:- ['../common/params'].
%%
%#INCLUDE twg_fee_sql
:- [twg_fee_sql].
%#INCLUDE twg_fee_in_params
:- [twg_fee_in_params].

%% facts
:-  init_data,
    [
    usr_wg_FeeType,
    usr_wg_alimony,
    usr_wg_FCRate,
    gd_const_budget,
    usr_wg_Variables
    ].
%%
%% dynamic state
%:- [param_list].
%%

%% flag
:- assertz(debug_mode).
%%

% ! при использовании в ТП Гедымин
% ! для begin & end debug mode section
% ! убрать символ процента из первой позиции
%*/ %%% end debug mode section

:- ps32k_lgt(64, 128, 64).

:- init_data.

/* реализация */




/**/
