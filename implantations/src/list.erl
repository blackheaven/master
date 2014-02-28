-module(list).
-export([merge_sort/1, merge_e_r/1, merge_sort_f/2]).

merge_f([], X) -> X;
merge_f(X, []) -> X;
merge_f([X|XS], [Y|YS]) ->
    case X > Y of
        true -> [Y | merge_f([X|XS], YS)];
        _ -> [X | merge_f(XS, [Y|YS])]
    end.

merge_e_r(MERGER) ->
    receive
        L -> merge_o_r(L, MERGER)
    end.

merge_o_r(L1, MERGER) ->
    receive
        L2 -> MERGER ! merge_f(L1, L2)
    end.

merge_sort(L) ->
    spawn(?MODULE, merge_sort_f, [L, self()]),
    receive
        R ->
            io:format("~p : ~p~n", ["Founded", R]),
            R
    end.

merge_sort_f([], SORTER) -> SORTER ! [];
merge_sort_f([X], SORTER) -> SORTER ! [X];
merge_sort_f([X, Y], SORTER) -> 
    SORTER ! case X > Y of
        true -> [Y, X];
        _ -> [X, Y]
    end;
merge_sort_f(L, SORTER) ->
    MERGER = spawn(?MODULE, merge_e_r, [self()]),
    {A, B} = lists:split(round(length(L)/2), L),
    merge_sort_f(A, MERGER),
    merge_sort_f(B, MERGER),
    receive
        R -> SORTER ! R
    end.
