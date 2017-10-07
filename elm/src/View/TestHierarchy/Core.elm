module View.TestHierarchy.Core exposing (render)

import Html exposing (Attribute, Html, li, span, strong, text, ul)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree, NodeId, Tree(Node))


type alias Messages message =
    { collapse : Int -> message
    , expand : Int -> message
    , mouseIn : Int -> message
    , mouseOut : message
    }


render : CollapsibleTree String TestInstance -> Messages message -> Maybe Int -> Html message
render testHierarchy messages nodeMouseIsOver =
    viewTree messages (Just "test-hierarchy") nodeMouseIsOver testHierarchy


viewTree : Messages message -> Maybe String -> Maybe Int -> CollapsibleTree String TestInstance -> Html message
viewTree messages className nodeMouseIsOver (Node ( nodeName, isExpanded, nodeId ) nodeData children) =
    ul
        (List.append [ class "test-list" ] (additionalClass className))
        (rootView messages nodeData (List.isEmpty children) isExpanded nodeName nodeId
            :: viewChildren messages isExpanded nodeMouseIsOver children
        )


viewChildren : Messages message -> Bool -> Maybe Int -> List (CollapsibleTree String TestInstance) -> List (Html message)
viewChildren messages shouldShow nodeMouseIsOver children =
    if shouldShow then
        viewForest messages nodeMouseIsOver children
    else
        []


viewForest : Messages message -> Maybe Int -> List (CollapsibleTree String TestInstance) -> List (Html message)
viewForest messages nodeMouseIsOver children =
    List.map (childTree messages nodeMouseIsOver) children


childTree : Messages message -> Maybe Int -> CollapsibleTree String TestInstance -> Html message
childTree messages nodeMouseIsOver ((Node ( _, _, nodeId ) _ children) as tree) =
    li
        (List.append
            (mouseEvents messages nodeId children)
            (mouseOverHighlight nodeId nodeMouseIsOver)
        )
        [ viewTree messages Nothing nodeMouseIsOver tree ]


mouseEvents : Messages message -> Int -> List (CollapsibleTree String TestInstance) -> List (Attribute message)
mouseEvents messages nodeId children =
    if List.isEmpty children then
        [ onMouseEnter <| messages.mouseIn nodeId
        , onMouseLeave <| messages.mouseOut
        ]
    else
        []


mouseOverHighlight : Int -> Maybe Int -> List (Attribute message)
mouseOverHighlight nodeId nodeMouseIsOver =
    case nodeMouseIsOver of
        Just mouseNodeId ->
            if nodeId == mouseNodeId then
                [ style [ ( "background-color", "#2c333e" ) ] ]
                -- save this color for later [ style [ ( "background-color", "#343f51" ) ] ]
            else
                []

        Nothing ->
            []


rootView : Messages message -> TestInstance -> Bool -> Bool -> String -> NodeId -> Html message
rootView messages nodeData hasChildren isExpanded nodeName nodeId =
    span
        [ expandOrCollapse messages isExpanded nodeId ]
        (rootText nodeData hasChildren isExpanded nodeName)


rootText : TestInstance -> Bool -> Bool -> String -> List (Html message)
rootText nodeData hasChildren isExpanded nodeName =
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


additionalClass : Maybe String -> List (Attribute message)
additionalClass name =
    case name of
        Just field ->
            [ class field ]

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
