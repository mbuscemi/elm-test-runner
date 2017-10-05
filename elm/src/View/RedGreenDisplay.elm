module View.RedGreenDisplay exposing (render)

import Html exposing (Html, div, strong, text)
import Html.Attributes exposing (class)
import State.RunStatus as RunStatus exposing (RunStatus)


render : RunStatus -> Html message
render runStatus =
    div [ class <| "status-bar " ++ RunStatus.toClass runStatus ]
        [ strong []
            [ text <| RunStatus.toText runStatus ]
        ]
