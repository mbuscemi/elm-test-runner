module Model.Model exposing (Model, buildTestRunDataTree, default, resetPassedTests, setRunStatusToCompileError, setRunStatusToPassFail, setRunStatusToProcessing, setTotalTestCount, updatePassedTestCount)

import State.RunStatus as RunStatus exposing (RunStatus)
import TestEvent.RunComplete as RunComplete exposing (RunComplete)
import TestEvent.RunStart as RunStart exposing (RunStart)
import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)
import Tree.Merge
import Tree.Tree exposing (CollapsibleTree, Tree(Node))


type alias Model =
    { runStatus : RunStatus
    , totalTests : Int
    , passedTests : Int
    , testRuns : Tree String
    }


default : Model
default =
    { runStatus = RunStatus.noData
    , totalTests = 0
    , passedTests = 0
    , testRuns = Node topLevelMessage []
    }


topLevelMessage : String
topLevelMessage =
    "::Root::"


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


setTotalTestCount : RunStart -> Model -> Model
setTotalTestCount event model =
    { model | totalTests = RunStart.numTotalTests event }


updatePassedTestCount : TestCompleted -> Model -> Model
updatePassedTestCount event model =
    { model | passedTests = model.passedTests + TestCompleted.passedTestCountToIncrement event }


buildTestRunDataTree : TestCompleted -> Model -> Model
buildTestRunDataTree event model =
    { model
        | testRuns =
            Tree.Merge.fromPath
                (topLevelMessage :: TestCompleted.labels event)
                model.testRuns
    }
