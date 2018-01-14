module Model.TestCount exposing (resetPassed, setTotal, updatePassed)

import TestEvent.RunStart as RunStart exposing (RunStart)
import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)


type alias Model model =
    { model
        | passedTests : Int
        , totalTests : Int
    }


updatePassed : TestCompleted -> Model model -> Model model
updatePassed event model =
    { model | passedTests = model.passedTests + TestCompleted.passedTestCountToIncrement event }


resetPassed : Model model -> Model model
resetPassed model =
    { model | passedTests = 0 }


setTotal : RunStart -> Model model -> Model model
setTotal event model =
    { model | totalTests = RunStart.numTotalTests event }
