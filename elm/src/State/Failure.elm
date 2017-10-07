module State.Failure exposing (Failure, failure, getMessage)

import Json.Decode exposing (Decoder, field, map, map2, map5, maybe, string)


type alias Comparison =
    { comparison : String
    , actual : Maybe String
    , expected : Maybe String
    , first : Maybe String
    , second : Maybe String
    }


comparison : Decoder Comparison
comparison =
    map5 Comparison
        (field "comparison" string)
        (maybe (field "actual" string))
        (maybe (field "expected" string))
        (maybe (field "first" string))
        (maybe (field "second" string))


type alias Reason =
    { data : Comparison
    }


reason : Decoder Reason
reason =
    map Reason
        (field "data" comparison)


type alias Failure =
    { message : String
    , reason : Reason
    }


failure : Decoder Failure
failure =
    map2 Failure
        (field "message" string)
        (field "reason" reason)


getMessage : Failure -> String
getMessage failure =
    failure.message
