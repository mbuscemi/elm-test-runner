module View.OutputDisplay exposing (render)

import Html exposing (Html, div, strong, text)
import State.Failure as Failure exposing (Failure, getMessage)


render : Maybe Failure -> Html message
render failure =
    div [] (failureText failure)


failureText : Maybe Failure -> List (Html message)
failureText maybeFailure =
    case maybeFailure of
        Just failure ->
            [ strong [] [ text <| getMessage failure ] ]

        Nothing ->
            [ text "" ]
