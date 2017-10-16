module View.Toolbar exposing (render)

import Html exposing (Html, div, section, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


render : message -> Html message
render runAllButtonClickHandler =
    section [ class "input-block" ]
        [ div [ class "btn-toolbar" ]
            [ div [ class "btn-group right" ]
                [ div
                    [ class "btn icon icon-sync"
                    , onClick runAllButtonClickHandler
                    ]
                    [ text "Run All" ]
                ]
            ]
        ]
