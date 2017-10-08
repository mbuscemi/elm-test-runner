module View.OutputDisplay exposing (render)

import Html exposing (Html, br, div, strong, text)
import State.Failure as Failure exposing (Failure, getActual, getComparison, getExpected, getMessage)


render : Maybe Failure -> Html message
render failure =
    div [] (failureText failure)


failureText : Maybe Failure -> List (Html message)
failureText maybeFailure =
    case maybeFailure of
        Just failure ->
            [ text <| "Failed on: "
            , strong [] [ text <| getMessage failure ]
            , br [] []
            , br [] []
            , text <| getActual failure
            , br [] []
            , text <| "╷"
            , br [] []
            , text <| "│ " ++ getComparison failure
            , br [] []
            , text <| "╵"
            , br [] []
            , text <| getExpected failure
            ]

        Nothing ->
            [ text "" ]
