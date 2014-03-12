-module(interrupt).
-export([producer/3, front/2, consumer/0]).

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

consumer() ->
    receive
        inconsistency -> io:format("~p~n", [inconsistency]);
        V -> io:format("Consume ~p~n", [V])
    end,
    consumer().
