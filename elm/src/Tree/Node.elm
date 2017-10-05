module Tree.Node exposing (toggle)

import Tree.Core exposing (CollapsibleTree, NodeId, Tree(Node))


toggle : NodeId -> Bool -> CollapsibleTree a -> CollapsibleTree a
toggle nodeId expand (Node root children) =
    let
        ( x, _, nid ) =
            root
    in
    if nodeId == nid then
        Node ( x, expand, nid ) children
    else
        Node root <| List.map (toggle nodeId expand) children
