module Model.Flags exposing (Flags, parse)

import Json.Decode exposing (Decoder, bool, decodeString, field, map2)


type alias Flags =
    { autoRun : Bool
    , autoNavigate : Bool
    }


parse : String -> Flags
parse raw =
    decodeString flags raw
        |> Result.withDefault default


default : Flags
default =
    { autoRun = False
    , autoNavigate = True
    }


flags : Decoder Flags
flags =
    map2 Flags
        (field "autoRun" bool)
        (field "autoNavigate" bool)
