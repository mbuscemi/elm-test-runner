module TestEvent.TestCompleted exposing (TestCompleted, duration, firstFailure, isTodo, labels, parseJson, parseString, passed, passedTestCountToIncrement)

import Json.Decode exposing (Decoder, andThen, decodeString, decodeValue, field, list, map, map4, string, succeed)
import Json.Encode exposing (Value)
import State.Failure as Failure exposing (Failure, failure)
import TestEvent.TestStatus as TestStatus exposing (TestStatus, testStatus)
import TestEvent.Util exposing (intString)
import State.Duration as Duration exposing (Duration)


type TestCompleted
    = TestCompleted Data


type alias Data =
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


parse : (Decoder Data -> input -> Result String Data) -> input -> TestCompleted
parse decoder input =
    decoder testComplete input
        |> Result.withDefault default
        |> supplementLabels
        |> TestCompleted


supplementLabels : Data -> Data
supplementLabels data =
    if TestStatus.isTodo data.status then
        { data | labels = data.labels ++ List.map Failure.toString data.failures }
    else
        data


testComplete : Decoder Data
testComplete =
    map4 Data
        (field "status" testStatus)
        (field "labels" (list string))
        (field "failures" (list failure))
        (field "duration" intString)


default : Data
default =
    { status = TestStatus.default, labels = [], failures = [], duration = 0 }


passedTestCountToIncrement : TestCompleted -> Int
passedTestCountToIncrement event =
    if passed event then
        1
    else
        0


passed : TestCompleted -> Bool
passed (TestCompleted data) =
    TestStatus.isPass data.status


isTodo : TestCompleted -> Bool
isTodo (TestCompleted data) =
    TestStatus.isTodo data.status


labels : TestCompleted -> List String
labels (TestCompleted data) =
    data.labels


duration : TestCompleted -> Duration
duration (TestCompleted data) =
    Duration.inMilliseconds data.duration


firstFailure : TestCompleted -> Maybe Failure
firstFailure (TestCompleted data) =
    List.head data.failures
