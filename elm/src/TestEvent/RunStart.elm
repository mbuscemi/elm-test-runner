module TestEvent.RunStart exposing (RawData, RunStart, numTotalTests, parse)

import TestEvent.Util


type RunStart
    = RunStart Parsed


type alias RawData =
    { testCount : String
    , fuzzRuns : String
    , paths : List String
    , initialSeed : String
    }


type alias Parsed =
    { testCount : Int
    , fuzzRuns : Int
    , paths : List String
    , initialSeed : Int
    }


parse : RawData -> RunStart
parse rawData =
    RunStart
        { testCount = TestEvent.Util.parseInt rawData.testCount
        , fuzzRuns = TestEvent.Util.parseInt rawData.fuzzRuns
        , paths = rawData.paths
        , initialSeed = TestEvent.Util.parseInt rawData.initialSeed
        }


numTotalTests : RunStart -> Int
numTotalTests (RunStart parsed) =
    parsed.testCount
