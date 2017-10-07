module TestInstance.Core
    exposing
        ( TestInstance
        , default
        , durationAsString
        , isFailing
        , isPending
        , setDuration
        , setStatus
        , toClass
        , toStatusIcon
        )

import Duration.Core as Duration exposing (Duration, inMilliseconds)


type TestStatus
    = Pass
    | Fail
    | Pending


type alias TestInstance =
    { testStatus : TestStatus
    , duration : Duration
    }


default : TestInstance
default =
    { testStatus = Pending
    , duration = inMilliseconds 0
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
setStatus newStatus instance =
    case newStatus of
        "pass" ->
            { instance | testStatus = Pass }

        "fail" ->
            { instance | testStatus = Fail }

        "pending" ->
            { instance | testStatus = Pending }

        _ ->
            { instance | testStatus = Pending }


setDuration : Int -> TestInstance -> TestInstance
setDuration duration instance =
    { instance | duration = inMilliseconds duration }


durationAsString : TestInstance -> String
durationAsString instance =
    toString <| Duration.asMilliseconds instance.duration
