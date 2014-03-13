-module(condensator).
-export([producer/3, front/2, consumer/0, condensator/2]).

producer(_, _, 0) -> ok;
producer(F, L, N) ->
    G = random:uniform(42),
    io:format("Produce ~p~n", [G]),
    F ! G,
    timer:sleep(L),
    producer(F, L, N - 1).

front(C, L) ->
    receive
        V ->
            case V < L of
                true -> C ! inconsistency;
                _ -> ok
            end,
            C ! V,
            front(C, V)
    end.

condensator(C, Acc) ->
    receive
        inconsistency -> condensator(C, [[]|Acc]);
        flush ->
            lists:foreach(fun(E) -> C ! E end, lists:reverse(multi_merge(Acc))),
            condensator(C, [[]]);
        V ->
            [H|T] = Acc,
            condensator(C, [[V|H]|T])
    end.

multi_merge([]) -> [];
multi_merge([H|T]) -> merge(H, multi_merge(T)).

merge([], X) -> X;
merge(X, []) -> X;
merge([X|XS], [Y|YS]) ->
    case X < Y of
        true -> [Y | merge([X|XS], YS)];
        _ -> [X | merge(XS, [Y|YS])]
    end.

consumer() ->
    receive
        V -> io:format("Consume ~p~n", [V])
    end,
    consumer().
