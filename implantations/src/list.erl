-module(list).
-export([merge_sort/1, merge_e_r/1, merge_sort_f/2, create/0, list/0, create/1, raw/1, insert/2, val/2, map/2]).

create() -> spawn(?MODULE, list, []).

create(L) ->
    P = create(),
    lists:foreach(fun(E) -> insert(P, E) end, L),
    P.

id(V) -> V.

raw(L) -> map(L, fun id/1).

map(L, F) ->
    S = self(),
    L ! {foreach, fun(V) -> S !
        case V of
            nil -> nil;
            _ -> {F(V)}
        end
        end},
    acc_wait([]).

acc_wait(L) ->
    receive
        nil -> lists:reverse(L);
        {E} -> acc_wait([E|L])
    end.

list() ->
    receive
        {insert, V} ->
            E = spawn(?MODULE, val, [V, nil]),
            list(E, E, 1);
        {foreach, F} ->
            F(nil),
            list()
    end.

list(B, E, S) ->
    receive
        {insert, V} ->
            N = spawn(?MODULE, val, [V, nil]),
            E ! {set_next, N},
            list(B, N, S+1);
        {foreach, F} ->
            case S of
                0 -> F(nil);
                _ -> B ! {foreach, F}
            end,
            list(B, E, S)
    end.

insert(L, E) ->
    L ! {insert, E},
    L.

val(V, nil) ->
    receive
        {set_next, NN} -> val(V, NN);
        {foreach, F} ->
            F(V),
            F(nil);
        {value, Asker} ->
            Asker ! V,
            val(V, nil);
        {delete, Previous} -> Previous ! {set_next, nil};
        destroy -> ok
    end;
val(V, N) ->
    receive
        {set_next, NN} -> val(V, NN);
        {foreach, F} ->
            F(V),
            N ! {foreach, F},
            val(V, N);
        {value, Asker} ->
            Asker ! V,
            val(V, N);
        {delete, Previous} -> Previous ! {set_next, N};
        destroy -> ok
    end.

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
        R -> R
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
