module View.TestHierarchy exposing (render)

import Html exposing (Attribute, Html, li, span, strong, text, ul)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import State.TestInstance as TestInstance exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree, NodeId, Tree(Node))


type alias Messages message =
    { collapse : Int -> message
    , expand : Int -> message
    }


render : CollapsibleTree String TestInstance -> Messages message -> Html message
render testHierarchy messages =
    viewTree messages (Just "test-hierarchy") testHierarchy


viewTree : Messages message -> Maybe String -> CollapsibleTree String TestInstance -> Html message
viewTree messages cssId (Node root testData children) =
    let
        ( nodeName, isExpanded, nodeId ) =
            root
    in
    ul
        (List.append [ class "test-list" ] (idField cssId))
        (rootView messages (List.isEmpty children) isExpanded nodeName nodeId
            :: viewChildren messages isExpanded children
        )


viewForest : Messages message -> List (CollapsibleTree String TestInstance) -> List (Html message)
viewForest messages children =
    List.map (\childTree -> li [] [ viewTree messages Nothing childTree ]) children


viewChildren : Messages message -> Bool -> List (CollapsibleTree String TestInstance) -> List (Html message)
viewChildren messages shouldShow children =
    if shouldShow then
        viewForest messages children
    else
        []


rootView : Messages message -> Bool -> Bool -> String -> NodeId -> Html message
rootView messages hasChildren isExpanded nodeName nodeId =
    span
        [ expandOrCollapse messages isExpanded nodeId ]
        [ rootText hasChildren isExpanded nodeName ]


rootText : Bool -> Bool -> String -> Html message
rootText hasChildren isExpanded nodeName =
    (togglingArrow hasChildren isExpanded ++ nodeName)
        |> conditionallyEmbolden (not hasChildren)


expandOrCollapse : Messages message -> Bool -> NodeId -> Attribute message
expandOrCollapse messages isExpanded nodeId =
    onClick <|
        if isExpanded then
            messages.collapse nodeId
        else
            messages.expand nodeId


togglingArrow : Bool -> Bool -> String
togglingArrow isVisible isExpanded =
    if isVisible then
        ""
    else if isExpanded then
        "▾ "
    else
        "▸ "


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
