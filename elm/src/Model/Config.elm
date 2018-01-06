module Model.Config exposing (Model, invertAutoNavigate, invertAutoRun, invertElmVerifyExamples, serialize, setAutoNavigate, setAutoRun, setElmVerifyExamples)

import Model.Flags exposing (Flags)


type alias Model model =
    { model
        | autoRunEnabled : Bool
        , autoNavigateEnabled : Bool
        , runElmVerifyExamplesEnabled : Bool
    }


invertAutoRun : Model model -> Model model
invertAutoRun model =
    { model | autoRunEnabled = not model.autoRunEnabled }


setAutoRun : Bool -> Model model -> Model model
setAutoRun setting model =
    { model | autoRunEnabled = setting }


invertAutoNavigate : Model model -> Model model
invertAutoNavigate model =
    { model | autoNavigateEnabled = not model.autoNavigateEnabled }


setAutoNavigate : Bool -> Model model -> Model model
setAutoNavigate setting model =
    { model | autoNavigateEnabled = setting }


invertElmVerifyExamples : Model model -> Model model
invertElmVerifyExamples model =
    { model | runElmVerifyExamplesEnabled = not model.runElmVerifyExamplesEnabled }


setElmVerifyExamples : Bool -> Model model -> Model model
setElmVerifyExamples setting model =
    { model | runElmVerifyExamplesEnabled = setting }


serialize : Model model -> Flags
serialize model =
    { autoRun = model.autoRunEnabled
    , autoNavigate = model.autoNavigateEnabled
    , useElmVerifyExamples = model.runElmVerifyExamplesEnabled
    }
