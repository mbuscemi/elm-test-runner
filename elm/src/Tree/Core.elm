module Tree.Core exposing (CollapsibleTree, NodeId, Tree(Node), make)

import State exposing (State)


type Tree a
    = Node a (List (Tree a))


type alias NodeId =
    Int


type alias CollapsibleTree a =
    Tree ( a, Bool, NodeId )


type alias IdGen a =
    State NodeId a


make : Tree a -> CollapsibleTree a
make tree =
    State.finalValue 0 (label tree)


label : Tree a -> IdGen (CollapsibleTree a)
label (Node root children) =
    State.map2
        (\nid collapsibleChildren -> Node ( root, True, nid ) collapsibleChildren)
        newId
        (State.traverse label children)


newId : IdGen NodeId
newId =
    State.modify (\x -> x + 1) |> State.andThen (\_ -> State.get)
