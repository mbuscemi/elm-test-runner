module Model.Core
    exposing
        ( Model
        , buildTestRunDataTree
        , clearRunDuration
        , clearRunSeed
        , default
        , invertAutoRun
        , purgeObsoleteNodes
        , resetPassedTests
        , resetTestRuns
        , setRandomSeed
        , setRunDuration
        , setRunSeed
        , setRunStatusToCompileError
        , setRunStatusToPassFail
        , setRunStatusToProcessing
        , setSelectedTest
        , setSelectedTestFailure
        , setTestMouseIsOver
        , setTotalTestCount
        , toggleNode
        , updateHierarchy
        , updatePassedTestCount
        )

import Duration.Core exposing (Duration)
import State.Failure exposing (Failure)
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
    { runStatus : RunStatus
    , totalTests : Int
    , passedTests : Int
    , runDuration : Maybe Duration
    , runSeed : Maybe Int
    , testRuns : Tree String TestInstance
    , testHierarchy : CollapsibleTree String TestInstance
    , testMouseIsOver : Maybe Int
    , selectedTest : Maybe Int
    , selectedTestFailure : Maybe Failure
    , autoRunEnabled : Bool
    , randomSeed : Maybe Int
    }


default : Model
default =
    { runStatus = RunStatus.noData
    , totalTests = 0
    , passedTests = 0
    , runDuration = Nothing
    , runSeed = Nothing
    , testRuns = Node systemTopLevelMessage TestInstance.default []
    , testHierarchy = Tree.make (Node humanReadableTopLevelMessage TestInstance.default [])
    , testMouseIsOver = Nothing
    , selectedTest = Nothing
    , selectedTestFailure = Nothing
    , autoRunEnabled = False
    , randomSeed = Nothing
    }


systemTopLevelMessage : String
systemTopLevelMessage =
    "::Root::"


humanReadableTopLevelMessage : String
humanReadableTopLevelMessage =
    "No Tests"


invertAutoRun : Model -> Model
invertAutoRun model =
    { model | autoRunEnabled = not model.autoRunEnabled }


setRunStatusToProcessing : Model -> Model
setRunStatusToProcessing model =
    { model | runStatus = RunStatus.processing }


setRunStatusToPassFail : RunComplete -> Model -> Model
setRunStatusToPassFail event model =
    { model | runStatus = RunStatus.passFail <| RunComplete.passed event }


setRunStatusToCompileError : Model -> Model
setRunStatusToCompileError model =
    { model | runStatus = RunStatus.compileError }


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


updatePassedTestCount : TestCompleted -> Model -> Model
updatePassedTestCount event model =
    { model | passedTests = model.passedTests + TestCompleted.passedTestCountToIncrement event }


buildTestRunDataTree : TestCompleted -> Model -> Model
buildTestRunDataTree event model =
    { model
        | testRuns =
            Tree.Merge.fromPath
                (systemTopLevelMessage :: TestCompleted.labels event)
                (TestCompleted.toTestInstance event)
                TestInstance.Reconcile.transform
                model.testRuns
    }


setTestMouseIsOver : Maybe Int -> Model -> Model
setTestMouseIsOver nodeId model =
    { model | testMouseIsOver = nodeId }


setSelectedTest : Maybe Int -> Model -> Model
setSelectedTest nodeId model =
    { model | selectedTest = nodeId }


setSelectedTestFailure : Maybe Failure -> Model -> Model
setSelectedTestFailure failure model =
    { model | selectedTestFailure = failure }


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
                |> removeTopNode
                |> Tree.make
    }


removeTopNode : Tree String b -> Tree String b
removeTopNode node =
    case node of
        Node _ _ (first :: _) ->
            first

        Node _ data [] ->
            Node humanReadableTopLevelMessage data []


toggleNode : Int -> Bool -> Model -> Model
toggleNode nodeId newState model =
    { model | testHierarchy = Tree.Node.toggle nodeId newState model.testHierarchy }


setRandomSeed : Maybe Int -> Model -> Model
setRandomSeed randomSeed model =
    { model | randomSeed = randomSeed }
