module View.DurationAndSeedDisplay exposing (render)

import Duration.Core as Duration exposing (Duration)
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (class)
import Round exposing (round)


render : Maybe Duration -> Html message
render runDuration =
    div [ class "run-data-row" ]
        [ div [ runDataClass ] [ text "Total Run Time:" ]
        , div [ runDataClass ] [ runTimeDisplay runDuration ]
        ]


runTimeDisplay : Maybe Duration -> Html message
runTimeDisplay runDuration =
    case runDuration of
        Just duration ->
            text <| formattedSeconds duration

        Nothing ->
            text ""


formattedSeconds : Duration -> String
formattedSeconds duration =
    Duration.asSeconds duration
        |> Round.round 2
        |> flip (++) " s"


runDataClass : Attribute message
runDataClass =
    class "run-data-field"
