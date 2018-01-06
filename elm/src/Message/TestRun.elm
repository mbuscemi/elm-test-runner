port module Message.TestRun exposing (Message, messages, update)

import And
import Animation
import Json.Encode exposing (Value)
import Model.Animation
import Model.Basics
import Model.ProjectName
import Model.RandomSeed
import Model.RunDuration
import Model.RunSeed
import Model.RunStatus
import Model.SelectedTest
import Model.TestCount
import Model.TestTree
import State.Duration exposing (Duration)
import State.PaneLocation exposing (PaneLocation)
import State.RunStatus exposing (RunStatus)
import TestEvent.RunComplete as RunComplete
import TestEvent.RunStart as RunStart
import TestEvent.TestCompleted as TestCompleted
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree, Tree)


type alias Model model =
    { model
        | runStatus : RunStatus
        , statusBarTextStyle : Animation.State
        , statusBarColorStyle : Animation.State
        , footerStyle : Animation.State
        , footerExpanded : Bool
        , compilerError : Maybe String
        , paneLocation : PaneLocation
        , projectName : String
        , testRuns : Tree String TestInstance
        , randomSeed : Maybe Int
        , forceRandomSeedEnabled : Bool
        , runSeed : Maybe Int
        , runDuration : Maybe Duration
        , runStatus : RunStatus
        , selectedTestNodeId : Maybe Int
        , selectedTestInstance : Maybe TestInstance
        , testMouseIsOver : Maybe Int
        , passedTests : Int
        , totalTests : Int
        , projectName : String
        , testRuns : Tree String TestInstance
        , testHierarchy : CollapsibleTree String TestInstance
        , currentWorkingDirectory : String
    }


type Message
    = Initiate
    | GenerateTests
    | Execute
    | CompilerError String
    | RunStart Value
    | TestCompleted Value
    | RunComplete Value


update : Message -> Model model -> ( Model model, Cmd message )
update message model =
    case message of
        Initiate ->
            model
                |> Model.TestCount.resetPassed
                |> Model.SelectedTest.setNodeId Nothing
                |> Model.SelectedTest.setInstance Nothing
                |> Model.Basics.setCompilerErrorMessage Nothing
                |> Model.RunDuration.clear
                |> Model.RunSeed.clear
                |> Model.TestTree.reset
                |> Model.TestTree.updateHierarchy
                |> And.execute (runTest <| ( model.currentWorkingDirectory, Model.RandomSeed.forJS model ))

        GenerateTests ->
            model
                |> Model.RunStatus.setToGeneratingTests
                |> Model.Animation.initiateColorOscillation
                |> And.doNothing

        Execute ->
            model
                |> Model.RunStatus.setToProcessing
                |> Model.Animation.initiateColorOscillation
                |> And.doNothing

        CompilerError error ->
            model
                |> Model.RunStatus.setToCompileError
                |> Model.Animation.pulseToStatusColor
                |> Model.Basics.setCompilerErrorMessage (Just error)
                |> And.doNothing

        RunStart value ->
            let
                event =
                    RunStart.parse value
            in
            model
                |> Model.ProjectName.setFromPath
                |> Model.TestCount.setTotal event
                |> Model.RunSeed.set event
                |> And.doNothing

        TestCompleted data ->
            let
                event =
                    TestCompleted.parseJson data
            in
            model
                |> Model.TestCount.updatePassed event
                |> Model.TestTree.build event
                |> Model.TestTree.updateHierarchy
                |> And.doNothing

        RunComplete value ->
            let
                event =
                    RunComplete.parse value
            in
            model
                |> Model.RunStatus.setToPassing
                |> Model.RunStatus.setForTodo TestInstance.isTodo
                |> Model.RunStatus.setForFailure event
                |> Model.Animation.pulseToStatusColor
                |> Model.RunDuration.set event
                |> Model.TestTree.purgeObsoleteNodes
                |> Model.TestTree.updateHierarchy
                |> Model.TestTree.expandFailingAndTodoNodes
                |> Model.TestTree.selectLastNodeWithFailureData
                |> Model.Animation.initiateStatusBarTextFlicker
                |> And.doNothing


type alias Messages =
    { initiate : Message
    , generate : Message
    , execute : Message
    , compilerError : String -> Message
    , runStart : Value -> Message
    , testCompleted : Value -> Message
    , runComplete : Value -> Message
    }


messages : Messages
messages =
    { initiate = Initiate
    , generate = GenerateTests
    , execute = Execute
    , compilerError = CompilerError
    , runStart = RunStart
    , testCompleted = TestCompleted
    , runComplete = RunComplete
    }


port runTest : ( String, String ) -> Cmd message
