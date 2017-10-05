module TestInstance.Core exposing (TestInstance, default, setStatus, toClass, toStatusIcon)


type TestStatus
    = Pass
    | Fail


type alias TestInstance =
    { testStatus : TestStatus
    }


default : TestInstance
default =
    { testStatus = Pass }


toStatusIcon : TestInstance -> String
toStatusIcon instance =
    case instance.testStatus of
        Pass ->
            "✓"

        Fail ->
            "✗"


toClass : TestInstance -> String
toClass instance =
    case instance.testStatus of
        Pass ->
            "passed"

        Fail ->
            "failed"


setStatus : Bool -> TestInstance -> TestInstance
setStatus passed test =
    { test
        | testStatus =
            if passed then
                Pass
            else
                Fail
    }
