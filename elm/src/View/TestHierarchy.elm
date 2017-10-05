module View.TestHierarchy exposing (render)

import Html exposing (Attribute, Html, li, span, strong, text, ul)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Tree.Core exposing (CollapsibleTree, Tree(Node))


type alias Messages message =
    { collapse : Int -> message
    , expand : Int -> message
    }


render : CollapsibleTree String {} -> Messages message -> Html message
render testHierarchy messages =
    viewTree messages (Just "test-hierarchy") testHierarchy


viewTree : Messages message -> Maybe String -> CollapsibleTree String {} -> Html message
viewTree messages cssId (Node root data children) =
    let
        ( nodeData, expanded, nodeId ) =
            root

        hasChildren =
            List.isEmpty children

        rootText =
            (plusOrMinus ++ nodeData)
                |> conditionallyEmbolden (not hasChildren)

        childrenListView =
            if expanded then
                viewForest messages children
            else
                []

        rootView =
            span [ expandOrCollapse ] [ rootText ]

        expandOrCollapse =
            onClick <|
                if expanded then
                    messages.collapse nodeId
                else
                    messages.expand nodeId

        plusOrMinus =
            if hasChildren then
                ""
            else if expanded then
                "▾ "
            else
                "▸ "
    in
    ul
        (List.append [ class "test-list" ] (idField cssId))
        (rootView :: childrenListView)


viewForest : Messages message -> List (CollapsibleTree String {}) -> List (Html message)
viewForest messages children =
    List.map (\childTree -> li [] [ viewTree messages Nothing childTree ]) children


idField : Maybe String -> List (Attribute message)
idField name =
    case name of
        Just field ->
            [ id field ]

        Nothing ->
            []


conditionallyEmbolden : Bool -> String -> Html message
conditionallyEmbolden shouldEmbolden string =
    let
        htmlText =
            text string
    in
    if shouldEmbolden then
        strong [] [ htmlText ]
    else
        htmlText
