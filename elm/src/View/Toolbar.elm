module View.Toolbar exposing (render)

import Html exposing (Html, div, section, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


render : message -> message -> Html message
render toggleClickHandler runAllButtonClickHandler =
    section [ class "input-block" ]
        [ div [ class "btn-toolbar" ]
            [ div [ class "btn-group" ]
                [ div
                    [ class "btn icon icon-chevron-right"
                    , onClick toggleClickHandler
                    ]
                    []
                ]
            , div [ class "btn-group right" ]
                [ div
                    [ class "btn icon icon-sync"
                    , onClick runAllButtonClickHandler
                    ]
                    [ text "Run All" ]
                ]
            ]
        ]
