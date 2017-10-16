module View.PassingTestsDisplay exposing (render)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)


render : Int -> Int -> Html message
render totalTests passingTests =
    div [ class "passing-tests" ]
        [ span [ class "number-field first" ] [ text <| toString passingTests ]
        , span [] [ text " / " ]
        , span [ class "number-field" ] [ text <| toString totalTests ]
        ]
