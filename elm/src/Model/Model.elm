module Model.Model exposing (Model, default, resetPassedTests, setRunStatusToPassFail, setRunStatusToProcessing, setTotalTestCount)

import State.RunStatus as RunStatus exposing (RunStatus)
import TestEvent.RunComplete as RunComplete exposing (RunComplete)
import TestEvent.RunStart as RunStart exposing (RunStart)


type alias Model =
    { runStatus : RunStatus
    , totalTests : Int
    , passedTests : Int
    }


default : Model
default =
    { runStatus = RunStatus.noData
    , totalTests = 0
    , passedTests = 0
    }


setRunStatusToProcessing : Model -> Model
setRunStatusToProcessing model =
    { model | runStatus = RunStatus.processing }


setRunStatusToPassFail : RunComplete -> Model -> Model
setRunStatusToPassFail event model =
    { model | runStatus = RunStatus.passFail <| RunComplete.passed event }


resetPassedTests : Model -> Model
resetPassedTests model =
    { model | passedTests = 0 }


setTotalTestCount : RunStart -> Model -> Model
setTotalTestCount event model =
    { model | totalTests = RunStart.numTotalTests event }
