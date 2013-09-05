/* Gedemin-Prolog dataset specification */

%%
% gd_pl_ds/5 % complete
% gd_pl_ds(+Scope, +Type, +Name, +Arity, +Pairs)
%   Scope - name of context
%   Type  - protocol support
%           { in ; out ; ... }
%   Name  - functor name
%   Arity - arity
%   Pairs - args specification
%           list of pairs fldName-fldType
%
% gd_pl_ds/4 % means Scope = global
% gd_pl_ds(+Type, +Name, +Arity, +Pairs)
%
% gd_pl_ds/3 % means Scope = global, Type = none
% gd_pl_ds(+Name, +Arity, +Pairs)
%%

%
gd_pl_ds_init :-
    dynamic([gd_pl_ds/5, gd_pl_ds/4, gd_pl_ds/3]),
    forall( get_data_spec(_, _, Name, Arity, _),
            ( dynamic(Name/Arity),
              multifile(Name/Arity),
              discontiguous(Name/Arity)
            )
          ),
    !.

%
get_data_spec(Scope, Type, Name, Arity, Pairs) :-
    gd_pl_ds(Scope, Type, Name, Arity, Pairs).
get_data_spec(global, Type, Name, Arity, Pairs) :-
    gd_pl_ds(Type, Name, Arity, Pairs).
get_data_spec(global, none, Name, Arity, Pairs) :-
    gd_pl_ds(Name, Arity, Pairs).

%
get_data(Name, FieldValuePairs) :-
    get_data(global, none, Name, FieldValuePairs).
get_data(Type, Name, FieldValuePairs) :-
    get_data(global, Type, Name, FieldValuePairs).
get_data(Scope, Type, Name, FieldValuePairs) :-
    gd_pl_ds(Scope, Type, Name, Arity, FieldTypePairs),
    catch( length(FieldTypePairs, Arity), _, fail ),
    current_functor(Name, Arity),
    check_fields(FieldValuePairs, FieldTypePairs),
    prepare_args(FieldTypePairs, FieldArgPairs, Args),
    Term =.. [Name|Args],
    call( Term ),
    unify_args(FieldValuePairs, FieldArgPairs).

%
check_fields([], _) :-
    !.
check_fields([Field-_|FieldValuePairs], FieldTypePairs) :-
    member(Field-_, FieldTypePairs),
    !,
    check_fields(FieldValuePairs, FieldTypePairs).

%
prepare_args([],[],[]) :-
    !.
prepare_args([Field-_|TailPairs], [Field-Arg|RestPairs], [Arg|RestArgs]) :-
    !,
    prepare_args(TailPairs, RestPairs, RestArgs).

%
unify_args([], _) :-
    !.
unify_args([FieldValue|FieldValuePairs], FieldArgPairs) :-
    member(FieldValue, FieldArgPairs),
    !,
    unify_args(FieldValuePairs, FieldArgPairs).

%