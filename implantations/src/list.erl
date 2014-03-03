-module(list).
-export([merger/0, atomic_sort/0, accumulator/0, last/1, init/0, add/2, get/1]).

atomic_sort() ->
    receive
        {L, Accumulator, Merger, Last} ->
            Accumulator ! {lists:sort(L), Merger, Last},
            atomic_sort()
    end.

accumulator() ->
    receive
        {L, _, _} ->
            % io:format("~p : ~p~n", ["acc0", L]),
            accumulator(L)
    end.

accumulator(L1) ->
    receive
        {L2, Merger, Last} ->
            % io:format("~p : ~p~n", ["acc1", L2]),
            Merger ! {L1, L2, self(), Last},
            accumulator()
    end.

merger() ->
    receive
        {L1, L2, Accumulator, Last} ->
            L = merge(L1, L2),
            % io:format("~p : ~p~n", ["merge", L]),
            Accumulator ! {L, self(), Last},
            Last ! {set, L},
            merger()
    end.

merge([], X) -> X;
merge(X, []) -> X;
merge([X|XS], [Y|YS]) ->
    case X > Y of
        true -> [Y | merge([X|XS], YS)];
        _ -> [X | merge(XS, [Y|YS])]
    end.

last(C) ->
    receive
        {set, N} ->
            % io:format("~p : ~p~n", ["last", N]),
            last(N);
        {get, A} ->
            A ! C,
            last(C)
    end.

init() ->
    A = spawn(?MODULE, accumulator, []),
    A ! {[], nil, nil},
    S = spawn(?MODULE, atomic_sort, []),
    M = spawn(?MODULE, merger, []),
    L = spawn(?MODULE, last, [[]]),
    {S, A, M, L}.

add(List, {S, A, M, L}) ->
    S ! {List, A, M, L}
    .

get({_, _, _, L}) ->
    L ! {get, self()},
    receive
        R -> R
    end;
get(L) ->
    L ! {get, self()},
    receive
        R -> R
    end.

