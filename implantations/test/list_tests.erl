-module(list_tests).
-include_lib("eunit/include/eunit.hrl").

merge_sort_test() ->
    ?assertEqual([], list:merge_sort([])),
    ?assertEqual([0], list:merge_sort([0])),
    ?assertEqual([0, 1], list:merge_sort([1, 0])),
    ?assertEqual([0, 1, 3], list:merge_sort([1, 0, 3])),
    ?assertEqual([-10, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9], list:merge_sort([3, 8, 9, 0, 2, 4, 7, 5, 6, -10, 1]))
    .
