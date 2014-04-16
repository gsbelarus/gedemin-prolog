% params

%:- ensure_loaded(lib).
/* member_list */

:-
    dynamic(param_list/3),
    multifile(param_list/3),
    discontiguous(param_list/3).

% param_list(?Scope, ?Type, ?Pairs)
%   Scope - name of context
%   Type  - protocol support
%       Client: in; data; got; restart; test; ...
%       Server: run; query; temp; log; out; clean; error; ...
%   Pairs - list of pairs Key-Value or mixed with other

% new_param_list(+Scope, +Type, +Pairs)
new_param_list(Scope, Type, Pairs) :-
    \+ param_list(Scope, Type, Pairs),
    assertz( param_list(Scope, Type, Pairs) ),
    !.
new_param_list(_, _, _) :-
    !.

% dispose_param_list(?Scope, ?Type, ?Pairs)
dispose_param_list(Scope, Type, Pairs) :-
    retractall( param_list(Scope, Type, Pairs) ),
    !.

% get_param(?Scope, ?Type, ?Param)
get_param(Scope, Type, Param) :-
    param_list(Scope, Type, Pairs),
    memberchk(Param, Pairs).
% get_param(?Scope, ?Type, ?Param, ?Pairs)
get_param(Scope, Type, Param, Pairs) :-
    param_list(Scope, Type, Pairs),
    memberchk(Param, Pairs).
    
% get_param_list(?Scope, ?Type, ?Params)
get_param_list(Scope, Type, Params) :-
    param_list(Scope, Type, Pairs),
    member_list(Params, Pairs).
% get_param_list(?Scope, ?Type, ?Params, ?Pairs)
get_param_list(Scope, Type, Params, Pairs) :-
    param_list(Scope, Type, Pairs),
    member_list(Params, Pairs).

%
get_scope(Scope) :-
    setof(Scope, Type^Pairs^param_list(Scope, Type, Pairs), ScopeList),
    member(Scope, ScopeList).

%
get_scope_list(ScopeList) :-
    setof(Scope, Type^Pairs^param_list(Scope, Type, Pairs), ScopeList),
    !.

%
get_type(Type) :-
    setof(Type, Scope^Pairs^param_list(Scope, Type, Pairs), TypeList),
    member(Type, TypeList).

%
get_type_list(TypeList) :-
    setof(Type, Scope^Pairs^param_list(Scope, Type, Pairs), TypeList),
    !.

%
get_scope_type(Scope-Type) :-
    setof(Scope-Type, Pairs^param_list(Scope, Type, Pairs), ScopeTypeList),
    member(Scope-Type, ScopeTypeList).

%
get_scope_type_list(ScopeTypeList) :-
    setof(Scope-Type, Pairs^param_list(Scope, Type, Pairs), ScopeTypeList),
    !.

%
