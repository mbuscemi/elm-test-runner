module Tree.Node exposing (toggle)

import Tree.Core exposing (CollapsibleTree, NodeId, Tree(Node))


toggle : NodeId -> Bool -> CollapsibleTree a b -> CollapsibleTree a b
toggle nodeId expand (Node root data children) =
    let
        ( x, _, nid ) =
            root
    in
    if nodeId == nid then
        Node ( x, expand, nid ) data children
    else
        Node root data <| List.map (toggle nodeId expand) children
