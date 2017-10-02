port module Main exposing (main)

import Html exposing (Html, div, h2, section, span, text)
import Html.Attributes exposing (class)
import Svg exposing (circle, svg)
import Svg.Attributes exposing (cx, cy, fill, height, r, width)
import TestEvent.RunComplete as RunComplete
import TestEvent.RunStart as RunStart
import TestEvent.TestCompleted as TestCompleted


type alias Model =
    { runStatus : RunStatus }


type Message
    = RunStart RunStart.RawData
    | TestCompleted TestCompleted.RawData
    | RunComplete RunComplete.RawData


type RunStatus
    = NoData
    | Processing
    | LastPassed
    | LastFailed


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Message )
init =
    { runStatus = NoData } ! []


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        RunStart data ->
            { runStatus = Processing } ! []

        TestCompleted data ->
            model ! []

        RunComplete data ->
            let
                event =
                    RunComplete.parse data

                newStatus =
                    if RunComplete.passed event then
                        LastPassed
                    else
                        LastFailed
            in
            { runStatus = newStatus } ! []


view : Model -> Html Message
view model =
    div [ class "etr-main-view" ]
        [ h2 [] [ text "Elm Test Runner" ]
        , section [ class "input-block" ]
            [ div [ class "button-toolbar" ]
                [ div [ class "button-group" ]
                    [ div [ class "btn icon icon-sync" ] [ text "Run All" ]
                    ]
                ]
            ]
        , redGreenDisplay model.runStatus
        ]


redGreenDisplay : RunStatus -> Html Message
redGreenDisplay runStatus =
    div [ class "status-bar" ]
        [ svg
            [ width "12", height "12" ]
            [ circle [ cx "6", cy "6", r "6", fill <| runStatusColor runStatus ] [] ]
        , span []
            [ text <| runStatusText runStatus ]
        ]


runStatusText : RunStatus -> String
runStatusText runStatus =
    case runStatus of
        NoData ->
            "No Data"

        Processing ->
            "... Processing ..."

        LastPassed ->
            "Passed!"

        LastFailed ->
            "Failed"


runStatusColor : RunStatus -> String
runStatusColor runStatus =
    case runStatus of
        NoData ->
            "grey"

        Processing ->
            "yellow"

        LastPassed ->
            "green"

        LastFailed ->
            "red"


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ runStart RunStart
        , testCompleted TestCompleted
        , runComplete RunComplete
        ]


port runStart : (RunStart.RawData -> message) -> Sub message


port testCompleted : (TestCompleted.RawData -> message) -> Sub message


port runComplete : (RunComplete.RawData -> message) -> Sub message
