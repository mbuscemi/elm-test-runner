module State.TestInstance exposing (TestInstance, default)


type TestStatus
    = Pass
    | Fail


type alias TestInstance =
    { testStatus : TestStatus
    }


default : TestInstance
default =
    { testStatus = Pass }
