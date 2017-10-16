module View.Toolbar exposing (render)

import Html exposing (Html, div, section, span, strong, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import State.RunStatus as RunStatus exposing (RunStatus)


render : Int -> Int -> RunStatus -> message -> Html message
render totalTests passingTests runStatus runAllButtonClickHandler =
    div [ class "toolbar" ]
        [ div [ class <| "status-bar " ++ RunStatus.toClass runStatus ]
            [ strong [ class "title" ] [ text <| RunStatus.toText runStatus ]
            , div [ class "passing-tests" ]
                [ span [ class "number-field passing" ] [ text <| toString passingTests ]
                , span [] [ text " / " ]
                , span [ class "number-field total" ] [ text <| toString totalTests ]
                ]
            ]
        , div [ class "run-all-button" ]
            [ div
                [ class "btn icon icon-sync"
                , onClick runAllButtonClickHandler
                ]
                [ text "Run All" ]
            ]
        ]
