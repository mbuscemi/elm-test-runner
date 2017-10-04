module View.TestHierarchy exposing (render)

import Html exposing (Attribute, Html, li, span, text, ul)
import Html.Attributes exposing (style)
import Tree.Tree exposing (CollapsibleTree, Tree(Node), makeTree)


render : Tree String -> Html message
render testRuns =
    testRuns
        |> removeTopNode
        |> makeTree
        |> viewTree


removeTopNode : Tree String -> Tree String
removeTopNode node =
    case node of
        Node _ (first :: _) ->
            first

        Node _ [] ->
            Node "No Tests" []


viewTree : CollapsibleTree String -> Html message
viewTree (Node root children) =
    let
        ( nodeData, expanded, nodeId ) =
            root

        rootText =
            plusOrMinus ++ nodeData

        childrenListView =
            if expanded then
                viewForest children
            else
                []

        rootView =
            span [] [ text rootText ]

        plusOrMinus =
            if List.isEmpty children then
                ""
            else if expanded then
                "▾ "
            else
                "▸ "
    in
    ul [ noBullets ] (rootView :: childrenListView)


viewForest : List (CollapsibleTree String) -> List (Html message)
viewForest children =
    List.map (\childTree -> li [] [ viewTree childTree ]) children


noBullets : Attribute message
noBullets =
    style [ ( "list-style-type", "none" ) ]
