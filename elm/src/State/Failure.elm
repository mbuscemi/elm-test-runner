module State.Failure exposing (Failure, failure, getActual, getComparison, getExpected, getMessage, shouldDiff)

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


getExpected : Failure -> String
getExpected failure =
    let
        expected =
            failure.reason.data.expected

        first =
            failure.reason.data.first
    in
    case ( expected, first ) of
        ( Just expected, Just first ) ->
            expected

        ( Nothing, Just first ) ->
            first

        ( Just expected, Nothing ) ->
            expected

        ( Nothing, Nothing ) ->
            ""


getActual : Failure -> String
getActual failure =
    let
        actual =
            failure.reason.data.actual

        second =
            failure.reason.data.second
    in
    case ( actual, second ) of
        ( Just actual, Just second ) ->
            actual

        ( Nothing, Just second ) ->
            second

        ( Just actual, Nothing ) ->
            actual

        ( Nothing, Nothing ) ->
            ""


getComparison : Failure -> String
getComparison failure =
    failure.reason.data.comparison


shouldDiff : Failure -> Bool
shouldDiff failure =
    let
        expected =
            failure.reason.data.expected

        first =
            failure.reason.data.first
    in
    case ( expected, first ) of
        ( Just expected, Just first ) ->
            True

        ( Nothing, Just first ) ->
            False

        ( Just expected, Nothing ) ->
            True

        ( Nothing, Nothing ) ->
            False
