module Model.Flags exposing (Flags, parse)

import Json.Decode exposing (Decoder, bool, decodeValue, field, map2)
import Json.Encode exposing (Value)


type alias Flags =
    { autoRun : Bool
    , autoNavigate : Bool
    }


parse : Value -> Flags
parse raw =
    decodeValue flags raw
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
