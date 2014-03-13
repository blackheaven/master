-module(multiflow).
-export([producer/3, front/3, consumer/0, condensator/1, run/0]).

producer(_, _, 0) -> ok;
producer(F, L, N) ->
    G = random:uniform(42),
    io:format("Produce ~p~n", [G]),
    F ! G,
    timer:sleep(L),
    producer(F, L, N - 1).

front(C, L, N) ->
    receive
        V ->
            case V < L of
                true ->
                    C ! {N + 1, V},
                    front(C, V, N + 1);
                _ ->
                    C ! {N, V},
                    front(C, V, N)
            end
    end.

condensator(C) ->
    receive
        flush ->
            flush(C),
            condensator(C)
    end.

flush(C) ->
    Start = discover_queues([], 0),
    vacuum_queues(C, Start).

discover_queues(O, L) ->
    R = get_next_queue(L),
    case R of
        {N, V} -> discover_queues([{N, V}|O], N + 1);
        _ -> O
    end.
 
get_next_queue(M) ->
    receive
        {N, V} when N >= M -> {N, V}
    after 0 ->
        eos
    end.

vacuum_queues(_, []) -> ok;
vacuum_queues(C, Q) ->
    Min = lists:min(lists:map(fun({_, E}) -> E end, Q)),
    Checked = lists:map(fun({L, E}) ->
                            case E == Min of
                                true ->
                                    C ! E,
                                    fetch_queue(L);
                                _ -> {L, E}
                            end
                        end, Q),
    vacuum_queues(C, lists:filter(fun(E) ->
                                    case E of
                                        {_, _} -> true;
                                        _ -> false
                                    end
                                  end, Checked)).
 
fetch_queue(N) ->
    receive
        {N, V} -> {N, V}
    after 0 ->
        eos
    end.

consumer() ->
    receive
        V -> io:format("Consume ~p~n", [V])
    end,
    consumer().

run() ->
    C = spawn(?MODULE, consumer, []),
    CD = spawn(?MODULE, condensator, [C]),
    F = spawn(?MODULE, front, [CD, 0, 1]),
    producer(F, 1, 10),
    CD ! flush,
    CD.
