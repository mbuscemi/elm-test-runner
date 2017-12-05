module TestEvent.RunStart exposing (RunStart, initialSeed, numTotalTests, parse)

import Json.Decode exposing (Decoder, Value, decodeValue, field, int, list, map4, string)
import TestEvent.Util exposing (intString)


type RunStart
    = RunStart Data


type alias Data =
    { testCount : Int
    , fuzzRuns : Int
    , paths : List String
    , initialSeed : Int
    }


parse : Value -> RunStart
parse value =
    decodeValue runComplete value
        |> Result.withDefault default
        |> RunStart


default : Data
default =
    { testCount = 0, fuzzRuns = 0, paths = [], initialSeed = 0 }


runComplete : Decoder Data
runComplete =
    map4 Data
        (field "testCount" intString)
        (field "fuzzRuns" intString)
        (field "paths" (list string))
        (field "initialSeed" intString)


numTotalTests : RunStart -> Int
numTotalTests (RunStart parsed) =
    parsed.testCount


initialSeed : RunStart -> Int
initialSeed (RunStart parsed) =
    parsed.initialSeed
