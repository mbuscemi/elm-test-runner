module View.TestHierarchy.Root exposing (render)

import Html exposing (Attribute, Html, span, strong, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import TestInstance.Core as TestInstance exposing (TestInstance)


type alias Messages message =
    { collapse : Int -> message
    , expand : Int -> message
    }


render : Messages message -> TestInstance -> Bool -> Bool -> String -> Int -> Html message
render messages nodeData hasChildren isExpanded nodeName nodeId =
    span
        [ expandOrCollapse messages isExpanded nodeId ]
        (rootText nodeData hasChildren isExpanded nodeName)


expandOrCollapse : Messages message -> Bool -> Int -> Attribute message
expandOrCollapse messages isExpanded nodeId =
    onClick <|
        if isExpanded then
            messages.collapse nodeId
        else
            messages.expand nodeId


rootText : TestInstance -> Bool -> Bool -> String -> List (Html message)
rootText nodeData hasChildren isExpanded nodeName =
    [ togglingArrow hasChildren isExpanded
    , statusIndicator nodeData
    , conditionallyEmbolden (not hasChildren) nodeName nodeData
    ]


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


conditionallyEmbolden : Bool -> String -> TestInstance -> Html message
conditionallyEmbolden hasChildren string nodeData =
    if hasChildren then
        strong [] [ htmlText string ]
    else
        htmlText (string ++ timeReport nodeData)


htmlText : String -> Html message
htmlText string =
    text <| string


timeReport : TestInstance -> String
timeReport nodeData =
    " (" ++ TestInstance.durationAsString nodeData ++ " ms)"
