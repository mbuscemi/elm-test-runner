port module Main exposing (main)

import And
import Animation
import Bind
import Html exposing (Html)
import Json.Encode exposing (Value)
import Message.Animate as Animate
import Message.TestListItem as TestListItem
import Model exposing (Model)
import Model.Animation
import Model.Basics
import Model.Config
import Model.Flags as Flags
import Model.ProjectName
import Model.RandomSeed
import Model.RunDuration
import Model.RunSeed
import Model.RunStatus
import Model.SelectedTest
import Model.TestCount
import Model.TestTree
import TestEvent.RunComplete as RunComplete
import TestEvent.RunStart as RunStart
import TestEvent.TestCompleted as TestCompleted
import TestInstance.Core as TestInstance exposing (TestInstance)
import TestInstance.View
import View


type Message
    = InitiateRunAll
    | GenerateTestsStart
    | ExecuteTestsStart
    | CompilerErrored String
    | RunStart ( String, Value )
    | TestCompleted Value
    | RunComplete Value
    | TestListItem TestListItem.Message
    | ToggleAutoRun
    | SetAutoRun Bool
    | ToggleAutoNavigate
    | SetAutoNavigate Bool
    | ToggleRunElmVerifyExamples
    | SetRunElmVerifyExamples Bool
    | CopySeed String
    | SetRandomSeed Int
    | SetForceSeed Bool
    | Animate Animate.Message
    | PaneMoved String
    | ToggleSettings
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
        |> Model.Config.setElmVerifyExamples flags.useElmVerifyExamples
        |> And.doNothing


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        InitiateRunAll ->
            Model.TestCount.resetPassed model
                |> Model.SelectedTest.setNodeId Nothing
                |> Model.SelectedTest.setInstance Nothing
                |> Model.Basics.setCompilerErrorMessage Nothing
                |> Model.RunDuration.clear
                |> Model.RunSeed.clear
                |> Model.TestTree.reset
                |> Model.TestTree.updateHierarchy
                |> And.execute (runTest <| Model.RandomSeed.forJS model)

        GenerateTestsStart ->
            Model.RunStatus.setToGeneratingTests model
                |> Model.Animation.initiateColorOscillation
                |> And.doNothing

        ExecuteTestsStart ->
            Model.RunStatus.setToProcessing model
                |> Model.Animation.initiateColorOscillation
                |> And.doNothing

        CompilerErrored errorMessage ->
            Model.RunStatus.setToCompileError model
                |> Model.Animation.pulseToStatusColor
                |> Model.Basics.setCompilerErrorMessage (Just errorMessage)
                |> And.doNothing

        RunStart ( projectPath, value ) ->
            let
                event =
                    RunStart.parse value
            in
            Model.ProjectName.setFromPath projectPath model
                |> Model.TestCount.setTotal event
                |> Model.RunSeed.set event
                |> And.doNothing

        TestCompleted data ->
            let
                event =
                    TestCompleted.parseJson data
            in
            Model.TestCount.updatePassed event model
                |> Model.TestTree.build event
                |> Model.TestTree.updateHierarchy
                |> And.doNothing

        RunComplete value ->
            let
                event =
                    RunComplete.parse value
            in
            Model.RunStatus.setToPassing model
                |> Model.RunStatus.setForTodo TestInstance.isTodo
                |> Model.RunStatus.setForFailure event
                |> Model.Animation.pulseToStatusColor
                |> Model.RunDuration.set event
                |> Model.TestTree.purgeObsoleteNodes
                |> Model.TestTree.updateHierarchy
                |> Model.TestTree.expandFailingAndTodoNodes
                |> Model.Animation.initiateStatusBarTextFlicker
                |> And.doNothing

        TestListItem message ->
            TestListItem.update message model

        ToggleAutoRun ->
            Model.Config.invertAutoRun model
                |> And.updateAtomState

        SetAutoRun state ->
            Model.Config.setAutoRun state model
                |> And.updateAtomState

        ToggleAutoNavigate ->
            Model.Config.invertAutoNavigate model
                |> And.updateAtomState

        SetAutoNavigate state ->
            Model.Config.setAutoNavigate state model
                |> And.updateAtomState

        ToggleRunElmVerifyExamples ->
            Model.Config.invertElmVerifyExamples model
                |> And.updateAtomState

        SetRunElmVerifyExamples state ->
            Model.Config.setElmVerifyExamples state model
                |> And.updateAtomState

        CopySeed seed ->
            model
                |> And.execute (copySeed seed)

        SetRandomSeed seed ->
            Model.RandomSeed.set (Just seed) model
                |> Model.RandomSeed.setForcing True
                |> And.doNothing

        SetForceSeed setting ->
            Model.RandomSeed.setForcing setting model
                |> And.doNothing

        Animate message ->
            Animate.update message model

        PaneMoved newLocation ->
            Model.Basics.setPaneLocation newLocation model
                |> And.doNothing

        ToggleSettings ->
            Model.Animation.toggleFooter model
                |> And.doNothing

        DoNothing ->
            model |> And.doNothing


view : Model -> Html Message
view model =
    View.render
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
        , elmVerifyExamplesEnabled = model.runElmVerifyExamplesEnabled
        , randomSeed = model.randomSeed
        , forceRandomSeedEnabled = model.forceRandomSeedEnabled
        , statusBarTextStyle = model.statusBarTextStyle
        , statusBarColorStyle = model.statusBarColorStyle
        , footerStyle = model.footerStyle
        , paneLocation = model.paneLocation
        }
        { runAllButtonClickHandler = InitiateRunAll
        , testListItemExpand = Bind.arity1 TestListItem (.expand TestListItem.messages)
        , testListItemCollapse = Bind.arity1 TestListItem (.collapse TestListItem.messages)
        , testListItemMouseEnter = Bind.arity1 TestListItem (.mouseEnter TestListItem.messages)
        , testListItemMouseLeave = Bind.arity0 TestListItem (.mouseLeave TestListItem.messages)
        , testClickHandler = Bind.arity2 TestListItem (.select TestListItem.messages)
        , copySeedClickHandler = CopySeed
        , setSeedClickHandler = SetRandomSeed
        , setForceSeedHandler = SetForceSeed
        , setAutoRun = SetAutoRun
        , setAutoNavigate = SetAutoNavigate
        , setRunElmVerifyExamples = SetRunElmVerifyExamples
        , settingsToggle = ToggleSettings
        }


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ commandKeyTestStart (always InitiateRunAll)
        , notifyGeneratingTests (always GenerateTestsStart)
        , notifyExecutingTests (always ExecuteTestsStart)
        , notifyCompilerErrored CompilerErrored
        , toggleAutoRun (always ToggleAutoRun)
        , toggleAutoNavigate (always ToggleAutoNavigate)
        , toggleElmVerifyExamples (always ToggleRunElmVerifyExamples)
        , notifySaveEvent <| saveEventMessage model
        , notifyPaneMoved PaneMoved
        , runStart RunStart
        , testCompleted TestCompleted
        , runComplete RunComplete
        , Animation.subscription (Bind.arity1 Animate <| .flicker Animate.messages) [ model.statusBarTextStyle ]
        , Animation.subscription (Bind.arity1 Animate <| .oscillateColor Animate.messages) [ model.statusBarColorStyle ]
        , Animation.subscription (Bind.arity1 Animate <| .settingsTransition Animate.messages) [ model.footerStyle ]
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


port notifyGeneratingTests : (() -> message) -> Sub message


port notifyExecutingTests : (() -> message) -> Sub message


port notifyCompilerErrored : (String -> message) -> Sub message


port toggleAutoRun : (() -> message) -> Sub message


port toggleAutoNavigate : (() -> message) -> Sub message


port toggleElmVerifyExamples : (() -> message) -> Sub message


port notifySaveEvent : (() -> message) -> Sub message


port notifyPaneMoved : (String -> message) -> Sub message


port runStart : (( String, Value ) -> message) -> Sub message


port testCompleted : (Value -> message) -> Sub message


port runComplete : (Value -> message) -> Sub message
