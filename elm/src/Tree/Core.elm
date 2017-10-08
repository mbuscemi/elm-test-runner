module Tree.Core exposing (CollapsibleTree, NodeId, Tree(Node), make)

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


label : Tree a b -> IdGen (CollapsibleTree a b)
label (Node root data children) =
    State.map2
        (\nid collapsibleChildren -> Node ( root, False, nid ) data collapsibleChildren)
        newId
        (State.traverse label children)


newId : IdGen NodeId
newId =
    State.modify (\x -> x + 1) |> State.andThen (\_ -> State.get)
