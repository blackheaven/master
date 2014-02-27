-module(list).
-export([merge_sort/1]).

% merge_sort() -> odds(List,1).
% merge_sort([X|R],N) when N rem 2 == 1 -> [X | odds(R,N+1)];
% merge_sort([_|R],N) -> odds(R,N+1);
% merge_sort([],_) -> [].

merge([], X) -> X;
merge(X, []) -> X;
merge([X|XS], [Y|YS]) ->
    case X > Y of
        true -> [Y | merge([X|XS], YS)];
        _ -> [X | merge(XS, [Y|YS])]
    end.

merge_sort([]) -> [];
merge_sort([X]) -> [X];
merge_sort([X, Y]) -> 
    case X > Y of
        true -> [Y, X];
        _ -> [X, Y]
    end;
merge_sort(L) ->
    {A, B} = lists:split(round(length(L)/2), L),
    merge(merge_sort(A), merge_sort(B)).
