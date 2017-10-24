module Model.TestCount exposing (resetPassed, setTotal, updatePassed)

import TestEvent.RunStart as RunStart exposing (RunStart)
import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)


type alias HasTestCounts r =
    { r
        | passedTests : Int
        , totalTests : Int
    }


updatePassed : TestCompleted -> HasTestCounts model -> HasTestCounts model
updatePassed event model =
    { model | passedTests = model.passedTests + TestCompleted.passedTestCountToIncrement event }


resetPassed : HasTestCounts model -> HasTestCounts model
resetPassed model =
    { model | passedTests = 0 }


setTotal : RunStart -> HasTestCounts model -> HasTestCounts model
setTotal event model =
    { model | totalTests = RunStart.numTotalTests event }
