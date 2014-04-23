% twg_fee_in_params

twg_fee_in_params:-
    new_param_list(wg_fee_alimony, in,
    [
    pRestPercent-0.3,
    pFeeGroupKey_ruid-'147732349,375143752',
    pDocType_ruid='147067079,453357870'
    pBudget_ruid-'147073065,1224850260',
    pStartDate-'2012-01-01',
    pBV_ruid-'147021364,256548741',
    pForAlimony_ruid-'147068435,453357870'
    ]),
    fail.
twg_fee_in_params:-
    member([ChildQtyCmp, PartByLaw, MinFromBuget],
        [['=1', 0.25, 0.5], ['=2', 0.33, 0.75], ['>=3', 0.5, 1.0]]),
    new_param_list(wg_fee_alimony, in,
        [pChildQtyCmp-ChildQtyCmp, pPartByLaw-PartByLaw, pMinFromBuget-MinFromBuget]),
    fail.
twg_fee_in_params.

:- twg_fee_in_params.

%
