module TestInstance.Core
    exposing
        ( TestInstance
        , default
        , isFailing
        , isPending
        , setStatus
        , toClass
        , toStatusIcon
        )


type TestStatus
    = Pass
    | Fail
    | Pending


type alias TestInstance =
    { testStatus : TestStatus
    }


default : TestInstance
default =
    { testStatus = Pending
    }


toStatusIcon : TestInstance -> String
toStatusIcon instance =
    case instance.testStatus of
        Pass ->
            "✓"

        Fail ->
            "✗"

        Pending ->
            "○"


toClass : TestInstance -> String
toClass instance =
    case instance.testStatus of
        Pass ->
            "passed"

        Fail ->
            "failed"

        Pending ->
            "pending"


isFailing : TestInstance -> Bool
isFailing instance =
    instance.testStatus == Fail


isPending : TestInstance -> Bool
isPending instance =
    instance.testStatus == Pending


setStatus : String -> TestInstance -> TestInstance
setStatus newStatus test =
    case newStatus of
        "pass" ->
            { test | testStatus = Pass }

        "fail" ->
            { test | testStatus = Fail }

        "pending" ->
            { test | testStatus = Pending }

        _ ->
            { test | testStatus = Pending }
