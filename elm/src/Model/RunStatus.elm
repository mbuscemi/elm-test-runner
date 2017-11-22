module Model.RunStatus
    exposing
        ( setForFailure
        , setForTodo
        , setToCompileError
        , setToGeneratingTests
        , setToPassing
        , setToProcessing
        )

import State.RunStatus as RunStatus exposing (RunStatus)
import TestEvent.RunComplete as RunComplete exposing (RunComplete)
import Tree.Core exposing (Tree)
import Tree.Traverse


type alias HasRunStatus model testInstance =
    { model
        | runStatus : RunStatus
        , testRuns : Tree String testInstance
    }


setToGeneratingTests : HasRunStatus model testInstance -> HasRunStatus model testInstance
setToGeneratingTests model =
    { model | runStatus = RunStatus.generatingTests }


setToProcessing : HasRunStatus model testInstance -> HasRunStatus model testInstance
setToProcessing model =
    { model | runStatus = RunStatus.processing }


setToPassing : HasRunStatus model testInstance -> HasRunStatus model testInstance
setToPassing model =
    { model | runStatus = RunStatus.lastPassed }


setForFailure : RunComplete -> HasRunStatus model testInstance -> HasRunStatus model testInstance
setForFailure event model =
    { model
        | runStatus =
            if not <| RunComplete.passed event then
                RunStatus.lastFailed
            else
                model.runStatus
    }


setForTodo : (testInstance -> Bool) -> HasRunStatus model testInstance -> HasRunStatus model testInstance
setForTodo isTodo model =
    { model
        | runStatus =
            if Tree.Traverse.hasMatchingNode isTodo model.testRuns then
                RunStatus.incomplete
            else
                model.runStatus
    }


setToCompileError : HasRunStatus model testInstance -> HasRunStatus model testInstance
setToCompileError model =
    { model | runStatus = RunStatus.compileError }
