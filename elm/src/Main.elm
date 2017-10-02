port module Main exposing (main)

import Html exposing (Html)
import Model.Model as Model exposing (Model, setRunStatusToPassFail, setRunStatusToProcessing)
import TestEvent.RunComplete as RunComplete
import TestEvent.RunStart as RunStart
import TestEvent.TestCompleted as TestCompleted
import View.Main


type Message
    = RunAllButtonClicked
    | RunStart RunStart.RawData
    | TestCompleted TestCompleted.RawData
    | RunComplete RunComplete.RawData


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
    Model.default ! []


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        RunAllButtonClicked ->
            setRunStatusToProcessing model ! [ runTest () ]

        RunStart data ->
            setRunStatusToProcessing model ! []

        TestCompleted data ->
            model ! []

        RunComplete data ->
            let
                event =
                    RunComplete.parse data
            in
            setRunStatusToPassFail event model ! []


view : Model -> Html Message
view model =
    View.Main.render
        model.runStatus
        model.totalTests
        model.passedTests
        { runAllButtonClickHandler = RunAllButtonClicked }


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ runStart RunStart
        , testCompleted TestCompleted
        , runComplete RunComplete
        ]


port runTest : () -> Cmd message


port runStart : (RunStart.RawData -> message) -> Sub message


port testCompleted : (TestCompleted.RawData -> message) -> Sub message


port runComplete : (RunComplete.RawData -> message) -> Sub message
