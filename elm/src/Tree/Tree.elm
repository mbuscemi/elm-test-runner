module Tree.Tree exposing (CollapsibleTree, NodeId, Tree(Node), makeTree, toggleNode)

import State exposing (State)


type Tree a
    = Node a (List (Tree a))


type alias NodeId =
    Int


type alias CollapsibleTree a =
    Tree ( a, Bool, NodeId )


type alias IdGen a =
    State NodeId a


toggleNode : NodeId -> Bool -> CollapsibleTree a -> CollapsibleTree a
toggleNode nodeId expand (Node root children) =
    let
        ( x, _, nid ) =
            root
    in
    if nodeId == nid then
        Node ( x, expand, nid ) children
    else
        Node root <| List.map (toggleNode nodeId expand) children


makeTree : Tree a -> CollapsibleTree a
makeTree tree =
    State.finalValue 0 (labelTree tree)


labelTree : Tree a -> IdGen (CollapsibleTree a)
labelTree (Node root children) =
    State.map2
        (\nid collapsibleChildren -> Node ( root, True, nid ) collapsibleChildren)
        newNodeId
        (State.traverse labelTree children)


newNodeId : IdGen NodeId
newNodeId =
    State.modify (\x -> x + 1) |> State.andThen (\_ -> State.get)
