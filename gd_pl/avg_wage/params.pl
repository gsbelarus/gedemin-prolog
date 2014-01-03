% params

%:- ensure_loaded(lib).
/* remove_list, member_list */

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
    ground([Scope, Type, Pairs]),
    ( \+ param_list(Scope, Type, Pairs),
      assertz( param_list(Scope, Type, Pairs) ) ; true ),
    !.

% dispose_param_list(?Scope, ?Type, ?Pairs)
dispose_param_list(Scope, Type, Pairs) :-
    retractall( param_list(Scope, Type, Pairs) ),
    !.

% get_param(?Scope, ?Type, ?Param)
get_param(Scope, Type, Param) :-
    param_list(Scope, Type, Pairs),
    once( member(Param, Pairs) ).
% get_param(?Scope, ?Type, ?Param, ?Pairs)
get_param(Scope, Type, Param, Pairs) :-
    param_list(Scope, Type, Pairs),
    once( member(Param, Pairs) ).
    
% get_param_list(?Scope, ?Type, ?Params)
get_param_list(Scope, Type, Params) :-
    param_list(Scope, Type, Pairs),
    once( member_list(Params, Pairs) ).
% get_param_list(?Scope, ?Type, ?Params, ?Pairs)
get_param_list(Scope, Type, Params, Pairs) :-
    param_list(Scope, Type, Pairs),
    once( member_list(Params, Pairs) ).
    
% find_param(+Scope, +Type, +Key1-Value1, ?Key2-Value2)
find_param(Scope, Type, Key1-Value1, Key2-Value2) :-
    find_param_list(Scope, Type, Key1-Value1, Pairs),
    once( member(Key2-Value2, Pairs) ).
% find_param(+Scope, +Type, +Pairs0, ?Key-Value)
find_param(Scope, Type, Pairs0, Key-Value) :-
    find_param_list(Scope, Type, Pairs0, Pairs),
    once( member(Key-Value, Pairs) ).

% find_param_list(+Scope, +Type, +Key-Value, ?Pairs)
find_param_list(Scope, Type, Key-Value, Pairs) :-
    ground([Scope, Type, Key-Value]),
    param_list(Scope, Type, Pairs0),
    once( member(Key-Value, Pairs0) ),
    remove_list(Key-Value, Pairs0, Pairs).
% find_param_list(+Scope, +Type, +Pairs0, ?Pairs)
find_param_list(Scope, Type, Pairs0, Pairs) :-
    ground([Scope, Type, Pairs0]),
    Pairs0 = [Key-Value|Tail],
    find_param_list(Scope, Type, Key-Value, Pairs1),
    once( member_list(Tail, Pairs1) ),
    remove_list(Tail, Pairs1, Pairs).
    
%
get_scope(Scope) :-
    findall(Scope0, param_list(Scope0, _, _), ScopeList0),
    sort(ScopeList0, ScopeList),
    member(Scope, ScopeList).

%
get_scope_list(ScopeList) :-
    findall(Scope0, param_list(Scope0, _, _), ScopeList0),
    sort(ScopeList0, ScopeList),
    !.

%
get_type(Type) :-
    findall(Type0, param_list(_, Type0, _), TypeList0),
    sort(TypeList0, TypeList),
    member(Type, TypeList).

%
get_type_list(TypeList) :-
    findall(Type0, param_list(_, Type0, _), TypeList0),
    sort(TypeList0, TypeList),
    !.

%
get_scope_type(Scope-Type) :-
    findall(Scope0-Type0, param_list(Scope0, Type0, _), ScopeTypeList0),
    sort(ScopeTypeList0, ScopeTypeList),
    member(Scope-Type, ScopeTypeList).

%
get_scope_type_list(ScopeTypeList) :-
    findall(Scope0-Type0, param_list(Scope0, Type0, _), ScopeTypeList0),
    sort(ScopeTypeList0, ScopeTypeList),
    !.

%
