module TestEvent.Util exposing (intString)

import Json.Decode exposing (Decoder, map, string)


intString : Decoder Int
intString =
    map parseInt string


parseInt : String -> Int
parseInt string =
    Result.withDefault 0 (String.toInt string)
