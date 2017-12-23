module Tree.Core exposing (CollapsibleTree, NodeId, Tree(Node), getData, getId, make)

import State exposing (State)


type Tree a b
    = Node a b (List (Tree a b))


type alias NodeId =
    Int


type alias CollapsibleTree a b =
    Tree ( a, Bool, NodeId ) b


type alias IdGen a =
    State NodeId a


make : Tree a b -> CollapsibleTree a b
make tree =
    State.finalValue 0 (label tree)


getId : CollapsibleTree a b -> Int
getId (Node ( _, _, nodeId ) _ _) =
    nodeId


getData : CollapsibleTree a b -> b
getData (Node _ data _) =
    data


label : Tree a b -> IdGen (CollapsibleTree a b)
label (Node root data children) =
    State.map2
        (\nodeId collapsibleChildren -> Node ( root, False, nodeId ) data collapsibleChildren)
        newId
        (State.traverse label children)


newId : IdGen NodeId
newId =
    State.modify (\x -> x + 1) |> State.andThen (\_ -> State.get)
