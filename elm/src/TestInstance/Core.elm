module TestInstance.Core
    exposing
        ( TestInstance
        , default
        , durationAsString
        , getFailure
        , isFailing
        , isPending
        , isTodo
        , setDuration
        , setFailure
        , setStatus
        , toClass
        , toStatusIcon
        )

import Duration.Core as Duration exposing (Duration, inMilliseconds)
import State.Failure exposing (Failure)


type TestStatus
    = Pass
    | Fail
    | Pending
    | Todo


type alias TestInstance =
    { testStatus : TestStatus
    , duration : Duration
    , failure : Maybe Failure
    }


default : TestInstance
default =
    { testStatus = Pending
    , duration = inMilliseconds 0
    , failure = Nothing
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

        Todo ->
            "»"


toClass : TestInstance -> String
toClass instance =
    case instance.testStatus of
        Pass ->
            "passed"

        Fail ->
            "failed"

        Pending ->
            "pending"

        Todo ->
            "todo"


isFailing : TestInstance -> Bool
isFailing instance =
    instance.testStatus == Fail


isPending : TestInstance -> Bool
isPending instance =
    instance.testStatus == Pending


isTodo : TestInstance -> Bool
isTodo instance =
    instance.testStatus == Todo


getFailure : TestInstance -> Maybe Failure
getFailure instance =
    instance.failure


setStatus : String -> TestInstance -> TestInstance
setStatus newStatus instance =
    case newStatus of
        "pass" ->
            { instance | testStatus = Pass }

        "fail" ->
            { instance | testStatus = Fail }

        "pending" ->
            { instance | testStatus = Pending }

        "todo" ->
            { instance | testStatus = Todo }

        _ ->
            { instance | testStatus = Pending }


setDuration : Int -> TestInstance -> TestInstance
setDuration duration instance =
    { instance | duration = inMilliseconds duration }


durationAsString : TestInstance -> String
durationAsString instance =
    toString <| Duration.asMilliseconds instance.duration


setFailure : Maybe Failure -> TestInstance -> TestInstance
setFailure failure instance =
    { instance | failure = failure }
