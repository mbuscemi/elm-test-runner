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


type alias Model model testInstance =
    { model
        | runStatus : RunStatus
        , testRuns : Tree String testInstance
    }


setToGeneratingTests : Model model testInstance -> Model model testInstance
setToGeneratingTests model =
    { model | runStatus = RunStatus.generatingTests }


setToProcessing : Model model testInstance -> Model model testInstance
setToProcessing model =
    { model | runStatus = RunStatus.processing }


setToPassing : Model model testInstance -> Model model testInstance
setToPassing model =
    { model | runStatus = RunStatus.lastPassed }


setForFailure : RunComplete -> Model model testInstance -> Model model testInstance
setForFailure event model =
    { model
        | runStatus =
            if not <| RunComplete.passed event then
                RunStatus.lastFailed
            else
                model.runStatus
    }


setForTodo : (testInstance -> Bool) -> Model model testInstance -> Model model testInstance
setForTodo isTodo model =
    { model
        | runStatus =
            if Tree.Traverse.hasMatchingNode isTodo model.testRuns then
                RunStatus.incomplete
            else
                model.runStatus
    }


setToCompileError : Model model testInstance -> Model model testInstance
setToCompileError model =
    { model | runStatus = RunStatus.compileError }
