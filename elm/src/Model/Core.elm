module Model.Core
    exposing
        ( Model
        , buildTestRunDataTree
        , clearRunDuration
        , clearRunSeed
        , default
        , expandFailingAndTodoNodes
        , initiateStatusBarTextFlicker
        , purgeObsoleteNodes
        , randomSeedForJS
        , resetPassedTests
        , resetTestRuns
        , serialize
        , setCompilerErrorMessage
        , setPaneLocation
        , setRandomSeed
        , setRandomSeedForcing
        , setRunDuration
        , setRunSeed
        , setSelectedTestInstance
        , setSelectedTestNodeId
        , setTestMouseIsOver
        , setTotalTestCount
        , toggleNode
        , updateFlicker
        , updateHierarchy
        , updatePassedTestCount
        )

import Animation exposing (State)
import Animation.Flicker
import Duration.Core exposing (Duration)
import Model.Flags exposing (Flags)
import Model.ProjectName
import State.PaneLocation as PaneLocation exposing (PaneLocation)
import State.RunStatus as RunStatus exposing (RunStatus)
import TestEvent.RunComplete as RunComplete exposing (RunComplete)
import TestEvent.RunStart as RunStart exposing (RunStart)
import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)
import TestInstance.Core as TestInstance exposing (TestInstance)
import TestInstance.Reconcile
import Tree.Core as Tree exposing (CollapsibleTree, Tree(Node))
import Tree.Merge
import Tree.Node
import Tree.Traverse


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


resetPassedTests : Model -> Model
resetPassedTests model =
    { model | passedTests = 0 }


resetTestRuns : Model -> Model
resetTestRuns model =
    { model
        | testRuns =
            Tree.Traverse.update
                (TestInstance.setStatus "pending")
                model.testRuns
    }


setTotalTestCount : RunStart -> Model -> Model
setTotalTestCount event model =
    { model | totalTests = RunStart.numTotalTests event }


setRunSeed : RunStart -> Model -> Model
setRunSeed event model =
    { model | runSeed = Just <| RunStart.initialSeed event }


clearRunSeed : Model -> Model
clearRunSeed model =
    { model | runSeed = Nothing }


setCompilerErrorMessage : Maybe String -> Model -> Model
setCompilerErrorMessage maybeError model =
    { model | compilerError = maybeError }


updatePassedTestCount : TestCompleted -> Model -> Model
updatePassedTestCount event model =
    { model | passedTests = model.passedTests + TestCompleted.passedTestCountToIncrement event }


buildTestRunDataTree : TestCompleted -> Model -> Model
buildTestRunDataTree event model =
    { model
        | testRuns =
            Tree.Merge.fromPath
                (model.projectName :: TestCompleted.labels event)
                (TestInstance.fromEvent event)
                TestInstance.Reconcile.transform
                model.testRuns
    }


setTestMouseIsOver : Maybe Int -> Model -> Model
setTestMouseIsOver nodeId model =
    { model | testMouseIsOver = nodeId }


setSelectedTestNodeId : Maybe Int -> Model -> Model
setSelectedTestNodeId nodeId model =
    { model | selectedTestNodeId = nodeId }


setSelectedTestInstance : Maybe TestInstance -> Model -> Model
setSelectedTestInstance testInstance model =
    { model | selectedTestInstance = testInstance }


setRunDuration : RunComplete -> Model -> Model
setRunDuration event model =
    { model | runDuration = Just <| RunComplete.duration event }


clearRunDuration : Model -> Model
clearRunDuration model =
    { model | runDuration = Nothing }


purgeObsoleteNodes : Model -> Model
purgeObsoleteNodes model =
    { model
        | testRuns =
            Tree.Traverse.purge
                (not << TestInstance.isPending)
                model.testRuns
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


setRandomSeed : Maybe Int -> Model -> Model
setRandomSeed randomSeed model =
    { model | randomSeed = randomSeed }


setRandomSeedForcing : Bool -> Model -> Model
setRandomSeedForcing setting model =
    { model | forceRandomSeedEnabled = setting }


randomSeedForJS : Model -> String
randomSeedForJS model =
    case ( model.forceRandomSeedEnabled, model.randomSeed ) of
        ( True, Just seed ) ->
            toString seed

        _ ->
            ""


updateFlicker : Animation.Msg -> Model -> Model
updateFlicker animationMessage model =
    { model | statusBarStyle = Animation.update animationMessage model.statusBarStyle }


initiateStatusBarTextFlicker : Model -> Model
initiateStatusBarTextFlicker model =
    { model | statusBarStyle = Animation.Flicker.animation model.statusBarStyle }


setPaneLocation : String -> Model -> Model
setPaneLocation newLocation model =
    { model | paneLocation = PaneLocation.fromString newLocation }
