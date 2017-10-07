port module Main exposing (main)

import Html exposing (Html)
import Model.Core as Model
    exposing
        ( Model
        , buildTestRunDataTree
        , clearRunDuration
        , clearRunSeed
        , invertAutoRun
        , purgeObsoleteNodes
        , resetPassedTests
        , resetTestRuns
        , setRunDuration
        , setRunSeed
        , setRunStatusToCompileError
        , setRunStatusToPassFail
        , setRunStatusToProcessing
        , setTestMouseIsOver
        , setTotalTestCount
        , toggleNode
        , updateHierarchy
        , updatePassedTestCount
        )
import TestEvent.RunComplete as RunComplete
import TestEvent.RunStart as RunStart
import TestEvent.TestCompleted as TestCompleted
import View.Main


type Message
    = ToggleButtonClicked
    | InitiateRunAll
    | CompilerErrored
    | RunStart RunStart.RawData
    | TestCompleted String
    | RunComplete RunComplete.RawData
    | TestListItemExpand Int
    | TestListItemCollapse Int
    | TestListItemMouseEnter Int
    | TestListItemMouseLeave
    | ToggleAutoRun
    | DoNothing


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
            model
                |> andPerform (toggle ())

        InitiateRunAll ->
            setRunStatusToProcessing model
                |> resetPassedTests
                |> clearRunDuration
                |> clearRunSeed
                |> resetTestRuns
                |> updateHierarchy
                |> andPerform (runTest ())

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
                |> setRunSeed event
                |> andNoCommand

        TestCompleted data ->
            let
                event =
                    TestCompleted.parse data
            in
            updatePassedTestCount event model
                |> buildTestRunDataTree event
                |> updateHierarchy
                |> andNoCommand

        RunComplete data ->
            let
                event =
                    RunComplete.parse data
            in
            setRunStatusToPassFail event model
                |> setRunDuration event
                |> purgeObsoleteNodes
                |> updateHierarchy
                |> andNoCommand

        TestListItemExpand nodeId ->
            toggleNode nodeId True model
                |> andNoCommand

        TestListItemCollapse nodeId ->
            toggleNode nodeId False model
                |> andNoCommand

        TestListItemMouseEnter nodeId ->
            setTestMouseIsOver (Just nodeId) model
                |> andNoCommand

        TestListItemMouseLeave ->
            setTestMouseIsOver Nothing model
                |> andNoCommand

        ToggleAutoRun ->
            invertAutoRun model
                |> andNoCommand

        DoNothing ->
            model |> andNoCommand


view : Model -> Html Message
view model =
    View.Main.render
        { runStatus = model.runStatus
        , totalTests = model.totalTests
        , passedTests = model.passedTests
        , runDuration = model.runDuration
        , runSeed = model.runSeed
        , testHierarchy = model.testHierarchy
        , nodeMouseIsOver = model.testMouseIsOver
        , autoRunEnabled = model.autoRunEnabled
        }
        { toggleClickHandler = ToggleButtonClicked
        , runAllButtonClickHandler = InitiateRunAll
        , testListItemExpand = TestListItemExpand
        , testListItemCollapse = TestListItemCollapse
        , testListItemMouseEnter = TestListItemMouseEnter
        , testListItemMouseLeave = TestListItemMouseLeave
        }


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ commandKeyTestStart (always InitiateRunAll)
        , notifyCompilerErrored (always CompilerErrored)
        , toggleAutoRun (always ToggleAutoRun)
        , notifySaveEvent <| saveEventMessage model
        , runStart RunStart
        , testCompleted TestCompleted
        , runComplete RunComplete
        ]


saveEventMessage : Model -> () -> Message
saveEventMessage model _ =
    if model.autoRunEnabled then
        InitiateRunAll
    else
        DoNothing


port toggle : () -> Cmd message


port runTest : () -> Cmd message


port commandKeyTestStart : (() -> message) -> Sub message


port notifyCompilerErrored : (() -> message) -> Sub message


port toggleAutoRun : (() -> message) -> Sub message


port notifySaveEvent : (() -> message) -> Sub message


port runStart : (RunStart.RawData -> message) -> Sub message


port testCompleted : (String -> message) -> Sub message


port runComplete : (RunComplete.RawData -> message) -> Sub message
