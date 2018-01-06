port module Main exposing (main)

import And
import Animation
import Function exposing ((<<<))
import Html exposing (Html)
import Json.Encode exposing (Value)
import Message.Animate as Animate
import Message.Directories as Directories
import Message.RandomSeed as RandomSeed
import Message.Settings as Settings
import Message.TestListItem as TestListItem
import Message.TestRun as TestRun
import Model exposing (Model)
import Model.Animation
import Model.Basics
import Model.Config
import Model.Flags as Flags
import TestInstance.Core as TestInstance
import TestInstance.View
import View


type Message
    = TestRun TestRun.Message
    | TestListItem TestListItem.Message
    | Settings Settings.Message
    | RandomSeed RandomSeed.Message
    | Animate Animate.Message
    | Directories Directories.Message
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
        TestRun message ->
            if model.hasRegisteredDirectories then
                TestRun.update message model
            else
                And.executeOnDelay (TestRun message) model

        TestListItem message ->
            TestListItem.update message model

        Settings message ->
            Settings.update message model

        RandomSeed message ->
            RandomSeed.update message model

        Animate message ->
            Animate.update message model

        Directories message ->
            Directories.update message model

        PaneMoved newLocation ->
            model
                |> Model.Basics.setPaneLocation newLocation
                |> And.doNothing

        ToggleSettings ->
            model
                |> Model.Animation.toggleFooter
                |> And.doNothing

        DoNothing ->
            model
                |> And.doNothing


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
        , projectDirectories = model.projectDirectories
        , testableElmDirectories = model.testableElmDirectories
        }
        { runAllButtonClickHandler = TestRun <| .initiate TestRun.messages
        , testListItemExpand = TestListItem << .expand TestListItem.messages
        , testListItemCollapse = TestListItem << .collapse TestListItem.messages
        , testListItemMouseEnter = TestListItem << .mouseEnter TestListItem.messages
        , testListItemMouseLeave = TestListItem <| .mouseLeave TestListItem.messages
        , testClickHandler = TestListItem <<< .select TestListItem.messages
        , copySeedClickHandler = RandomSeed << .copy RandomSeed.messages
        , setSeedClickHandler = RandomSeed << .set RandomSeed.messages
        , setForceSeedHandler = RandomSeed << .setForce RandomSeed.messages
        , setAutoRun = Settings << (.set <| .autoRun Settings.messages)
        , setAutoNavigate = Settings << (.set <| .autoNavigate Settings.messages)
        , setRunElmVerifyExamples = Settings << (.set <| .runElmVerifyExamples Settings.messages)
        , settingsToggle = ToggleSettings
        , workingDirectoryChanged = Directories << .changeWorking Directories.messages
        }


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ commandKeyTestStart <| always <| TestRun <| .initiate TestRun.messages
        , notifyGeneratingTests <| always <| TestRun <| .generate TestRun.messages
        , notifyExecutingTests <| always <| TestRun <| .execute TestRun.messages
        , notifyCompilerErrored <| TestRun << .compilerError TestRun.messages
        , toggleAutoRun <| always <| Settings <| .toggle <| .autoRun Settings.messages
        , toggleAutoNavigate <| always <| Settings <| .toggle <| .autoNavigate Settings.messages
        , toggleElmVerifyExamples <| always <| Settings <| .toggle <| .runElmVerifyExamples Settings.messages
        , notifySaveEvent <| saveEventMessage model
        , notifyPaneMoved PaneMoved
        , runStart <| TestRun << .runStart TestRun.messages
        , testCompleted <| TestRun << .testCompleted TestRun.messages
        , runComplete <| TestRun << .runComplete TestRun.messages
        , updateProjectDirectories <| Directories << .updateProject Directories.messages
        , updateTestableElmDirectories <| Directories << .updateTestable Directories.messages
        , Animation.subscription (Animate << .flicker Animate.messages) [ model.statusBarTextStyle ]
        , Animation.subscription (Animate << .oscillateColor Animate.messages) [ model.statusBarColorStyle ]
        , Animation.subscription (Animate << .settingsTransition Animate.messages) [ model.footerStyle ]
        ]


saveEventMessage : Model -> () -> Message
saveEventMessage model _ =
    if model.autoRunEnabled then
        TestRun <| .initiate TestRun.messages
    else
        DoNothing


port commandKeyTestStart : (() -> message) -> Sub message


port notifyGeneratingTests : (() -> message) -> Sub message


port notifyExecutingTests : (() -> message) -> Sub message


port notifyCompilerErrored : (String -> message) -> Sub message


port toggleAutoRun : (() -> message) -> Sub message


port toggleAutoNavigate : (() -> message) -> Sub message


port toggleElmVerifyExamples : (() -> message) -> Sub message


port notifySaveEvent : (() -> message) -> Sub message


port notifyPaneMoved : (String -> message) -> Sub message


port runStart : (Value -> message) -> Sub message


port testCompleted : (Value -> message) -> Sub message


port runComplete : (Value -> message) -> Sub message


port updateProjectDirectories : (List String -> message) -> Sub message


port updateTestableElmDirectories : (List String -> message) -> Sub message
