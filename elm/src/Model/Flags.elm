module Model.Flags exposing (Flags, parse)

import Json.Decode exposing (Decoder, bool, decodeValue, field, map3)
import Json.Encode exposing (Value)


type alias Flags =
    { autoRun : Bool
    , autoNavigate : Bool
    , useElmVerifyExamples : Bool
    }


parse : Value -> Flags
parse raw =
    decodeValue flags raw
        |> Result.withDefault default


default : Flags
default =
    { autoRun = False
    , autoNavigate = True
    , useElmVerifyExamples = False
    }


flags : Decoder Flags
flags =
    map3 Flags
        (field "autoRun" bool)
        (field "autoNavigate" bool)
        (field "useElmVerifyExamples" bool)
