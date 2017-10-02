module TestEvent.TestCompleted exposing (RawData, TestCompleted, parse, passedTestCountToIncrement)

import TestEvent.Util


type TestCompleted
    = TestCompleted Parsed


type alias RawData =
    { status : String
    , labels : List String
    , failures : List String
    , duration : String
    }


type TestStatus
    = Pass
    | Fail


type alias Parsed =
    { status : TestStatus
    , labels : List String
    , failures : List String
    , duration : Int
    }


parse : RawData -> TestCompleted
parse rawData =
    TestCompleted
        { status =
            if rawData.status == "pass" then
                Pass
            else
                Fail
        , labels = rawData.labels
        , failures = rawData.failures
        , duration = TestEvent.Util.parseInt rawData.duration
        }


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
