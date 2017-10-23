module View.TestHierarchy.Root exposing (render)

import Html exposing (Attribute, Html, span, strong, text)
import Html.Events exposing (onClick)


type alias Messages message =
    { collapse : Int -> message
    , expand : Int -> message
    }


type alias TestInstanceView testInstance message =
    { statusIndicator : testInstance -> Html message
    , conditionallyEmbolden : Bool -> String -> testInstance -> Html message
    }


render : Bool -> Bool -> String -> Int -> TestInstanceView testInstance message -> testInstance -> Messages message -> Html message
render hasChildren isExpanded nodeName nodeId testInstanceView testInstance messages =
    span
        [ expandOrCollapse isExpanded nodeId messages ]
        (rootText hasChildren isExpanded nodeName testInstanceView testInstance)


expandOrCollapse : Bool -> Int -> Messages message -> Attribute message
expandOrCollapse isExpanded nodeId messages =
    onClick <|
        if isExpanded then
            messages.collapse nodeId
        else
            messages.expand nodeId


rootText : Bool -> Bool -> String -> TestInstanceView testInstance message -> testInstance -> List (Html message)
rootText hasChildren isExpanded nodeName testInstanceView testInstance =
    [ togglingArrow hasChildren isExpanded
    , testInstanceView.statusIndicator testInstance
    , testInstanceView.conditionallyEmbolden (not hasChildren) nodeName testInstance
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
