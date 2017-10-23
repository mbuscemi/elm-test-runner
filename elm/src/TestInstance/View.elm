module TestInstance.View exposing (conditionallyEmbolden, statusIndicator)

import Html exposing (Attribute, Html, span, strong, text)
import Html.Attributes exposing (class)
import TestInstance.Core as TestInstance exposing (TestInstance)


statusIndicator : TestInstance -> Html message
statusIndicator testInstance =
    span
        [ statusIndicatorTextColor testInstance ]
        [ statusIndicatorIcon testInstance ]


statusIndicatorTextColor : TestInstance -> Attribute message
statusIndicatorTextColor testInstance =
    class <| TestInstance.toClass testInstance


statusIndicatorIcon : TestInstance -> Html message
statusIndicatorIcon testInstance =
    text <| " " ++ TestInstance.toStatusIcon testInstance ++ " "


conditionallyEmbolden : Bool -> String -> TestInstance -> Html message
conditionallyEmbolden hasChildren string testInstance =
    if hasChildren then
        strong [] [ text string ]
    else
        text (string ++ timeReport testInstance)


timeReport : TestInstance -> String
timeReport testInstance =
    " (" ++ TestInstance.durationAsString testInstance ++ " ms)"
