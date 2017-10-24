module Model.Core
    exposing
        ( Model
        , default
        , expandFailingAndTodoNodes
        , initiateStatusBarTextFlicker
        , serialize
        , toggleNode
        , updateFlicker
        , updateHierarchy
        )

import Animation exposing (State)
import Animation.Flicker
import Duration.Core exposing (Duration)
import Model.Flags exposing (Flags)
import Model.ProjectName
import State.PaneLocation as PaneLocation exposing (PaneLocation)
import State.RunStatus as RunStatus exposing (RunStatus)
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core as Tree exposing (CollapsibleTree, Tree(Node))
import Tree.Node


type alias Model =
    { projectName : String
    , compilerError : Maybe String
    , runStatus : RunStatus
    , totalTests : Int
    , passedTests : Int
    , runDuration : Maybe Duration
    , runSeed : Maybe Int
    , testRuns : Tree String TestInstance
    , testHierarchy : CollapsibleTree String TestInstance
    , testMouseIsOver : Maybe Int
    , selectedTestNodeId : Maybe Int
    , selectedTestInstance : Maybe TestInstance
    , autoRunEnabled : Bool
    , autoNavigateEnabled : Bool
    , randomSeed : Maybe Int
    , forceRandomSeedEnabled : Bool
    , statusBarStyle : State
    , paneLocation : PaneLocation
    }


default : Model
default =
    { projectName = ""
    , compilerError = Nothing
    , runStatus = RunStatus.noData
    , totalTests = 0
    , passedTests = 0
    , runDuration = Nothing
    , runSeed = Nothing
    , testRuns = Node Model.ProjectName.default TestInstance.default []
    , testHierarchy = Tree.make (Node humanReadableTopLevelMessage TestInstance.default [])
    , testMouseIsOver = Nothing
    , selectedTestNodeId = Nothing
    , selectedTestInstance = Nothing
    , autoRunEnabled = False
    , autoNavigateEnabled = True
    , randomSeed = Nothing
    , forceRandomSeedEnabled = False
    , statusBarStyle = Animation.Flicker.initial
    , paneLocation = PaneLocation.default
    }


humanReadableTopLevelMessage : String
humanReadableTopLevelMessage =
    "No Tests"


serialize : Model -> Flags
serialize model =
    { autoRun = model.autoRunEnabled
    , autoNavigate = model.autoNavigateEnabled
    }


updateHierarchy : Model -> Model
updateHierarchy model =
    { model
        | testHierarchy =
            model.testRuns
                |> Tree.make
    }


expandFailingAndTodoNodes : Model -> Model
expandFailingAndTodoNodes model =
    { model | testHierarchy = toggleFailingAndTodoNodes model.testHierarchy }


toggleFailingAndTodoNodes : CollapsibleTree String TestInstance -> CollapsibleTree String TestInstance
toggleFailingAndTodoNodes (Node ( name, _, nodeId ) testInstance children) =
    let
        expanded =
            TestInstance.isFailing testInstance || TestInstance.isTodo testInstance
    in
    Node ( name, expanded, nodeId ) testInstance <|
        List.map toggleFailingAndTodoNodes children


toggleNode : Int -> Bool -> Model -> Model
toggleNode nodeId newState model =
    { model | testHierarchy = Tree.Node.toggle nodeId newState model.testHierarchy }


updateFlicker : Animation.Msg -> Model -> Model
updateFlicker animationMessage model =
    { model | statusBarStyle = Animation.update animationMessage model.statusBarStyle }


initiateStatusBarTextFlicker : Model -> Model
initiateStatusBarTextFlicker model =
    { model | statusBarStyle = Animation.Flicker.animation model.statusBarStyle }
