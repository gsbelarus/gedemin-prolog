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

/**/

:- module( dataset, [
            init_data_spec/0,
            clean_data_spec/0,
            init_data/0,
            clean_data/0,
            get_data/2,         % +Name, ?FieldValuePairs
            get_data/3,         % +Type, +Name, ?FieldValuePairs
            get_data/4          % +Scope, +Type, +Name, ?FieldValuePairs
            ]).

% first, call init_data_spec then assert spec facts gd_pl_ds
init_data_spec :-
    SpecFacts = [user:gd_pl_ds/5, user:gd_pl_ds/4, user:gd_pl_ds/3],
    dynamic(SpecFacts),
    multifile(SpecFacts),
    discontiguous(SpecFacts),
    !.

:- init_data_spec.

%
clean_data_spec :-
    SpecFacts = [user:gd_pl_ds/5, user:gd_pl_ds/4, user:gd_pl_ds/3],
    member(SpecFact, SpecFacts),
    abolish(SpecFact),
    fail.
clean_data_spec :-
    init_data_spec,
    !.

% second, call init_data then assert data facts
init_data :-
    get_data_spec(_, _, Name, Arity, _),
    dynamic(user:Name/Arity),
    multifile(user:Name/Arity),
    discontiguous(user:Name/Arity),
    fail.
init_data :-
    !.

%
clean_data :-
    get_data_spec(_, _, Name, Arity, _),
    abolish(user:Name/Arity),
    fail.
clean_data :-
    init_data,
    !.

%
get_data_spec(Scope, Type, Name, Arity, Pairs) :-
    user:gd_pl_ds(Scope, Type, Name, Arity, Pairs).
get_data_spec(global, Type, Name, Arity, Pairs) :-
    user:gd_pl_ds(Type, Name, Arity, Pairs).
get_data_spec(global, none, Name, Arity, Pairs) :-
    user:gd_pl_ds(Name, Arity, Pairs).

%
get_data(Name, FieldValuePairs) :-
    get_data(global, none, Name, FieldValuePairs).
get_data(Type, Name, FieldValuePairs) :-
    get_data(global, Type, Name, FieldValuePairs).
get_data(Scope, Type, Name, FieldValuePairs) :-
    ground(Scope), ground(Type), ground(Name),
    get_data_spec(Scope, Type, Name, Arity, FieldTypePairs),
    catch( length(FieldTypePairs, Arity), _, fail ),
    current_functor(Name, Arity),
    check_fields(FieldValuePairs, FieldTypePairs),
    prepare_args(FieldTypePairs, FieldArgPairs, Args),
    Term =.. [Name|Args],
    call( user:Term ),
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