module Model.Config exposing (HasConfig, invertAutoNavigate, invertAutoRun, invertElmVerifyExamples, serialize, setAutoNavigate, setAutoRun, setElmVerifyExamples)

import Model.Flags exposing (Flags)


type alias HasConfig r =
    { r
        | autoRunEnabled : Bool
        , autoNavigateEnabled : Bool
        , runElmVerifyExamplesEnabled : Bool
    }


invertAutoRun : HasConfig model -> HasConfig model
invertAutoRun model =
    { model | autoRunEnabled = not model.autoRunEnabled }


setAutoRun : Bool -> HasConfig model -> HasConfig model
setAutoRun setting model =
    { model | autoRunEnabled = setting }


invertAutoNavigate : HasConfig model -> HasConfig model
invertAutoNavigate model =
    { model | autoNavigateEnabled = not model.autoNavigateEnabled }


setAutoNavigate : Bool -> HasConfig model -> HasConfig model
setAutoNavigate setting model =
    { model | autoNavigateEnabled = setting }


invertElmVerifyExamples : HasConfig model -> HasConfig model
invertElmVerifyExamples model =
    { model | runElmVerifyExamplesEnabled = not model.runElmVerifyExamplesEnabled }


setElmVerifyExamples : Bool -> HasConfig model -> HasConfig model
setElmVerifyExamples setting model =
    { model | runElmVerifyExamplesEnabled = setting }


serialize : HasConfig model -> Flags
serialize model =
    { autoRun = model.autoRunEnabled
    , autoNavigate = model.autoNavigateEnabled
    , useElmVerifyExamples = model.runElmVerifyExamplesEnabled
    }
