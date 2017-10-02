module Model.Model exposing (Model, default, setRunStatusToPassFail, setRunStatusToProcessing)

import State.RunStatus as RunStatus exposing (RunStatus)
import TestEvent.RunComplete as RunComplete exposing (RunComplete)


type alias Model =
    { runStatus : RunStatus }


default : Model
default =
    { runStatus = RunStatus.noData }


setRunStatusToProcessing : Model -> Model
setRunStatusToProcessing model =
    { model | runStatus = RunStatus.processing }


setRunStatusToPassFail : RunComplete -> Model -> Model
setRunStatusToPassFail event model =
    { model | runStatus = RunStatus.passFail <| RunComplete.passed event }
