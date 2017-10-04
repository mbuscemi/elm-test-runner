port module Main exposing (main)

import Html exposing (Html)
import Model.Model as Model exposing (Model, buildTestRunDataTree, resetPassedTests, setRunStatusToCompileError, setRunStatusToPassFail, setRunStatusToProcessing, setTotalTestCount, updatePassedTestCount)
import TestEvent.RunComplete as RunComplete
import TestEvent.RunStart as RunStart
import TestEvent.TestCompleted as TestCompleted
import View.Main


type Message
    = ToggleButtonClicked
    | RunAllButtonClicked
    | InitiateRunAll
    | CompilerErrored
    | RunStart RunStart.RawData
    | TestCompleted String
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


andNoCommand : Model -> ( Model, Cmd Message )
andNoCommand model =
    ( model, Cmd.none )


andPerform : Cmd Message -> Model -> ( Model, Cmd Message )
andPerform command model =
    ( model, command )


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        ToggleButtonClicked ->
            model |> andPerform (toggle ())

        RunAllButtonClicked ->
            setRunStatusToProcessing model
                |> resetPassedTests
                |> andPerform (runTest ())

        InitiateRunAll ->
            setRunStatusToProcessing model
                |> resetPassedTests
                |> andNoCommand

        CompilerErrored ->
            setRunStatusToCompileError model
                |> andNoCommand

        RunStart data ->
            let
                event =
                    RunStart.parse data
            in
            setRunStatusToProcessing model
                |> setTotalTestCount event
                |> andNoCommand

        TestCompleted data ->
            let
                event =
                    TestCompleted.parse data
            in
            updatePassedTestCount event model
                |> buildTestRunDataTree event
                |> andNoCommand

        RunComplete data ->
            let
                event =
                    RunComplete.parse data
            in
            setRunStatusToPassFail event model
                |> andNoCommand


view : Model -> Html Message
view model =
    View.Main.render
        model.runStatus
        model.totalTests
        model.passedTests
        model.testRuns
        { toggleClickHandler = ToggleButtonClicked
        , runAllButtonClickHandler = RunAllButtonClicked
        }


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ commandKeyTestStart (always InitiateRunAll)
        , notifyCompilerErrored (always CompilerErrored)
        , runStart RunStart
        , testCompleted TestCompleted
        , runComplete RunComplete
        ]


port toggle : () -> Cmd message


port runTest : () -> Cmd message


port commandKeyTestStart : (() -> message) -> Sub message


port notifyCompilerErrored : (() -> message) -> Sub message


port runStart : (RunStart.RawData -> message) -> Sub message


port testCompleted : (String -> message) -> Sub message


port runComplete : (RunComplete.RawData -> message) -> Sub message
