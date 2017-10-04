module View.TestHierarchy exposing (render)

import Html exposing (Attribute, Html, li, span, text, ul)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Tree.Tree exposing (CollapsibleTree, Tree(Node), makeTree)


type alias Messages message =
    { collapse : Int -> message
    , expand : Int -> message
    }


render : CollapsibleTree String -> Messages message -> Html message
render testHierarchy messages =
    viewTree messages (Just "test-hierarchy") testHierarchy


viewTree : Messages message -> Maybe String -> CollapsibleTree String -> Html message
viewTree messages cssId (Node root children) =
    let
        ( nodeData, expanded, nodeId ) =
            root

        rootText =
            plusOrMinus ++ nodeData

        childrenListView =
            if expanded then
                viewForest messages children
            else
                []

        rootView =
            span [ expandOrCollapse ] [ text rootText ]

        expandOrCollapse =
            onClick <|
                if expanded then
                    messages.collapse nodeId
                else
                    messages.expand nodeId

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


viewForest : Messages message -> List (CollapsibleTree String) -> List (Html message)
viewForest messages children =
    List.map (\childTree -> li [] [ viewTree messages Nothing childTree ]) children


idField : Maybe String -> List (Attribute message)
idField name =
    case name of
        Just field ->
            [ id field ]

        Nothing ->
            []
