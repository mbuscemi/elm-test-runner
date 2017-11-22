module View.Toolbar exposing (render)

import Animation exposing (State)
import Html exposing (Html, div, span, strong, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import State.RunStatus as RunStatus exposing (RunStatus)


render : Int -> Int -> RunStatus -> State -> message -> Html message
render totalTests passingTests runStatus statusBarTextStyle runAllButtonClickHandler =
    div [ class "toolbar" ]
        [ div [ class <| "status-bar " ++ RunStatus.toClass runStatus ]
            [ strong
                (class "title" :: Animation.render statusBarTextStyle)
                [ text <| RunStatus.toText runStatus ]
            , span
                (class "passing-tests" :: Animation.render statusBarTextStyle)
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
