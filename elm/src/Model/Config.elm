module Model.Config exposing (invertAutoNavigate, invertAutoRun, setAutoNavigate, setAutoRun, setElmVerifyExamples)


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


setElmVerifyExamples : Bool -> HasConfig model -> HasConfig model
setElmVerifyExamples setting model =
    { model | runElmVerifyExamplesEnabled = setting }
