port module Main exposing (main)

import Animation
import Html exposing (Html)
import Model.Core as Model
    exposing
        ( Model
        , buildTestRunDataTree
        , clearRunDuration
        , clearRunSeed
        , expandFailingAndTodoNodes
        , initiateStatusBarTextFlicker
        , invertAutoNavigate
        , invertAutoRun
        , purgeObsoleteNodes
        , randomSeedForJS
        , resetPassedTests
        , resetTestRuns
        , serialize
        , setAutoNavigate
        , setAutoRun
        , setCompilerErrorMessage
        , setPaneLocation
        , setRandomSeed
        , setRandomSeedForcing
        , setRunDuration
        , setRunSeed
        , setRunStatusForFailure
        , setRunStatusForTodo
        , setRunStatusToCompileError
        , setRunStatusToPassing
        , setRunStatusToProcessing
        , setSelectedTestInstance
        , setSelectedTestNodeId
        , setTestMouseIsOver
        , setTotalTestCount
        , toggleNode
        , updateFlicker
        , updateHierarchy
        , updatePassedTestCount
        )
import Model.Flags as Flags exposing (Flags)
import Model.ProjectName
import TestEvent.RunComplete as RunComplete
import TestEvent.RunStart as RunStart
import TestEvent.TestCompleted as TestCompleted
import TestInstance.Core as TestInstance exposing (TestInstance)
import View.Core


type Message
    = InitiateRunAll
    | CompilerErrored String
    | RunStart ( String, RunStart.RawData )
    | TestCompleted String
    | RunComplete RunComplete.RawData
    | TestListItemExpand Int
    | TestListItemCollapse Int
    | TestListItemMouseEnter Int
    | TestListItemMouseLeave
    | TestListItemSelect Int (Maybe TestInstance)
    | ToggleAutoRun
    | ToggleAutoNavigate
    | CopySeed String
    | SetRandomSeed Int
    | SetForceSeed Bool
    | AnimateFlicker Animation.Msg
    | PaneMoved String
    | DoNothing


main : Program String Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : String -> ( Model, Cmd Message )
init rawFlags =
    let
        flags =
            Flags.parse rawFlags
    in
    Model.default
        |> setAutoRun flags.autoRun
        |> setAutoNavigate flags.autoNavigate
        |> andNoCommand


andNoCommand : Model -> ( Model, Cmd Message )
andNoCommand model =
    ( model, Cmd.none )


andPerform : Cmd Message -> Model -> ( Model, Cmd Message )
andPerform command model =
    ( model, command )


andUpdatePersistentState : Model -> ( Model, Cmd Message )
andUpdatePersistentState model =
    serialize model
        |> updatePersistentState
        |> flip andPerform model


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        InitiateRunAll ->
            setRunStatusToProcessing model
                |> resetPassedTests
                |> setSelectedTestNodeId Nothing
                |> setSelectedTestInstance Nothing
                |> setCompilerErrorMessage Nothing
                |> clearRunDuration
                |> clearRunSeed
                |> resetTestRuns
                |> updateHierarchy
                |> andPerform (runTest <| randomSeedForJS model)

        CompilerErrored errorMessage ->
            setRunStatusToCompileError model
                |> setCompilerErrorMessage (Just errorMessage)
                |> andNoCommand

        RunStart ( projectPath, data ) ->
            let
                event =
                    RunStart.parse data
            in
            setRunStatusToProcessing model
                |> Model.ProjectName.setFromPath projectPath
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
            setRunStatusToPassing model
                |> setRunStatusForTodo
                |> setRunStatusForFailure event
                |> setRunDuration event
                |> purgeObsoleteNodes
                |> updateHierarchy
                |> expandFailingAndTodoNodes
                |> initiateStatusBarTextFlicker
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

        TestListItemSelect nodeId testInstance ->
            setSelectedTestNodeId (Just nodeId) model
                |> setSelectedTestInstance testInstance
                |> (case ( testInstance, model.autoNavigateEnabled ) of
                        ( Just instance, True ) ->
                            andPerform <| navigateToFile (TestInstance.pathAndDescription instance)

                        _ ->
                            andNoCommand
                   )

        ToggleAutoRun ->
            invertAutoRun model
                |> andUpdatePersistentState

        ToggleAutoNavigate ->
            invertAutoNavigate model
                |> andUpdatePersistentState

        CopySeed seed ->
            model
                |> andPerform (copySeed seed)

        SetRandomSeed seed ->
            setRandomSeed (Just seed) model
                |> setRandomSeedForcing True
                |> andNoCommand

        SetForceSeed setting ->
            setRandomSeedForcing setting model
                |> andNoCommand

        AnimateFlicker animateMessage ->
            updateFlicker animateMessage model
                |> andNoCommand

        PaneMoved newLocation ->
            setPaneLocation newLocation model
                |> andNoCommand

        DoNothing ->
            model |> andNoCommand


view : Model -> Html Message
view model =
    View.Core.render
        { runStatus = model.runStatus
        , compilerError = model.compilerError
        , totalTests = model.totalTests
        , passedTests = model.passedTests
        , runDuration = model.runDuration
        , runSeed = model.runSeed
        , testHierarchy = model.testHierarchy
        , nodeMouseIsOver = model.testMouseIsOver
        , selectedNodeId = model.selectedTestNodeId
        , selectedTestInstance = model.selectedTestInstance
        , autoRunEnabled = model.autoRunEnabled
        , autoNavigateEnabled = model.autoNavigateEnabled
        , randomSeed = model.randomSeed
        , forceRandomSeedEnabled = model.forceRandomSeedEnabled
        , statusBarTextStyle = model.statusBarStyle
        , paneLocation = model.paneLocation
        }
        { runAllButtonClickHandler = InitiateRunAll
        , testListItemExpand = TestListItemExpand
        , testListItemCollapse = TestListItemCollapse
        , testListItemMouseEnter = TestListItemMouseEnter
        , testListItemMouseLeave = TestListItemMouseLeave
        , testClickHandler = TestListItemSelect
        , copySeedClickHandler = CopySeed
        , setSeedClickHandler = SetRandomSeed
        , setForceSeedHandler = SetForceSeed
        }


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ commandKeyTestStart (always InitiateRunAll)
        , notifyCompilerErrored CompilerErrored
        , toggleAutoRun (always ToggleAutoRun)
        , toggleAutoNavigate (always ToggleAutoNavigate)
        , notifySaveEvent <| saveEventMessage model
        , notifyPaneMoved PaneMoved
        , runStart RunStart
        , testCompleted TestCompleted
        , runComplete RunComplete
        , Animation.subscription AnimateFlicker [ model.statusBarStyle ]
        ]


saveEventMessage : Model -> () -> Message
saveEventMessage model _ =
    if model.autoRunEnabled then
        InitiateRunAll
    else
        DoNothing


port runTest : String -> Cmd message


port copySeed : String -> Cmd message


port navigateToFile : ( String, List String ) -> Cmd message


port updatePersistentState : Flags -> Cmd message


port commandKeyTestStart : (() -> message) -> Sub message


port notifyCompilerErrored : (String -> message) -> Sub message


port toggleAutoRun : (() -> message) -> Sub message


port toggleAutoNavigate : (() -> message) -> Sub message


port notifySaveEvent : (() -> message) -> Sub message


port notifyPaneMoved : (String -> message) -> Sub message


port runStart : (( String, RunStart.RawData ) -> message) -> Sub message


port testCompleted : (String -> message) -> Sub message


port runComplete : (RunComplete.RawData -> message) -> Sub message
