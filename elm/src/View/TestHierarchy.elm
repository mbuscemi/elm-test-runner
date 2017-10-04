module View.TestHierarchy exposing (render)

import Html exposing (Attribute, Html, li, span, text, ul)
import Html.Attributes exposing (class, id)
import Tree.Tree exposing (CollapsibleTree, Tree(Node), makeTree)


render : Tree String -> Html message
render testRuns =
    testRuns
        |> removeTopNode
        |> makeTree
        |> viewTree (Just "test-hierarchy")


removeTopNode : Tree String -> Tree String
removeTopNode node =
    case node of
        Node _ (first :: _) ->
            first

        Node _ [] ->
            Node "No Tests" []


viewTree : Maybe String -> CollapsibleTree String -> Html message
viewTree cssId (Node root children) =
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
    ul
        (List.append [ class "test-list" ] (idField cssId))
        (rootView :: childrenListView)


viewForest : List (CollapsibleTree String) -> List (Html message)
viewForest children =
    List.map (\childTree -> li [] [ viewTree Nothing childTree ]) children


idField : Maybe String -> List (Attribute message)
idField name =
    case name of
        Just field ->
            [ id field ]

        Nothing ->
            []
