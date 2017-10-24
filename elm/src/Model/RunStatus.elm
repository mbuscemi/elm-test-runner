module Model.RunStatus exposing (setForFailure, setForTodo, setToCompileError, setToPassing, setToProcessing)

import State.RunStatus as RunStatus exposing (RunStatus)
import TestEvent.RunComplete as RunComplete exposing (RunComplete)
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core exposing (Tree)
import Tree.Traverse


type alias HasRunStatus r =
    { r
        | runStatus : RunStatus
        , testRuns : Tree String TestInstance
    }


setToProcessing : HasRunStatus model -> HasRunStatus model
setToProcessing model =
    { model | runStatus = RunStatus.processing }


setToPassing : HasRunStatus model -> HasRunStatus model
setToPassing model =
    { model | runStatus = RunStatus.lastPassed }


setForFailure : RunComplete -> HasRunStatus model -> HasRunStatus model
setForFailure event model =
    { model
        | runStatus =
            if not <| RunComplete.passed event then
                RunStatus.lastFailed
            else
                model.runStatus
    }


setForTodo : HasRunStatus model -> HasRunStatus model
setForTodo model =
    { model
        | runStatus =
            if Tree.Traverse.hasMatchingNode TestInstance.isTodo model.testRuns then
                RunStatus.incomplete
            else
                model.runStatus
    }


setToCompileError : HasRunStatus model -> HasRunStatus model
setToCompileError model =
    { model | runStatus = RunStatus.compileError }
