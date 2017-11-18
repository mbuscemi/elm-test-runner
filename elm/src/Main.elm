port module Main exposing (main)

import And
import Animation
import Html exposing (Html)
import Json.Encode exposing (Value)
import Model exposing (Model)
import Model.Basics
import Model.Config
import Model.Flags as Flags
import Model.ProjectName
import Model.RandomSeed
import Model.RunDuration
import Model.RunSeed
import Model.RunStatus
import Model.SelectedTest
import Model.StatusBar
import Model.TestCount
import Model.TestTree
import TestEvent.RunComplete as RunComplete
import TestEvent.RunStart as RunStart
import TestEvent.TestCompleted as TestCompleted
import TestInstance.Core as TestInstance exposing (TestInstance)
import TestInstance.View
import View.Core


type Message
    = InitiateRunAll
    | CompilerErrored String
    | RunStart ( String, RunStart.RawData )
    | TestCompleted Value
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


main : Program Value Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Value -> ( Model, Cmd Message )
init rawFlags =
    let
        flags =
            Flags.parse rawFlags
    in
    Model.default
        |> Model.Config.setAutoRun flags.autoRun
        |> Model.Config.setAutoNavigate flags.autoNavigate
        |> And.noCommand


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        InitiateRunAll ->
            Model.RunStatus.setToProcessing model
                |> Model.TestCount.resetPassed
                |> Model.SelectedTest.setNodeId Nothing
                |> Model.SelectedTest.setInstance Nothing
                |> Model.Basics.setCompilerErrorMessage Nothing
                |> Model.RunDuration.clear
                |> Model.RunSeed.clear
                |> Model.TestTree.reset
                |> Model.TestTree.updateHierarchy
                |> And.execute (runTest <| Model.RandomSeed.forJS model)

        CompilerErrored errorMessage ->
            Model.RunStatus.setToCompileError model
                |> Model.Basics.setCompilerErrorMessage (Just errorMessage)
                |> And.noCommand

        RunStart ( projectPath, data ) ->
            let
                event =
                    RunStart.parse data
            in
            Model.RunStatus.setToProcessing model
                |> Model.ProjectName.setFromPath projectPath
                |> Model.TestCount.setTotal event
                |> Model.RunSeed.set event
                |> And.noCommand

        TestCompleted data ->
            let
                event =
                    TestCompleted.parseJson data
            in
            Model.TestCount.updatePassed event model
                |> Model.TestTree.build event
                |> Model.TestTree.updateHierarchy
                |> And.noCommand

        RunComplete data ->
            let
                event =
                    RunComplete.parse data
            in
            Model.RunStatus.setToPassing model
                |> Model.RunStatus.setForTodo TestInstance.isTodo
                |> Model.RunStatus.setForFailure event
                |> Model.RunDuration.set event
                |> Model.TestTree.purgeObsoleteNodes
                |> Model.TestTree.updateHierarchy
                |> Model.TestTree.expandFailingAndTodoNodes
                |> Model.StatusBar.initiateTextFlicker
                |> And.noCommand

        TestListItemExpand nodeId ->
            Model.TestTree.toggleNode nodeId True model
                |> And.noCommand

        TestListItemCollapse nodeId ->
            Model.TestTree.toggleNode nodeId False model
                |> And.noCommand

        TestListItemMouseEnter nodeId ->
            Model.Basics.setTestMouseIsOver (Just nodeId) model
                |> And.noCommand

        TestListItemMouseLeave ->
            Model.Basics.setTestMouseIsOver Nothing model
                |> And.noCommand

        TestListItemSelect nodeId testInstance ->
            Model.SelectedTest.setNodeId (Just nodeId) model
                |> Model.SelectedTest.setInstance testInstance
                |> Model.SelectedTest.showInEditor testInstance model.autoNavigateEnabled

        ToggleAutoRun ->
            Model.Config.invertAutoRun model
                |> And.updateAtomState

        ToggleAutoNavigate ->
            Model.Config.invertAutoNavigate model
                |> And.updateAtomState

        CopySeed seed ->
            model
                |> And.execute (copySeed seed)

        SetRandomSeed seed ->
            Model.RandomSeed.set (Just seed) model
                |> Model.RandomSeed.setForcing True
                |> And.noCommand

        SetForceSeed setting ->
            Model.RandomSeed.setForcing setting model
                |> And.noCommand

        AnimateFlicker animateMessage ->
            Model.StatusBar.updateFlicker animateMessage model
                |> And.noCommand

        PaneMoved newLocation ->
            Model.Basics.setPaneLocation newLocation model
                |> And.noCommand

        DoNothing ->
            model |> And.noCommand


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
        , statusIndicator = TestInstance.View.statusIndicator
        , conditionallyEmbolden = TestInstance.View.conditionallyEmbolden
        , nodeMouseIsOver = model.testMouseIsOver
        , selectedNodeId = model.selectedTestNodeId
        , selectedTestInstance = model.selectedTestInstance
        , failure = TestInstance.getFailureData model.selectedTestInstance
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


port commandKeyTestStart : (() -> message) -> Sub message


port notifyCompilerErrored : (String -> message) -> Sub message


port toggleAutoRun : (() -> message) -> Sub message


port toggleAutoNavigate : (() -> message) -> Sub message


port notifySaveEvent : (() -> message) -> Sub message


port notifyPaneMoved : (String -> message) -> Sub message


port runStart : (( String, RunStart.RawData ) -> message) -> Sub message


port testCompleted : (Value -> message) -> Sub message


port runComplete : (RunComplete.RawData -> message) -> Sub message
