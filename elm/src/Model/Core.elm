module Model.Core
    exposing
        ( Model
        , buildTestRunDataTree
        , default
        , purgeObsoleteNodes
        , resetPassedTests
        , resetTestRuns
        , setRunStatusToCompileError
        , setRunStatusToPassFail
        , setRunStatusToProcessing
        , setTotalTestCount
        , toggleNode
        , updateHierarchy
        , updatePassedTestCount
        )

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
    , testRuns : Tree String TestInstance
    , testHierarchy : CollapsibleTree String TestInstance
    }


default : Model
default =
    { runStatus = RunStatus.noData
    , totalTests = 0
    , passedTests = 0
    , testRuns = Node systemTopLevelMessage TestInstance.default []
    , testHierarchy = Tree.make (Node humanReadableTopLevelMessage TestInstance.default [])
    }


systemTopLevelMessage : String
systemTopLevelMessage =
    "::Root::"


humanReadableTopLevelMessage : String
humanReadableTopLevelMessage =
    "No Tests"


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
