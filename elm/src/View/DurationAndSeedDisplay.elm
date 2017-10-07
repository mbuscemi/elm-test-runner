module View.DurationAndSeedDisplay exposing (render)

import Duration.Core as Duration exposing (Duration)
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (class)
import Round exposing (round)


render : Maybe Duration -> Maybe Int -> Html message
render runDuration runSeed =
    div [ class "run-data-row" ]
        [ div [ runDataClass ] [ runTimeDisplay runDuration ]
        , div [ runDataClass ] [ runSeedDisplay runSeed ]
        ]


runTimeDisplay : Maybe Duration -> Html message
runTimeDisplay runDuration =
    case runDuration of
        Just duration ->
            text <| "Total Run Time: " ++ formattedSeconds duration

        Nothing ->
            text ""


runSeedDisplay : Maybe Int -> Html message
runSeedDisplay runSeed =
    case runSeed of
        Just seed ->
            text <| "Seed: " ++ toString seed

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
