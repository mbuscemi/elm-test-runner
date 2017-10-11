module State.Failure
    exposing
        ( Failure
        , failure
        , getActual
        , getComparison
        , getExpected
        , getMessage
        , hasComplexComparison
        , shouldDiff
        )

import Json.Decode exposing (Decoder, field, list, map, map2, map5, maybe, oneOf, string)


type Expectation
    = ListFields (List String)
    | Simple String


expectation : Decoder Expectation
expectation =
    oneOf
        [ map ListFields (list string)
        , map Simple string
        ]


type alias ComparisonData =
    { comparison : Maybe String
    , actual : Maybe Expectation
    , expected : Maybe Expectation
    , first : Maybe String
    , second : Maybe String
    }


type Comparison
    = Complex ComparisonData
    | Plain String


comparison : Decoder Comparison
comparison =
    oneOf
        [ map Plain string
        , map Complex <|
            map5 ComparisonData
                (maybe <| field "comparison" string)
                (maybe <| field "actual" expectation)
                (maybe <| field "expected" expectation)
                (maybe <| field "first" string)
                (maybe <| field "second" string)
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


hasComplexComparison : Failure -> Bool
hasComplexComparison failure =
    case failure.reason.data of
        Complex _ ->
            True

        Plain _ ->
            False


getData : Failure -> ComparisonData
getData failure =
    case failure.reason.data of
        Complex data ->
            data

        Plain string ->
            { comparison = Just string
            , actual = Nothing
            , expected = Nothing
            , first = Nothing
            , second = Nothing
            }


expectationText : Expectation -> String
expectationText expectation =
    case expectation of
        ListFields list ->
            "[\""
                ++ List.foldl
                    (\number string -> string ++ number)
                    ""
                    (List.intersperse "\",\"" list)
                ++ "\"]"

        Simple string ->
            string


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
            expectationText expected

        ( Nothing, Just first ) ->
            first

        ( Just expected, Nothing ) ->
            expectationText expected

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
            expectationText actual

        ( Nothing, Just second ) ->
            second

        ( Just actual, Nothing ) ->
            expectationText actual

        ( Nothing, Nothing ) ->
            ""


getComparison : Failure -> String
getComparison failure =
    case getData failure |> .comparison of
        Just string ->
            string

        Nothing ->
            ""


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
