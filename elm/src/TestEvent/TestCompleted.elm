module TestEvent.TestCompleted exposing (RawData, TestCompleted, labels, parse, passed, passedTestCountToIncrement, toTestInstance)

import Json.Decode exposing (Decoder, decodeString, field, list, map, map2, map4, map5, maybe, string)
import TestEvent.Util
import TestInstance.Core as TestInstance exposing (TestInstance)


type TestCompleted
    = TestCompleted Parsed


type alias Comparison =
    { comparison : String
    , actual : Maybe String
    , expected : Maybe String
    , first : Maybe String
    , second : Maybe String
    }


comparison : Decoder Comparison
comparison =
    map5 Comparison
        (field "comparison" string)
        (maybe (field "actual" string))
        (maybe (field "expected" string))
        (maybe (field "first" string))
        (maybe (field "second" string))


type alias Reason =
    { data : Comparison
    }


reason : Decoder Reason
reason =
    map Reason
        (field "data" comparison)


type alias Failure =
    { message : String
    , reason : Reason
    }


failure : Decoder Failure
failure =
    map2 Failure
        (field "message" string)
        (field "reason" reason)


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
toTestInstance event =
    TestInstance.default
        |> TestInstance.setStatus (passed event)
