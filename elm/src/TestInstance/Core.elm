module TestInstance.Core
    exposing
        ( TestInstance
        , default
        , durationAsString
        , fromEvent
        , getFailure
        , getFailureData
        , isFailing
        , isPending
        , isTodo
        , pathAndDescription
        , setDuration
        , setFailure
        , setLabels
        , setStatus
        , toClass
        , toStatusIcon
        )

import Duration.Core as Duration exposing (Duration, inMilliseconds)
import Maybe.Extra as Maybe
import State.Failure as Failure exposing (Failure)
import State.Labels as Labels exposing (Labels)
import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)


type TestStatus
    = Pass
    | Fail
    | Pending
    | Todo


type alias TestInstance =
    { testStatus : TestStatus
    , labels : Labels
    , duration : Duration
    , failure : Maybe Failure
    }


default : TestInstance
default =
    { testStatus = Pending
    , labels = Labels.empty
    , duration = inMilliseconds 0
    , failure = Nothing
    }


fromEvent : TestCompleted -> TestInstance
fromEvent event =
    TestInstance
        (if TestCompleted.passed event then
            Pass
         else if TestCompleted.isTodo event then
            Todo
         else
            Fail
        )
        (Labels.fromList <| TestCompleted.labels event)
        (TestCompleted.duration event)
        (TestCompleted.firstFailure event)


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


getFailureData : Maybe TestInstance -> Maybe Failure.Data
getFailureData maybeTestInstance =
    Maybe.map getFailure maybeTestInstance
        |> Maybe.join
        |> Maybe.map Failure.toData


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


setLabels : Labels -> TestInstance -> TestInstance
setLabels labels instance =
    { instance | labels = labels }


pathAndDescription : TestInstance -> ( List String, String )
pathAndDescription instance =
    Labels.getPotentialPathPiecesAndTestDescription instance.labels
