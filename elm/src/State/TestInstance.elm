module State.TestInstance exposing (TestInstance, default, passed, setStatus)


type TestStatus
    = Pass
    | Fail


type alias TestInstance =
    { testStatus : TestStatus
    }


default : TestInstance
default =
    { testStatus = Pass }


passed : TestInstance -> Bool
passed test =
    test.testStatus == Pass


setStatus : Bool -> TestInstance -> TestInstance
setStatus passed test =
    { test
        | testStatus =
            if passed then
                Pass
            else
                Fail
    }
