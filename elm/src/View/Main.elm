module View.Main exposing (render)

import Html exposing (Html, div, h2, section, span, text)
import Html.Attributes exposing (class)
import State.RunStatus as RunStatus exposing (RunStatus)
import View.RedGreenDisplay
import View.Toolbar


render : RunStatus -> Html message
render runStatus =
    div [ class "etr-main-view" ]
        [ h2 [] [ text "Elm Test Runner" ]
        , View.Toolbar.render
        , View.RedGreenDisplay.render runStatus
        ]
