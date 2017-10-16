module Tree.Traverse exposing (hasMatchingNode, purge, update)

import Tree.Core exposing (Tree(Node))


type alias DataUpdater b =
    b -> b


type alias DataEvaluator b =
    b -> Bool


update : DataUpdater b -> Tree a b -> Tree a b
update updater (Node node data children) =
    let
        updatedData =
            updater data
    in
    Node node updatedData (List.map (update updater) children)


purge : DataEvaluator b -> Tree a b -> Tree a b
purge evaluator (Node node data children) =
    purgeNodes evaluator children
        |> List.map (purge evaluator)
        |> Node node data


purgeNodes : DataEvaluator b -> List (Tree a b) -> List (Tree a b)
purgeNodes evaluator nodeList =
    List.filter
        (\(Node _ data _) -> evaluator data)
        nodeList


hasMatchingNode : DataEvaluator b -> Tree a b -> Bool
hasMatchingNode evaluator (Node _ data children) =
    if evaluator data then
        True
    else
        List.foldl
            (||)
            False
            (List.map (hasMatchingNode evaluator) children)
