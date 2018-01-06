module TestInstance.Core
    exposing
        ( TestInstance
        , default
        , durationAsString
        , fromEvent
        , getFailure
        , getFailureData
        , hasFailureData
        , isFailing
        , isFailingOrTodo
        , isPending
        , isTodo
        , pathAndDescription
        , setStatus
        , toClass
        , toStatusIcon
        )

import Maybe.Extra as Maybe
import State.Duration as Duration exposing (Duration, inMilliseconds)
import State.Failure as Failure exposing (Failure)
import State.Labels as Labels exposing (Labels)
import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)
import TestInstance.TestStatus as TestStatus exposing (TestStatus)


type alias TestInstance =
    { testStatus : TestStatus
    , labels : Labels
    , duration : Duration
    , failure : Maybe Failure
    }


default : TestInstance
default =
    { testStatus = TestStatus.default
    , labels = Labels.empty
    , duration = inMilliseconds 0
    , failure = Nothing
    }


fromEvent : TestCompleted -> TestInstance
fromEvent event =
    TestInstance
        (TestStatus.fromTestCompletedEvent event)
        (Labels.fromList <| TestCompleted.labels event)
        (TestCompleted.duration event)
        (TestCompleted.firstFailure event)


toStatusIcon : TestInstance -> String
toStatusIcon instance =
    TestStatus.toIcon instance.testStatus


toClass : TestInstance -> String
toClass instance =
    TestStatus.toClass instance.testStatus


isFailing : TestInstance -> Bool
isFailing instance =
    TestStatus.isFail instance.testStatus


isPending : TestInstance -> Bool
isPending instance =
    TestStatus.isPending instance.testStatus


isTodo : TestInstance -> Bool
isTodo instance =
    TestStatus.isTodo instance.testStatus


isFailingOrTodo : TestInstance -> Bool
isFailingOrTodo instance =
    isFailing instance || isTodo instance


getFailure : TestInstance -> Maybe Failure
getFailure instance =
    instance.failure


getFailureData : Maybe TestInstance -> Maybe Failure.Data
getFailureData maybeTestInstance =
    Maybe.map getFailure maybeTestInstance
        |> Maybe.join
        |> Maybe.map Failure.toData


hasFailureData : TestInstance -> Bool
hasFailureData testInstance =
    Maybe.isJust testInstance.failure


setStatus : String -> TestInstance -> TestInstance
setStatus newStatus instance =
    { instance | testStatus = TestStatus.fromString newStatus }


durationAsString : TestInstance -> String
durationAsString instance =
    toString <| Duration.asMilliseconds instance.duration


pathAndDescription : TestInstance -> ( List String, String )
pathAndDescription instance =
    Labels.getPotentialPathPiecesAndTestDescription instance.labels
