port module Main exposing (main)

import And
import Animation
import Bind
import Html exposing (Html)
import Json.Encode exposing (Value)
import Message.Animate as Animate
import Message.Settings as Settings
import Message.TestListItem as TestListItem
import Message.TestRun as TestRun
import Model exposing (Model)
import Model.Animation
import Model.Basics
import Model.Config
import Model.Flags as Flags
import Model.RandomSeed
import TestInstance.Core as TestInstance exposing (TestInstance)
import TestInstance.View
import View


type Message
    = TestRun TestRun.Message
    | TestListItem TestListItem.Message
    | Settings Settings.Message
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
        TestRun message ->
            TestRun.update message model

        TestListItem message ->
            TestListItem.update message model

        Settings message ->
            Settings.update message model

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
        { runAllButtonClickHandler = Bind.arity0 TestRun (.initiate TestRun.messages)
        , testListItemExpand = Bind.arity1 TestListItem (.expand TestListItem.messages)
        , testListItemCollapse = Bind.arity1 TestListItem (.collapse TestListItem.messages)
        , testListItemMouseEnter = Bind.arity1 TestListItem (.mouseEnter TestListItem.messages)
        , testListItemMouseLeave = Bind.arity0 TestListItem (.mouseLeave TestListItem.messages)
        , testClickHandler = Bind.arity2 TestListItem (.select TestListItem.messages)
        , copySeedClickHandler = CopySeed
        , setSeedClickHandler = SetRandomSeed
        , setForceSeedHandler = SetForceSeed
        , setAutoRun = Bind.arity1 Settings (.set <| .autoRun Settings.messages)
        , setAutoNavigate = Bind.arity1 Settings (.set <| .autoNavigate Settings.messages)
        , setRunElmVerifyExamples = Bind.arity1 Settings (.set <| .runElmVerifyExamples Settings.messages)
        , settingsToggle = ToggleSettings
        }


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ commandKeyTestStart (always <| Bind.arity0 TestRun (.initiate TestRun.messages))
        , notifyGeneratingTests (always <| Bind.arity0 TestRun (.generate TestRun.messages))
        , notifyExecutingTests (always <| Bind.arity0 TestRun (.execute TestRun.messages))
        , notifyCompilerErrored <| Bind.arity1 TestRun (.compilerError TestRun.messages)
        , toggleAutoRun (always <| Bind.arity0 Settings (.toggle <| .autoRun Settings.messages))
        , toggleAutoNavigate (always <| Bind.arity0 Settings (.toggle <| .autoNavigate Settings.messages))
        , toggleElmVerifyExamples (always <| Bind.arity0 Settings (.toggle <| .runElmVerifyExamples Settings.messages))
        , notifySaveEvent <| saveEventMessage model
        , notifyPaneMoved PaneMoved
        , runStart <| Bind.arity1 TestRun (.runStart TestRun.messages)
        , testCompleted <| Bind.arity1 TestRun (.testCompleted TestRun.messages)
        , runComplete <| Bind.arity1 TestRun (.runComplete TestRun.messages)
        , Animation.subscription (Bind.arity1 Animate <| .flicker Animate.messages) [ model.statusBarTextStyle ]
        , Animation.subscription (Bind.arity1 Animate <| .oscillateColor Animate.messages) [ model.statusBarColorStyle ]
        , Animation.subscription (Bind.arity1 Animate <| .settingsTransition Animate.messages) [ model.footerStyle ]
        ]


saveEventMessage : Model -> () -> Message
saveEventMessage model _ =
    if model.autoRunEnabled then
        Bind.arity0 TestRun (.initiate TestRun.messages)
    else
        DoNothing


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
