module TestEvent.RunComplete exposing (RawData, RunComplete, parse, passed)

import TestEvent.Util


type RunComplete
    = RunComplete Parsed


type alias RawData =
    { passed : String
    , failed : String
    , duration : String
    }


type alias Parsed =
    { passed : Int
    , failed : Int
    , duration : Int
    }


parse : RawData -> RunComplete
parse rawData =
    RunComplete
        { passed = TestEvent.Util.parseInt rawData.passed
        , failed = TestEvent.Util.parseInt rawData.failed
        , duration = TestEvent.Util.parseInt rawData.duration
        }


passed : RunComplete -> Bool
passed (RunComplete parsed) =
    parsed.failed == 0
