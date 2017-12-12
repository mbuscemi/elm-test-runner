port module Main exposing (main)

import And
import Animation
import Html exposing (Html)
import Json.Encode exposing (Value)
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
import View.Core


type Message
    = InitiateRunAll
    | GenerateTestsStart
    | ExecuteTestsStart
    | CompilerErrored String
    | RunStart ( String, Value )
    | TestCompleted Value
    | RunComplete Value
    | TestListItemExpand Int
    | TestListItemCollapse Int
    | TestListItemMouseEnter Int
    | TestListItemMouseLeave
    | TestListItemSelect Int (Maybe TestInstance)
    | ToggleAutoRun
    | SetAutoRun Bool
    | ToggleAutoNavigate
    | SetAutoNavigate Bool
    | ToggleRunElmVerifyExamples
    | SetRunElmVerifyExamples Bool
    | CopySeed String
    | SetRandomSeed Int
    | SetForceSeed Bool
    | AnimateFlicker Animation.Msg
    | AnimateProcessingColorOscillate Animation.Msg
    | AnimateSettingsTransition Animation.Msg
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

        TestListItemExpand nodeId ->
            Model.TestTree.toggleNode nodeId True model
                |> And.doNothing

        TestListItemCollapse nodeId ->
            Model.TestTree.toggleNode nodeId False model
                |> And.doNothing

        TestListItemMouseEnter nodeId ->
            Model.Basics.setTestMouseIsOver (Just nodeId) model
                |> And.doNothing

        TestListItemMouseLeave ->
            Model.Basics.setTestMouseIsOver Nothing model
                |> And.doNothing

        TestListItemSelect nodeId testInstance ->
            Model.SelectedTest.setNodeId (Just nodeId) model
                |> Model.SelectedTest.setInstance testInstance
                |> Model.SelectedTest.showInEditor testInstance model.autoNavigateEnabled

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

        AnimateFlicker animateMessage ->
            Model.Animation.updateStatusBarText animateMessage model
                |> And.doNothing

        AnimateProcessingColorOscillate animateMessage ->
            Model.Animation.updateStatusBarColor animateMessage model
                |> And.doNothing

        AnimateSettingsTransition animateMessage ->
            Model.Animation.updateFooter animateMessage model
                |> And.doNothing

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
        , elmVerifyExamplesEnabled = model.runElmVerifyExamplesEnabled
        , randomSeed = model.randomSeed
        , forceRandomSeedEnabled = model.forceRandomSeedEnabled
        , statusBarTextStyle = model.statusBarTextStyle
        , statusBarColorStyle = model.statusBarColorStyle
        , footerStyle = model.footerStyle
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
        , Animation.subscription AnimateFlicker [ model.statusBarTextStyle ]
        , Animation.subscription AnimateProcessingColorOscillate [ model.statusBarColorStyle ]
        , Animation.subscription AnimateSettingsTransition [ model.footerStyle ]
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
