module State.Failure
    exposing
        ( Failure
        , failure
        , getActual
        , getComparison
        , getExpected
        , getGiven
        , getMessage
        , hasComplexComparison
        , isTodo
        , shouldDiff
        )

import Json.Decode exposing (Decoder, field, list, map, map3, map5, maybe, oneOf, string)


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
    = SimpleComparison String
    | ComplexComparison ComparisonData


comparison : Decoder Comparison
comparison =
    oneOf
        [ map SimpleComparison string
        , map ComplexComparison <|
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


type alias FailureData =
    { message : String
    , reason : Reason
    , given : Maybe String
    }


type Failure
    = SimpleFailure String
    | ComplexFailure FailureData


failure : Decoder Failure
failure =
    oneOf
        [ map SimpleFailure string
        , map ComplexFailure <|
            map3 FailureData
                (field "message" string)
                (field "reason" reason)
                (maybe <| field "given" string)
        ]


getMessage : Failure -> String
getMessage failure =
    case failure of
        SimpleFailure string ->
            string

        ComplexFailure complexFailure ->
            complexFailure.message


getGiven : Failure -> Maybe String
getGiven failure =
    case failure of
        SimpleFailure string ->
            Nothing

        ComplexFailure complexFailure ->
            complexFailure.given


hasComplexComparison : Failure -> Bool
hasComplexComparison failure =
    case failure of
        SimpleFailure _ ->
            False

        ComplexFailure complexFailure ->
            case complexFailure.reason.data of
                ComplexComparison _ ->
                    True

                SimpleComparison _ ->
                    False


getData : Failure -> ComparisonData
getData failure =
    case failure of
        SimpleFailure string ->
            { comparison = Just string
            , actual = Nothing
            , expected = Nothing
            , first = Nothing
            , second = Nothing
            }

        ComplexFailure complexFailure ->
            case complexFailure.reason.data of
                SimpleComparison string ->
                    { comparison = Just string
                    , actual = Nothing
                    , expected = Nothing
                    , first = Nothing
                    , second = Nothing
                    }

                ComplexComparison data ->
                    data


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


isTodo : Failure -> Bool
isTodo failure =
    case failure of
        SimpleFailure _ ->
            True

        ComplexFailure _ ->
            False
