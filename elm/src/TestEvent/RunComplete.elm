module TestEvent.RunComplete exposing (RunComplete, duration, parse, passed)

import Json.Decode exposing (Decoder, Value, decodeValue, field, int, map, map3, string)
import TestEvent.Util exposing (intString)
import State.Duration as Duration exposing (Duration)


type alias Data =
    { passed : Int
    , failed : Int
    , duration : Int
    }


type RunComplete
    = RunComplete Data


parse : Value -> RunComplete
parse value =
    decodeValue runComplete value
        |> Result.withDefault default
        |> RunComplete


default : Data
default =
    { passed = 0, failed = 0, duration = 0 }


runComplete : Decoder Data
runComplete =
    map3 Data
        (field "passed" intString)
        (field "failed" intString)
        (field "duration" intString)


passed : RunComplete -> Bool
passed (RunComplete data) =
    data.failed == 0


duration : RunComplete -> Duration
duration (RunComplete data) =
    Duration.inMilliseconds data.duration
