module State.Failure exposing (Failure, failure, getActual, getComparison, getExpected, getMessage, shouldDiff)

import Json.Decode exposing (Decoder, field, map, map2, map5, maybe, oneOf, string)


type alias ComparisonData =
    { comparison : String
    , actual : Maybe String
    , expected : Maybe String
    , first : Maybe String
    , second : Maybe String
    }


type Comparison
    = Complex ComparisonData
    | Plain String


comparison : Decoder Comparison
comparison =
    oneOf
        [ map Complex <|
            map5 ComparisonData
                (field "comparison" string)
                (maybe (field "actual" string))
                (maybe (field "expected" string))
                (maybe (field "first" string))
                (maybe (field "second" string))
        , map Plain string
        ]


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


getData : Failure -> ComparisonData
getData failure =
    case failure.reason.data of
        Complex data ->
            data

        Plain string ->
            { comparison = string
            , actual = Nothing
            , expected = Nothing
            , first = Nothing
            , second = Nothing
            }


getExpected : Failure -> String
getExpected failure =
    let
        data =
            getData failure

        expected =
            data.expected

        first =
            data.first
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
        data =
            getData failure

        actual =
            data.actual

        second =
            data.second
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
    getData failure |> .comparison


shouldDiff : Failure -> Bool
shouldDiff failure =
    let
        data =
            getData failure

        expected =
            data.expected

        first =
            data.first
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
