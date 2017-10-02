module View.RedGreenDisplay exposing (render)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import State.RunStatus as RunStatus exposing (RunStatus)
import Svg exposing (circle, svg)
import Svg.Attributes exposing (cx, cy, fill, height, r, width)


render : RunStatus -> Html message
render runStatus =
    div [ class "status-bar" ]
        [ svg
            [ width "12", height "12" ]
            [ circle [ cx "6", cy "6", r "6", fill <| RunStatus.toColor runStatus ] [] ]
        , span []
            [ text <| RunStatus.toText runStatus ]
        ]
