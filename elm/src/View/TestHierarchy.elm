module View.TestHierarchy exposing (render)

import Html exposing (Attribute, Html, li, span, strong, text, ul)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree, NodeId, Tree(Node))


type alias Messages message =
    { collapse : Int -> message
    , expand : Int -> message
    }


render : CollapsibleTree String TestInstance -> Messages message -> Html message
render testHierarchy messages =
    viewTree messages (Just "test-hierarchy") testHierarchy


viewTree : Messages message -> Maybe String -> CollapsibleTree String TestInstance -> Html message
viewTree messages cssId (Node root nodeData children) =
    let
        ( nodeName, isExpanded, nodeId ) =
            root
    in
    ul
        (List.append [ class "test-list" ] (idField cssId))
        (rootView messages nodeData (List.isEmpty children) isExpanded nodeName nodeId
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


rootView : Messages message -> TestInstance -> Bool -> Bool -> String -> NodeId -> Html message
rootView messages nodeData hasChildren isExpanded nodeName nodeId =
    span
        [ expandOrCollapse messages isExpanded nodeId ]
        [ rootText nodeData hasChildren isExpanded nodeName ]


rootText : TestInstance -> Bool -> Bool -> String -> Html message
rootText nodeData hasChildren isExpanded nodeName =
    span []
        [ togglingArrow hasChildren isExpanded
        , statusIndicator nodeData
        , conditionallyEmbolden (not hasChildren) nodeName nodeData
        ]


expandOrCollapse : Messages message -> Bool -> NodeId -> Attribute message
expandOrCollapse messages isExpanded nodeId =
    onClick <|
        if isExpanded then
            messages.collapse nodeId
        else
            messages.expand nodeId


togglingArrow : Bool -> Bool -> Html message
togglingArrow isVisible isExpanded =
    strong [] [ text <| togglingArrowText isVisible isExpanded ]


togglingArrowText : Bool -> Bool -> String
togglingArrowText isVisible isExpanded =
    if isVisible then
        ""
    else if isExpanded then
        "▾ "
    else
        "▸ "


statusIndicator : TestInstance -> Html message
statusIndicator nodeData =
    span
        [ statusIndicatorTextColor nodeData ]
        [ statusIndicatorIcon nodeData ]


statusIndicatorTextColor : TestInstance -> Attribute message
statusIndicatorTextColor nodeData =
    class <| TestInstance.toClass nodeData


statusIndicatorIcon : TestInstance -> Html message
statusIndicatorIcon nodeData =
    text <| " " ++ TestInstance.toStatusIcon nodeData ++ " "


idField : Maybe String -> List (Attribute message)
idField name =
    case name of
        Just field ->
            [ id field ]

        Nothing ->
            []


conditionallyEmbolden : Bool -> String -> TestInstance -> Html message
conditionallyEmbolden hasChildren string nodeData =
    if hasChildren then
        strong [] [ htmlText string nodeData ]
    else
        htmlText (string ++ timeReport nodeData) nodeData


htmlText : String -> TestInstance -> Html message
htmlText string nodeData =
    text <| string


timeReport : TestInstance -> String
timeReport nodeData =
    " (" ++ TestInstance.durationAsString nodeData ++ " ms)"
