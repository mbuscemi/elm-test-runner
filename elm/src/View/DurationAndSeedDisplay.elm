module View.DurationAndSeedDisplay exposing (render)

import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Round
import State.Duration as Duration exposing (Duration)


type alias Data =
    { runDuration : Maybe Duration
    , runSeed : Maybe Int
    }


type alias Messages message =
    { copySeedClickHandler : String -> message
    , setSeedClickHandler : Int -> message
    }


render : Data -> Messages message -> Html message
render data messages =
    div [ class "run-data-row" ]
        [ div [ runDataClass "time" ] [ runTimeDisplay data.runDuration ]
        , div [ runDataClass "seed" ] (runSeedDisplay data.runSeed messages)
        ]


runTimeDisplay : Maybe Duration -> Html message
runTimeDisplay runDuration =
    case runDuration of
        Just duration ->
            text <| "Total Run Time: " ++ formattedSeconds duration

        Nothing ->
            text ""


runSeedDisplay : Maybe Int -> Messages message -> List (Html message)
runSeedDisplay runSeed messages =
    case runSeed of
        Just seed ->
            let
                seedString =
                    toString seed
            in
            [ text <| "Seed: " ++ seedString
            , div
                [ class "btn btn-xs icon icon-file-symlink-file"
                , onClick <| messages.copySeedClickHandler seedString
                ]
                [ text "Copy" ]
            , div
                [ class "btn btn-xs icon icon-arrow-down"
                , onClick <| messages.setSeedClickHandler seed
                ]
                [ text "Set" ]
            ]

        Nothing ->
            [ text "" ]


formattedSeconds : Duration -> String
formattedSeconds duration =
    Duration.asSeconds duration
        |> Round.round 2
        |> flip (++) " s"


runDataClass : String -> Attribute message
runDataClass additionalField =
    class <| "run-data-field " ++ additionalField
