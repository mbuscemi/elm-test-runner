module State.TestInstance exposing (TestInstance, default, passed)


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
