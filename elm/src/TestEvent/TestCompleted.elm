module TestEvent.TestCompleted
    exposing
        ( RawData
        , TestCompleted
        , labels
        , parse
        , passed
        , passedTestCountToIncrement
        , toTestInstance
        )

import Json.Decode exposing (Decoder, decodeString, field, list, map4, string)
import State.Failure exposing (Failure, failure)
import TestEvent.Util
import TestInstance.Core as TestInstance exposing (TestInstance)


type TestCompleted
    = TestCompleted Parsed


type alias RawData =
    { status : String
    , labels : List String
    , failures : List Failure
    , duration : String
    }


rawData : Decoder RawData
rawData =
    map4 RawData
        (field "status" string)
        (field "labels" (list string))
        (field "failures" (list failure))
        (field "duration" string)


defaultRawData : RawData
defaultRawData =
    { status = "", labels = [], failures = [], duration = "" }


type TestStatus
    = Pass
    | Fail


type alias Parsed =
    { status : TestStatus
    , labels : List String
    , failures : List Failure
    , duration : Int
    }


parse : String -> TestCompleted
parse rawData =
    let
        parsed =
            parseJson rawData
    in
    TestCompleted
        { status =
            if parsed.status == "pass" then
                Pass
            else
                Fail
        , labels = parsed.labels
        , failures = parsed.failures
        , duration = TestEvent.Util.parseInt parsed.duration
        }


parseJson : String -> RawData
parseJson jsonString =
    decodeString rawData jsonString
        |> Result.withDefault defaultRawData


passedTestCountToIncrement : TestCompleted -> Int
passedTestCountToIncrement event =
    if passed event then
        1
    else
        0


passed : TestCompleted -> Bool
passed (TestCompleted parsed) =
    case parsed.status of
        Pass ->
            True

        Fail ->
            False


labels : TestCompleted -> List String
labels (TestCompleted parsed) =
    parsed.labels


toTestInstance : TestCompleted -> TestInstance
toTestInstance ((TestCompleted parsed) as event) =
    TestInstance.default
        |> TestInstance.setStatus
            (if passed event then
                "pass"
             else
                "fail"
            )
        |> TestInstance.setDuration parsed.duration
        |> TestInstance.setFailure (List.head parsed.failures)
