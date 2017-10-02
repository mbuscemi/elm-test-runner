module View.Toolbar exposing (render)

import Html exposing (Html, div, section, text)
import Html.Attributes exposing (class)


render : Html message
render =
    section [ class "input-block" ]
        [ div [ class "button-toolbar" ]
            [ div [ class "button-group" ]
                [ div [ class "btn icon icon-sync" ] [ text "Run All" ]
                ]
            ]
        ]
