% xo_game
% игра крестики-нолики
%

%:- module( xo, [] ).

:- dynamic([ xo_params/1, xo_cell/2, xo_solve/2, xo_step/4, xo_step_back/4 ]).

%:- ['kb/xo_cell', 'kb/xo_solve'].

% параметры игры
% xo_params([Size, Line, Level, Go, ModeOpt])
%   Size = size(PosBegin, PosEnd) - размер игрового поля
%   Line = line(WinLength) - длина линии выигрыша
%   Level = level(Level) - уровень игры
%   Go = go(CompMark, UserMark) - отметки хода
%   ModeOpt - опции режима
xo_params( [
    size(0, 19),
    line(5),
    level(4),
    go(x, o),
    mode_opt([level(echo, +5)])
] ).

% пространство ячеек
% xo_cell(Coor, Mark)
%   Coor = X-Y
%   Mark = {x ; o ; n}

% пространство решений
% xo_solve(Solve, State/HasChanceMark)
%   Solve = [ cell(Coor, Mark) | _ ]
%   Coor = X-Y
%   Mark = {x ; o ; n}
%   State = [x-Qty1, o-Qty2, n-Qty3]
%   HasChanceMark

% пространство движений для поиска решения
% xo_solve_moves(SolveMoves)
%   SolveMoves = [ move(DeltaX, DeltaY) | _ ]
xo_solve_moves([move(1, 0), move(-1, 0)]).    % горизонталь
xo_solve_moves([move(0, 1), move(0, -1)]).    % вертикаль
xo_solve_moves([move(1, 1), move(-1, -1)]).   % диагональ1
xo_solve_moves([move(1, -1), move(-1, 1)]).   % диагональ2

% формирование пространства ячеек
% xo_make_cell
xo_make_cell :-
    retractall( xo_cell(_, _) ),
    xo_params(Params),
    memberchk(size(PosBegin, PosEnd), Params),
    between(PosBegin, PosEnd, X),
    between(PosBegin, PosEnd, Y),
    assertz( xo_cell(X-Y, n) ),
    fail.
xo_make_cell :-
    once( xo_cell(_, _) ).

% формирование пространства решений
% xo_make_solve
xo_make_solve :-
    retractall( xo_solve(_, _) ),
    xo_params(Params),
    memberchk(size(PosBegin, PosEnd), Params),
    memberchk(line(WinLength), Params),
    Coor = X-Y,
    xo_cell(Coor, _),
    once( ( \+ WinLength =:= (PosEnd - PosBegin) + 1
          ; ( X = PosBegin ; Y = PosBegin )
          )
        ),
    xo_solve_moves(Moves),
    xo_cell_solve(Moves, Coor, Coor, WinLength, [cell(Coor, n)], Solve),
    \+ xo_solve(Solve, _),
    State = [x-0, o-0, n-WinLength],
    assertz( xo_solve(Solve, State/_) ),
    fail.
xo_make_solve :-
    once( xo_solve(_, _) ).

% шаблон решения по ячейке
% xo_cell_solve(Moves, BeginCoor, CurrentCoor, WinLength, Solve0, Solve)
xo_cell_solve(_, _, _, WinLength, Solve, SortedSolve) :-
    length(Solve, WinLength),
    sort(Solve, SortedSolve),
    !.
xo_cell_solve([Move | Moves], BeginCoor, X-Y, WinLength, Solve0, Solve) :-
    Move = move(DeltaX, DeltaY),
    plus(X, DeltaX, X1),
    plus(Y, DeltaY, Y1),
    xo_cell(X1-Y1, _),
    Solve1 = [cell(X1-Y1, n) | Solve0],
    !,
    xo_cell_solve([Move | Moves], BeginCoor, X1-Y1, WinLength, Solve1, Solve).
xo_cell_solve([_ | Moves], BeginCoor, _, WinLength, Solve0, Solve) :-
    !,
    xo_cell_solve(Moves, BeginCoor, BeginCoor, WinLength, Solve0, Solve).

% выигрыш
% xo_win(Mode, Mark, X, Y)
xo_win(Mode, Mark, X, Y) :-
    xo_win(Mode, Mark, Solve),
    member(cell(X-Y, _), Solve).
% xo_win(Mode, Mark, Solve)
xo_win(Mode, Mark, Solve) :-
    xo_params(Params),
    memberchk(line(WinLength), Params),
    memberchk(go(CompMark, UserMark), Params),
    member(Mode-Mark, [normal-CompMark, echo-UserMark]),
    xo_solve(Solve, State/Mark),
    memberchk(Mark-WinLength, State),
    !.

% ничья
% xo_tie(Mode)
xo_tie(Mode) :-
    xo_params(Params),
    memberchk(level(Level), Params),
    memberchk(mode_opt(ModeOpt), Params),
    xo_mode_level(Mode, ModeOpt, Level, ModeLevel),
    ModeLevel >= 3,
    memberchk(go(CompMark, UserMark), Params),
    once( xo_solve(_, _) ),
    \+ xo_has_chance(CompMark, _, _),
    \+ xo_has_chance(UserMark, _, _),
    !.
xo_tie(_) :-
    once( xo_cell(_, _) ),
    \+ xo_cell(_, n),
    !.

% xo_mode_level(Mode, ModeOpt, Level, ModeLevel)
xo_mode_level(Mode, ModeOpt, Level, ModeLevel) :-
    Mode = echo,
    memberchk(level(Mode, Diff), ModeOpt),
    plus(Level, Diff, ModeLevel),
    !.
xo_mode_level(_, _, Level, Level).

% есть шанс для выигрыша
% xo_has_chance(Mark, Solve, MarkedQty)
xo_has_chance(Mark, Solve, MarkedQty) :-
    xo_solve(Solve, State/Mark),
    memberchk(Mark-MarkedQty, State),
    true.
xo_has_chance(Mark, Solve, MarkedQty) :-
    fail, % disabled
    xo_params(Params),
    memberchk(line(WinLength), Params),
    xo_solve(Solve, State/_),
    memberchk(n-FreeQty, State),
    memberchk(Mark-MarkedQty, State),
    ( WinLength = FreeQty
     -> true
    ; plus(FreeQty, MarkedQty, WinLength)
    ).

% xo_mode_go(Mode, Go, ModeGo)
xo_mode_go(echo, go(Mark1, Mark2), go(Mark2, Mark1)) :-
    !.
xo_mode_go(normal, Go, Go).

% игра
% xo_play(Mode, X, Y, Rule)
xo_play(Mode, X, Y, Rule) :-
    Cell = cell(X-Y, n),
    xo_play(Mode, Cell, Rule),
    !.
% xo_play(Mode, PlayCell, Rule)
% первый ход - случайный выбор из лучших позиций
xo_play(Mode, PlayCell, Rule) :-
    xo_params(Params),
    memberchk(level(Level), Params),
    memberchk(mode_opt(ModeOpt), Params),
    xo_mode_level(Mode, ModeOpt, Level, ModeLevel),
    ModeLevel >= 3,
    \+ xo_cell(_, x),
    \+ xo_cell(_, o),
    %check_point,
    memberchk(line(WinLength), Params),
    Method = 0,
    findall( Method-rate(Gift, Count) / Coor,
             ( xo_cell(Coor, n),
               findall( WinLength-1,
                        ( xo_solve(Solve, _),
                          %xo_solve(Solve, State/_),
                          memberchk(cell(Coor, n), Solve)%,
                          %memberchk(n-FreeQty, State)
                        ),
                        FreeQtyList
               ),
               sum_int_pairs(FreeQtyList, Gift-Count)
             ),
             RateCoorList
    ),
    \+ RateCoorList = [],
    sort(RateCoorList, SortedRateCoorList),
    reverse(SortedRateCoorList, PlayCoorList),
    length(PlayCoorList, PlayLen),
    catch( PlayBest is PlayLen // 2 ** (ModeLevel - 2), _, PlayBest = 1 ),
    catch( PlayIndex is random(PlayBest), _, PlayIndex = 0 ),
    nth0(PlayIndex, PlayCoorList, Method-Rate / _),
    findall( Coor,
             member(Method-Rate / Coor, PlayCoorList),
             PlayRateCoorList
    ),
    length(PlayRateCoorList, PlayRateLen),
    PlayRateIndex is random(PlayRateLen),
    nth0(PlayRateIndex, PlayRateCoorList, PlayCoor),
    PlayCell = cell(PlayCoor, n),
    Rule = rule(random_best,method=Method,length=PlayLen/PlayRateLen,index=PlayIndex/PlayRateIndex),
    !.
% первый ход - случайный выбор
xo_play(_, PlayCell, Rule) :-
    \+ xo_cell(_, x),
    \+ xo_cell(_, o),
    xo_random_free_cell(PlayCell, Rule),
    !.
% выигрыш следующим ходом
xo_play(Mode, PlayCell, Rule) :-
    xo_params(Params),
    memberchk(level(Level), Params),
    memberchk(mode_opt(ModeOpt), Params),
    xo_mode_level(Mode, ModeOpt, Level, ModeLevel),
    ModeLevel >= 1,
    memberchk(go(Mark1, Mark2), Params),
    xo_mode_go(Mode, go(Mark1, Mark2), go(CompMark, UserMark)),
    memberchk(line(WinLength), Params),
    plus(WinLength, -1, ToWinLength),
    %
    ( Mark = CompMark ; Mark = UserMark ),
    xo_has_chance(Mark, Solve, ToWinLength),
    %
    PlayCell = cell(X-Y, n),
    memberchk(PlayCell, Solve),
    Rule = rule(next_step_win,Mark,X,Y),
    !.
% свободные края (выигрыш через ход)
xo_play(Mode, PlayCell, Rule) :-
    xo_params(Params),
    memberchk(level(Level), Params),
    memberchk(mode_opt(ModeOpt), Params),
    xo_mode_level(Mode, ModeOpt, Level, ModeLevel),
    ModeLevel >= 5,
    memberchk(go(Mark1, Mark2), Params),
    xo_mode_go(Mode, go(Mark1, Mark2), go(CompMark, UserMark)),
    memberchk(line(WinLength), Params),
    plus(WinLength, -2, ToWinLength),
    ( Mark = CompMark ; Mark = UserMark ),
    xo_has_chance(Mark, Solve, ToWinLength),
    Solve = [First | Right],
    append(Left, [Last], Solve),
    %check_point
    ( % n nooon n
      First = cell(_, n),
      Last = cell(_, n),
      xo_has_chance(Mark, SolveBorder1, ToWinLength),
      append(Right, [cell(_, n)], SolveBorder1),
      xo_has_chance(Mark, SolveBorder2, ToWinLength),
      append([cell(_, n)], Left, SolveBorder2),
      PlayList = [First, Last]
    ; % _ nonoo n | _ nnooo n
      xo_has_chance(Mark, SolveBorder1, ToWinLength),
      append(Right, [cell(_, n)], SolveBorder1),
      PlayCell = cell(_, n),
      memberchk(PlayCell, Right),
      PlayList = [PlayCell]
    ; % n oonon _ | n ooonn _
      xo_has_chance(Mark, SolveBorder2, ToWinLength),
      append([cell(_, n)], Left, SolveBorder2),
      PlayCell = cell(_, n),
      memberchk(PlayCell, Left),
      PlayList = [PlayCell]
    ),
    %check_point,
    length(PlayList, PlayLength),
    PlayIndex is random(PlayLength),
    nth0(PlayIndex, PlayList, PlayCell),
    PlayCell = cell(X-Y, n),
    Rule = rule(free_border,Mark,X,Y),
    !.
% тире (выигрыш через ход)
xo_play(Mode, PlayCell, Rule) :-
    xo_params(Params),
    memberchk(level(Level), Params),
    memberchk(mode_opt(ModeOpt), Params),
    xo_mode_level(Mode, ModeOpt, Level, ModeLevel),
    ModeLevel >= 6,
    memberchk(go(Mark1, Mark2), Params),
    xo_mode_go(Mode, go(Mark1, Mark2), go(CompMark, UserMark)),
    memberchk(line(WinLength), Params),
    plus(WinLength, -2, ToWinCut2),
    plus(WinLength, -3, ToWinCut3),
    ( Mark = CompMark ; Mark = UserMark ),
    xo_has_chance(Mark, Solve, ToWinCut3),
    Solve = [First | Right],
    append(Left, [Last], Solve),
    %check_point,
    ( % o nonon o
      First = cell(_, n),
      Last = cell(_, n),
      xo_has_chance(Mark, SolveBorder1, ToWinCut2),
      append(Right, [cell(_, Mark)], SolveBorder1),
      xo_has_chance(Mark, SolveBorder2, ToWinCut2),
      append([cell(_, Mark)], Left, SolveBorder2),
      Left = [First | Middle],
      PlayCell = cell(_, n),
      memberchk(PlayCell, Middle),
      PlayList = [PlayCell]
    ),
    %check_point,
    length(PlayList, PlayLength),
    PlayIndex is random(PlayLength),
    nth0(PlayIndex, PlayList, PlayCell),
    PlayCell = cell(X-Y, n),
    Rule = rule(dash_mark,Mark,X,Y),
    !.
% вилка
xo_play(Mode, PlayCell, Rule) :-
    xo_params(Params),
    memberchk(level(Level), Params),
    memberchk(mode_opt(ModeOpt), Params),
    xo_mode_level(Mode, ModeOpt, Level, ModeLevel),
    ModeLevel >= 7,
    memberchk(go(Mark1, Mark2), Params),
    xo_mode_go(Mode, go(Mark1, Mark2), go(CompMark, UserMark)),
    memberchk(line(WinLength), Params),
    plus(WinLength, -2, ToWinLength1),
    plus(WinLength, -3, ToWinLength2),
    MarkedQtyList = [ToWinLength1, ToWinLength2],
    OrderMarkList = [1-CompMark, 0-UserMark],
    %check_point,
    findall( MarkedQty-Order-Mark-Solve,
             ( member(MarkedQty, MarkedQtyList),
               member(Order-Mark, OrderMarkList),
               xo_has_chance(Mark, Solve, MarkedQty)
             ),
             MarkedSolveList
    ),
    \+ MarkedSolveList = [],
    sort(MarkedSolveList, SortedSolveList),
    reverse(SortedSolveList, ClaimForkList),
    %check_point,
    findall( Extra-Fork,
             ( xo_has_fork(ClaimForkList, Fork),
               xo_fork_extra(ModeLevel, Mark1, WinLength, Fork, Extra)
             ),
             ForkList
    ),
    \+ ForkList = [],
    sort(ForkList, SortedForkList),
    reverse(SortedForkList, [BestFork | TeilForkList]),
    BestFork = ForkExtra-fork(ForkHeight, ForkPower, ForkWidth, ForkOrder, _, _),
    PlayFork = ForkExtra-fork(ForkHeight, ForkPower, ForkWidth, ForkOrder, _, _),
    %check_point,
    findall( PlayFork,
             member(PlayFork, [BestFork | TeilForkList]),
             PlayForkList
    ),
    length(PlayForkList, PlayLength),
    PlayIndex is random(PlayLength),
    nth0(PlayIndex, PlayForkList, PlayFork),
    %check_point,
    PlayCell = cell(X-Y, n),
    PlayFork = Extra-fork(Height, Power, Width, Order, Mark, PlayCell),
    Rule = rule(fork,extra=Extra,height=Height,power=Power,width=Width,order=Order,Mark,X,Y),
    !.
% случайный выбор из лучших шансов на выигрыш
xo_play(Mode, PlayCell, Rule) :-
    xo_params(Params),
    memberchk(level(Level), Params),
    memberchk(mode_opt(ModeOpt), Params),
    xo_mode_level(Mode, ModeOpt, Level, ModeLevel),
    ModeLevel >= 3,
    memberchk(go(Mark1, Mark2), Params),
    xo_mode_go(Mode, go(Mark1, Mark2), go(CompMark, UserMark)),
    memberchk(line(WinLength), Params),
    xo_limit_coor(WinLength, LimitData),
    member(Cost, [2, 1, 0]),
    %check_point,
    RateShape = [TotalGift, TotalCount, CompGift, UserGift, CompCount, UserCount],
    xo_rate_shape(RateShape, Method-Rate),
    findall( Method-Rate / Coor,
             ( xo_cell(Coor, n),
               xo_check_coor(Coor, LimitData),
               xo_rate(CompMark, Coor, Cost, CompGift-CompCount),
               xo_rate(UserMark, Coor, Cost, UserGift-UserCount),
               plus(CompCount, UserCount, TotalCount),
               TotalCount > 0,
               plus(CompGift, UserGift, TotalGift)
             ),
             RateCoorList
    ),
    \+ RateCoorList = [],
    sort(RateCoorList, SortedRateCoorList),
    reverse(SortedRateCoorList, PlayCoorList),
    length(PlayCoorList, PlayLen),
    catch( PlayBest is PlayLen // 2 ** (ModeLevel - 2), _, PlayBest = 1 ),
    catch( PlayIndex is random(PlayBest), _, PlayIndex = 0 ),
    nth0(PlayIndex, PlayCoorList, Method-Rate / _),
    findall( Coor,
             member(Method-Rate / Coor, PlayCoorList),
             PlayRateCoorList
    ),
    length(PlayRateCoorList, PlayRateLen),
    PlayRateIndex is random(PlayRateLen),
    nth0(PlayRateIndex, PlayRateCoorList, PlayCoor),
    PlayCell = cell(PlayCoor, n),
    Rule = rule(random_best,method=Method,cost=Cost,length=PlayLen/PlayRateLen,index=PlayIndex/PlayRateIndex),
    !.
% случайный выбор из шансов на выигрыш
xo_play(Mode, PlayCell, Rule) :-
    xo_params(Params),
    memberchk(level(Level), Params),
    memberchk(mode_opt(ModeOpt), Params),
    xo_mode_level(Mode, ModeOpt, Level, ModeLevel),
    ModeLevel >= 2,
    memberchk(go(Mark1, Mark2), Params),
    xo_mode_go(Mode, go(Mark1, Mark2), go(CompMark, UserMark)),
    memberchk(line(WinLength), Params),
    xo_limit_coor(WinLength, LimitData),
    member(Cost, [1, 0]),
    ( Mark = CompMark ;  Mark = UserMark ),
    findall( Coor,
             ( xo_cell(Coor, n),
               xo_check_coor(Coor, LimitData),
               xo_rate(Mark, Coor, Cost, _-Count),
               \+ Count = 0
             ),
             FreeCoorList
    ),
    \+ FreeCoorList = [],
    length(FreeCoorList, Len),
    Index is random(Len),
    nth0(Index, FreeCoorList, Coor),
    PlayCell = cell(Coor, n),
    Rule = rule(random_chance,cost=Cost,length=Len,index=Index),
    !.
% случайный выбор свободной ячейки
xo_play(_, PlayCell, Rule) :-
    xo_random_free_cell(PlayCell, Rule).

% xo_fork_extra(ModeLevel, NormalMark, WinLength, Fork, Extra)
xo_fork_extra(ModeLevel, NormalMark, WinLength, Fork, Extra) :-
    ModeLevel >= 8,
    plus(WinLength, -2, ToWinCut2),
    plus(WinLength, -3, ToWinCut3),
    %
    Cell = cell(X-Y, n),
    Fork = fork(_, _, _, _, Mark, Cell),
    ( Mark = NormalMark -> ForkMode = normal ; ForkMode = echo ),
    xo_mark_cell(ForkMode, X, Y),
    %
    findall( Solve,
             ( xo_has_chance(Mark, Solve, ToWinCut2),
               memberchk(cell(X-Y, Mark), Solve),
               %
               Solve = [First | Right],
               append(Left, [Last], Solve),
               ( % n nooon n
                 First = cell(_, n),
                 Last = cell(_, n),
                 xo_has_chance(Mark, SolveBorder1, ToWinCut2),
                 append(Right, [cell(_, n)], SolveBorder1),
                 xo_has_chance(Mark, SolveBorder2, ToWinCut2),
                 append([cell(_, n)], Left, SolveBorder2)
                -> true
               ; % _ nonoo n | _ nnooo n
                 xo_has_chance(Mark, SolveBorder1, ToWinCut2),
                 append(Right, [cell(_, n)], SolveBorder1),
                 member(PlayCell, Right),
                 PlayCell = cell(_, n)
                -> true
               ; % n oonon _ | n ooonn _
                 xo_has_chance(Mark, SolveBorder2, ToWinCut2),
                 append([cell(_, n)], Left, SolveBorder2),
                 member(PlayCell, Left),
                 PlayCell = cell(_, n)
               )
             ; xo_has_chance(Mark, Solve, ToWinCut3),
               memberchk(cell(X-Y, Mark), Solve),
               %
               Solve = [First | Right],
               append(Left, [Last], Solve),
               ( % o nonon o
                 First = cell(_, n),
                 Last = cell(_, n),
                 xo_has_chance(Mark, SolveBorder1, ToWinCut2),
                 append(Right, [cell(_, Mark)], SolveBorder1),
                 xo_has_chance(Mark, SolveBorder2, ToWinCut2),
                 append([cell(_, Mark)], Left, SolveBorder2),
                 Left = [First | Middle],
                 PlayCell = cell(_, n),
                 memberchk(PlayCell, Middle)
               )
             ),
             SolveList
           ),
    length(SolveList, Extra),
    %
    xo_unmark_cell(X, Y),
    !.
xo_fork_extra(_, _, _, _, 0).

% xo_limit_coor(WinLength, LimitData)
xo_limit_coor(WinLength, LimitData) :-
    LimitData = [MinX, MaxX, MinY, MaxY],
    findall( X, ( xo_cell(X-_, Mark), \+ Mark = n ), XList ),
    findall( Y, ( xo_cell(_-Y, Mark), \+ Mark = n ), YList ),
    min_list(XList, MinX0),
    max_list(XList, MaxX0),
    min_list(YList, MinY0),
    max_list(YList, MaxY0),
    WinLength1 is -WinLength,
    plus(MinX0, WinLength1, MinX),
    plus(MaxX0, WinLength, MaxX),
    plus(MinY0, WinLength1, MinY),
    plus(MaxY0, WinLength, MaxY),
    !.

% xo_check_coor(Coor, LimitData)
xo_check_coor(Coor, LimitData) :-
    Coor = X-Y,
    LimitData = [MinX, MaxX, MinY, MaxY],
    X >= MinX, X =< MaxX,
    Y >= MinY, Y =< MaxY,
    !.

% xo_random_free_cell(PlayCell, Rule)
xo_random_free_cell(PlayCell, Rule) :-
    findall( Coor,
             xo_cell(Coor, n),
             FreeCoorList
    ),
    \+ FreeCoorList = [],
    length(FreeCoorList, Len),
    Index is random(Len),
    nth0(Index, FreeCoorList, Coor),
    PlayCell = cell(Coor, n),
    Rule = rule(random_free_cell,length=Len,index=Index),
    !.

% шаблон ранга
% xo_rate_shape(RateShape, MethodRate)
xo_rate_shape(RateShape, MethodRate) :-
    RateShape = [TotalGift, TotalCount, CompGift, UserGift, CompCount, UserCount],
    List = [
        1-rate(TotalGift, TotalCount, CompGift, UserGift, CompCount, UserCount),
        2-rate(TotalGift, TotalCount, UserGift, CompGift, UserCount, CompCount),
        3-rate(TotalCount, TotalGift, CompCount, UserCount, CompGift, UserGift),
        4-rate(TotalCount, TotalGift, UserCount, CompCount, UserGift, CompGift),
        5-rate(TotalGift, TotalCount, CompCount, UserCount, CompGift, UserGift),
        6-rate(TotalGift, TotalCount, UserCount, CompCount, UserGift, CompGift),
        7-rate(TotalCount, TotalGift, CompGift, UserGift, CompCount, UserCount),
        8-rate(TotalCount, TotalGift, UserGift, CompGift, UserCount, CompCount),
        -
    ],
    length(List, Len),
    Index is random(Len - 1),
    nth0(Index, List, MethodRate),
    !.

% ранг ячейки
% xo_rate(Mark, X, Y, Cost, Gift, Count)
xo_rate(Mark, X, Y, Cost, Gift, Count) :-
    xo_rate(Mark, X-Y, Cost, Gift-Count).
% xo_rate(Mark, Coor, Cost, Rate)
xo_rate(Mark, Coor, Cost, Gift-Count) :-
    findall( MarkedQty-1,
             ( xo_has_chance(Mark, Solve, MarkedQty),
               MarkedQty >= Cost,
               memberchk(cell(Coor, n), Solve)
             ),
             MarkedQtyList
    ),
    sum_int_pairs(MarkedQtyList, Gift-Count),
    !.

% есть вилка
% xo_has_fork(MarkedSolveList, Fork)
xo_has_fork([MarkedQty-Order-Mark-Solve | TeilSolves], Fork) :-
    Fork = fork(ForkHeight, ForkPower, ForkWidth, ForkOrder, Mark, FreeCell),
    FreeCell = cell(_, n),
    %check_point,
    member(FreeCell, Solve),
    member(ClaimOrder, [1, 0]),
    findall( ForkMarkedQty,
             ( member(ForkMarkedQty-ClaimOrder-_-ForkSolve, TeilSolves),
               select(FreeCell, ForkSolve, ForkSolveRest),
               \+ ( member(ForkCell, ForkSolveRest),
                    memberchk(ForkCell, Solve)
                  )
             ),
             ForkMarkedQtyList
    ),
    \+ ForkMarkedQtyList = [],
    %check_point,
    max_list([MarkedQty | ForkMarkedQtyList], MaxMarkedQty),
    succ(MaxMarkedQty, ForkHeight),
    sum_list([MarkedQty | ForkMarkedQtyList], ForkPower),
    length([MarkedQty | ForkMarkedQtyList], ForkWidth),
    memberchk(Order-ClaimOrder-ForkOrder, [1-1-4, 0-0-3, 1-0-2, 0-1-1]).
xo_has_fork([_ | TeilSolves], Fork) :-
    xo_has_fork(TeilSolves, Fork).
    
% оценка ситуации
% xo_review(Mark, X, Y, Cost, OutMark, OutX, OutY)
xo_review(Mark, X, Y, Cost, OutMark, OutX, OutY) :-
    xo_has_chance(Mark, Solve, MarkedQty),
    MarkedQty >= Cost,
    selectchk(cell(X-Y, n), Solve, Review),
    member(cell(OutX-OutY, OutMark), Review).

% sum_int_pairs(Pairs, SumPairs)
sum_int_pairs(Pairs, SumPairs) :-
    sum_int_pairs(Pairs, 0-0, SumPairs),
    !.
% sum_int_pairs(Pairs, SumPairs0, SumPairs)
sum_int_pairs([], SumPairs, SumPairs).
sum_int_pairs([X1-X2|Xs], Sum01-Sum02, SumPairs) :-
    plus(Sum01, X1, Sum11),
    plus(Sum02, X2, Sum12),
    sum_int_pairs(Xs, Sum11-Sum12, SumPairs).

% отметка ячейки
% xo_mark_cell(Mode, X, Y)
xo_mark_cell(Mode, X, Y) :-
    Cell = cell(X-Y, n),
    xo_mark_cell(Mode, Cell),
    !.
% xo_mark_cell(Mode, Cell)
xo_mark_cell(Mode, Cell) :-
    xo_params(Params),
    memberchk(go(CompMark, UserMark), Params),
    memberchk(Mode-Mark, [normal-CompMark, echo-UserMark]),
    xo_solve(Solve, State),
    memberchk(Cell, Solve),
    xo_change_solve(Solve, Cell, Mark, ChangedSolve, State, ChangedState),
    retract( xo_solve(Solve, State) ),
    assertz( xo_solve(ChangedSolve, ChangedState) ),
    fail.
xo_mark_cell(Mode, Cell) :-
    xo_params(Params),
    memberchk(go(CompMark, UserMark), Params),
    memberchk(Mode-Mark, [normal-CompMark, echo-UserMark]),
    Cell = cell(X-Y, n),
    retract( xo_cell(X-Y, n) ),
    assertz( xo_cell(X-Y, Mark) ),
    ( xo_step(_, Step, _, _) -> true ; Step = 0 ),
    ( Mode = normal -> succ(Step, Step1) ; Step1 = Step ),
    asserta( xo_step(Mark, Step1, X, Y) ),
    !.

% очистка ячейки
% xo_unmark_cell(X, Y)
xo_unmark_cell(X, Y) :-
    Cell = cell(X-Y, _),
    xo_solve(Solve, State),
    memberchk(Cell, Solve),
    xo_change_solve(Solve, Cell, n, ChangedSolve, State, ChangedState),
    retract( xo_solve(Solve, State) ),
    assertz( xo_solve(ChangedSolve, ChangedState) ),
    fail.
xo_unmark_cell(X, Y) :-
    retract( xo_cell(X-Y, _) ),
    assertz( xo_cell(X-Y, n) ),
    xo_step(Mark, Step, X, Y),
    retract( xo_step(Mark, Step, X, Y) ),
    !.

xo_back :-
    retract( xo_step(Mark, Step, X, Y) ),
    xo_unmark_cell(X, Y),
    asserta( xo_step_back(Mark, Step, X, Y) ),
    !.

xo_forth :-
    retract( xo_step_back(Mark, _, X, Y) ),
    xo_params(Params),
    memberchk(go(CompMark, UserMark), Params),
    memberchk(Mode-Mark, [normal-CompMark, echo-UserMark]),
    xo_mark_cell(Mode, X, Y),
    !.

% смена состояния для решения
% xo_change_solve(Solve, State, Cell, Mark, ChangedSolve, ChangedState)
xo_change_solve([Cell|TeilSolve], Cell, Mark, [ChangedCell|TeilSolve], State0, ChangedState) :-
    Cell = cell(X-Y, OldMark),
    ChangedCell = cell(X-Y, Mark),
    State0 = State/_,
    select(Mark-MarkedQty, State, State1),
    select(OldMark-OldMarkQty, State1, State2),
    succ(MarkedQty, MarkedQty1),
    plus(OldMarkQty, -1, OldMarkQty1),
    append(State2, [Mark-MarkedQty1, OldMark-OldMarkQty1], ChangedState0),
    xo_change_chance(ChangedState0, ChangedState),
    !.
xo_change_solve([SafeCell|TeilSolve], Cell, Mark, [SafeCell|RestSolve], State, ChangedState) :-
    !,
    xo_change_solve(TeilSolve, Cell, Mark, RestSolve, State, ChangedState).

% xo_change_chance(State, State/HasChanceMark)
xo_change_chance(State, State/HasChanceMark) :-
    xo_params(Params),
    memberchk(go(CompMark, UserMark), Params),
    ( memberchk(CompMark-0, State),
      memberchk(UserMark-0, State)
    ; memberchk(CompMark-CompMarkedQty, State),
      memberchk(UserMark-0, State),
      CompMarkedQty > 0,
      HasChanceMark = CompMark
    ; memberchk(UserMark-UserMarkedQty, State),
      memberchk(CompMark-0, State),
      UserMarkedQty > 0,
      HasChanceMark = UserMark
    ; HasChanceMark = n
    ),
    !.

% взять параметры игры
% xo_get_params(PosBegin, PosEnd, WinLength, Level, CompMark, UserMark)
xo_get_params(PosBegin, PosEnd, WinLength, Level, CompMark, UserMark) :-
    xo_params( [
        size(PosBegin, PosEnd),
        line(WinLength),
        level(Level),
        go(CompMark, UserMark),
        _
    ] ).

% установить параметры игры
% xo_get_params(PosBegin, PosEnd, WinLength, Level, CompMark, UserMark)
xo_set_params(PosBegin, PosEnd, WinLength, Level, CompMark, UserMark) :-
    retractall( xo_params(_) ),
    assertz(
        xo_params( [
            size(PosBegin, PosEnd),
            line(WinLength),
            level(Level),
            go(CompMark, UserMark),
            mode_opt([])
        ] )
    ).

% инициализация
% xo_init
xo_init :-
    xo_make_cell,
    xo_make_solve,
    retractall( xo_step(_, _, _, _) ),
    retractall( xo_step_back(_, _, _, _) ),
    !.

% тест
% xo_test
xo_test :-
    Count = 1,
    between(1, Count, Value),
    xo_test(Result, Solve),
    once( xo_step(Mark, Step, _, _) ),
    writeln(game_over(Value, Result, Mark, Step, Solve)),
    Value = Count,
    !.
% xo_test(Result, Solve)
xo_test(Result, Solve) :-
    xo_init,
    xo_params(Params),
    memberchk(go(CompMark, UserMark), Params),
    memberchk(size(PosBegin, PosEnd), Params),
    %retractall( xo_step(_, _, _, _) ),
    PlayCell = cell(X-Y, n),
    MaxStep is round( float_integer_part( (PosEnd - PosBegin + 1) ** 2 / 2 * sign(PosEnd - PosBegin + 1) ) ),
    between(1, MaxStep, _),
    member(Mode-Mark, [normal-CompMark, echo-UserMark]),
    ( xo_play_in(Mode-Mark, PlayCell, Rule)
     -> true
    ; time( xo_play(Mode, PlayCell, Rule) )
    ),
    xo_mark_cell(Mode, PlayCell),
    once( xo_step(Mark, Step, X, Y) ),
    writeln(step(Step, Mark, X, Y)-Rule),
    ( xo_win(Mode, Mark, Solve)
     ->
      Result = Mode
    ; xo_tie(Mode),
      Result = none,
      Solve = none
    ),
    !.

%
xo_play_in(Mode-Mark, cell(X-Y,_), input) :-
    fail,
    write(Mode-Mark),
    write(': '),
    read(In),
    In = X-Y.

%
check_point.
