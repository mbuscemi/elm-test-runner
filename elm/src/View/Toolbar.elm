module View.Toolbar exposing (render)

import Html exposing (Html, div, section, strong, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import State.RunStatus as RunStatus exposing (RunStatus)


render : RunStatus -> message -> Html message
render runStatus runAllButtonClickHandler =
    div [ class "toolbar" ]
        [ div [ class <| "status-bar " ++ RunStatus.toClass runStatus ]
            [ strong []
                [ text <| RunStatus.toText runStatus ]
            ]
        , div [ class "run-all-button" ]
            [ div
                [ class "btn icon icon-sync"
                , onClick runAllButtonClickHandler
                ]
                [ text "Run All" ]
            ]
        ]
