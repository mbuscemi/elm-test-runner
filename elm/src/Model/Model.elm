module Model.Model exposing (Model, TestRuns, buildTestRunDataTree, default, resetPassedTests, setRunStatusToCompileError, setRunStatusToPassFail, setRunStatusToProcessing, setTotalTestCount, toTree, updatePassedTestCount)

import Dict exposing (Dict)
import State.RunStatus as RunStatus exposing (RunStatus)
import TestEvent.RunComplete as RunComplete exposing (RunComplete)
import TestEvent.RunStart as RunStart exposing (RunStart)
import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)
import Tree.Tree exposing (CollapsibleTree, Tree(Node))


-- type alias TestRun =
--     { name : String, pass : Bool }


type TestRuns
    = TestRuns (Dict String TestRuns)


type alias Model =
    { runStatus : RunStatus
    , totalTests : Int
    , passedTests : Int
    , testRuns : TestRuns
    }


default : Model
default =
    { runStatus = RunStatus.noData
    , totalTests = 0
    , passedTests = 0
    , testRuns = TestRuns Dict.empty
    }


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
    { model | testRuns = Debug.log "nodes" (buildNodes (TestCompleted.labels event) (TestCompleted.passed event) model.testRuns) }


buildNodes : List String -> Bool -> TestRuns -> TestRuns
buildNodes labels passed (TestRuns dict) =
    List.foldl
        (\label (TestRuns dict) ->
            case Dict.get label dict of
                Just testRuns ->
                    testRuns

                Nothing ->
                    TestRuns (Dict.insert label (TestRuns Dict.empty) dict)
        )
        (TestRuns dict)
        labels


toTree : TestRuns -> Tree String
toTree (TestRuns dict) =
    Node ""
        (Dict.foldr
            toLeaf
            []
            dict
        )


toLeaf : String -> TestRuns -> List (Tree String) -> List (Tree String)
toLeaf key testRuns list =
    Node key [ toTree testRuns ] :: list



-- adjustNode : String -> TestRuns -> TestRuns
-- adjustNode label (TestRuns dict) =
--     if Dict.member label dict then
--         TestRuns dict
--     else
--         TestRuns (Dict.insert label (TestRuns Dict.empty) dict)
-- buildNodes : List String -> Tree TestRun -> Tree TestRun
-- buildNodes labels tree =
--     let
--         invertedLabels =
--             List.reverse labels
--
--         (firstLabel :: rest) =
--             invertedLabels
--
--         firstNode =
--             Node { name = firstLabel, passed = True } []
--     in
--     List.foldr
--         (\label tree ->
--             tree
--         )
--         tree
--         labels
