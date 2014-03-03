-module(list_tests).
-include_lib("eunit/include/eunit.hrl").

empty_test() ->
    P = list:init(),
    ?assertEqual([], list:get(P)).

empty_one_var_test() ->
    {_, _, _, L} = list:init(),
    ?assertEqual([], list:get(L)).

add_one_ordered_set_test() ->
    P = list:init(),
    list:add([1, 2], P),
    timer:sleep(5),
    ?assertEqual([1, 2], list:get(P)).

add_one_unordered_set_test() ->
    P = list:init(),
    list:add([2, 1], P),
    timer:sleep(5),
    ?assertEqual([1, 2], list:get(P)).

add_two_sets_test() ->
    P = list:init(),
    list:add([5, 4], P),
    list:add([1, 8], P),
    timer:sleep(5),
    ?assertEqual([1, 4, 5, 8], list:get(P)).

add_three_sets_test() ->
    P = list:init(),
    list:add([9], P),
    list:add([5, 4], P),
    list:add([1, 8], P),
    timer:sleep(5),
    ?assertEqual([1, 4, 5, 8, 9], list:get(P)).
