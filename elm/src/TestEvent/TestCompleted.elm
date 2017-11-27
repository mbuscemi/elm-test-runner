module TestEvent.TestCompleted
    exposing
        ( RawData
        , TestCompleted
        , duration
        , firstFailure
        , isTodo
        , labels
        , parseJson
        , parseString
        , passed
        , passedTestCountToIncrement
        )

import Duration.Core as Duration exposing (Duration)
import Json.Decode exposing (Decoder, decodeString, decodeValue, field, list, map4, string)
import Json.Encode exposing (Value)
import State.Failure as Failure exposing (Failure, failure)
import TestEvent.Util


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
    | Todo


type alias Parsed =
    { status : TestStatus
    , labels : List String
    , failures : List Failure
    , duration : Int
    }


parseJson : Value -> TestCompleted
parseJson json =
    parse decodeValue json


parseString : String -> TestCompleted
parseString jsonString =
    parse decodeString jsonString


parse : (Decoder RawData -> input -> Result String RawData) -> input -> TestCompleted
parse decoder input =
    let
        parsed =
            decoder rawData input
                |> Result.withDefault defaultRawData

        status =
            if parsed.status == "pass" then
                Pass
            else if parsed.status == "todo" then
                Todo
            else
                Fail

        labels =
            case status of
                Todo ->
                    parsed.labels ++ List.map Failure.toString parsed.failures

                _ ->
                    parsed.labels
    in
    TestCompleted
        { status = status
        , labels = labels
        , failures = parsed.failures
        , duration = TestEvent.Util.parseInt parsed.duration
        }


passedTestCountToIncrement : TestCompleted -> Int
passedTestCountToIncrement event =
    if passed event then
        1
    else
        0


passed : TestCompleted -> Bool
passed (TestCompleted parsed) =
    parsed.status == Pass


isTodo : TestCompleted -> Bool
isTodo (TestCompleted parsed) =
    parsed.status == Todo


labels : TestCompleted -> List String
labels (TestCompleted parsed) =
    parsed.labels


duration : TestCompleted -> Duration
duration (TestCompleted parsed) =
    Duration.inMilliseconds parsed.duration


firstFailure : TestCompleted -> Maybe Failure
firstFailure (TestCompleted parsed) =
    List.head parsed.failures
