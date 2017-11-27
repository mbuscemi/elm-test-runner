module State.Failure
    exposing
        ( Data
        , Failure
        , failure
        , getActual
        , getExpected
        , getGiven
        , getMessage
        , hasComplexComparison
        , isTodo
        , nullInstance
        , shouldDiff
        , toData
        , toString
        )

import Json.Decode exposing (Decoder, field, list, map, map2, map3, map4, oneOf, string)


type alias EqualityComparisonData =
    { comparison : String
    , actual : String
    , expected : String
    }


equalityComparison : Decoder EqualityComparisonData
equalityComparison =
    map3 EqualityComparisonData
        (field "comparison" string)
        (field "actual" string)
        (field "expected" string)


type alias QuantityComparisonData =
    { comparison : String
    , first : String
    , second : String
    }


quantityComparison : Decoder QuantityComparisonData
quantityComparison =
    map3 QuantityComparisonData
        (field "comparison" string)
        (field "first" string)
        (field "second" string)


type alias ListComparisonData =
    { actual : List String
    , expected : List String
    }


listComparison : Decoder ListComparisonData
listComparison =
    map2 ListComparisonData
        (field "actual" <| list string)
        (field "expected" <| list string)


type alias DictSetComparisonData =
    { actual : String
    , expected : String
    , extra : List String
    , missing : List String
    }


dictSetComparison : Decoder DictSetComparisonData
dictSetComparison =
    map4 DictSetComparisonData
        (field "actual" string)
        (field "expected" string)
        (field "extra" <| list string)
        (field "missing" <| list string)


type Comparison
    = SimpleComparison String
    | EqualityComparison EqualityComparisonData
    | QuantityComparison QuantityComparisonData
    | ListComparison ListComparisonData
    | DictSetComparison DictSetComparisonData


comparison : Decoder Comparison
comparison =
    oneOf
        [ map SimpleComparison string
        , map EqualityComparison equalityComparison
        , map QuantityComparison quantityComparison
        , map ListComparison listComparison
        , map DictSetComparison dictSetComparison
        ]


type alias Reason =
    Comparison


reason : Decoder Reason
reason =
    field "data" comparison


type alias ComplexFailureData =
    { message : String
    , reason : Reason
    }


complexFailureData : Decoder ComplexFailureData
complexFailureData =
    map2 ComplexFailureData
        (field "message" string)
        (field "reason" reason)


type alias ConditionalFailureData =
    { message : String
    , reason : Reason
    , given : String
    }


conditionalFailureData : Decoder ConditionalFailureData
conditionalFailureData =
    map3 ConditionalFailureData
        (field "message" string)
        (field "reason" reason)
        (field "given" string)


type Failure
    = SimpleFailure String
    | ConditionalFailure ConditionalFailureData
    | ComplexFailure ComplexFailureData


failure : Decoder Failure
failure =
    oneOf
        [ map SimpleFailure string
        , map ConditionalFailure conditionalFailureData
        , map ComplexFailure complexFailureData
        ]


nullInstance : Failure
nullInstance =
    SimpleFailure "NULL"


type alias Data =
    { actual : String
    , expected : String
    , given : Maybe String
    , message : String
    , hasComplexComparison : Bool
    , isTodo : Bool
    , shouldDiff : Bool
    }


toData : Failure -> Data
toData failure =
    { actual = getActual failure
    , expected = getExpected failure
    , given = getGiven failure
    , message = getMessage failure
    , hasComplexComparison = hasComplexComparison failure
    , isTodo = isTodo failure
    , shouldDiff = shouldDiff failure
    }


getExpected : Failure -> String
getExpected failure =
    case getComparison failure of
        SimpleComparison _ ->
            ""

        EqualityComparison data ->
            data.expected

        QuantityComparison data ->
            data.first

        ListComparison data ->
            expectationText data.expected

        DictSetComparison data ->
            data.expected


getActual : Failure -> String
getActual failure =
    case getComparison failure of
        SimpleComparison _ ->
            ""

        EqualityComparison data ->
            data.actual

        QuantityComparison data ->
            data.second

        ListComparison data ->
            expectationText data.actual

        DictSetComparison data ->
            data.actual


getGiven : Failure -> Maybe String
getGiven failure =
    case failure of
        SimpleFailure _ ->
            Nothing

        ComplexFailure _ ->
            Nothing

        ConditionalFailure fail ->
            Just fail.given


getMessage : Failure -> String
getMessage failure =
    case failure of
        SimpleFailure messsage ->
            messsage

        ComplexFailure complexFailure ->
            complexFailure.message

        ConditionalFailure conditionalFailure ->
            conditionalFailure.message


hasComplexComparison : Failure -> Bool
hasComplexComparison failure =
    case failure of
        SimpleFailure _ ->
            False

        ComplexFailure complexFailure ->
            case complexFailure.reason of
                SimpleComparison _ ->
                    False

                _ ->
                    True

        ConditionalFailure conditionalFailure ->
            case conditionalFailure.reason of
                SimpleComparison _ ->
                    False

                _ ->
                    True


isTodo : Failure -> Bool
isTodo failure =
    case failure of
        SimpleFailure _ ->
            True

        ComplexFailure _ ->
            False

        ConditionalFailure _ ->
            False


toString : Failure -> String
toString failure =
    case failure of
        SimpleFailure string ->
            string

        _ ->
            ""


shouldDiff : Failure -> Bool
shouldDiff failure =
    case getComparison failure of
        SimpleComparison _ ->
            False

        EqualityComparison _ ->
            True

        QuantityComparison _ ->
            False

        ListComparison _ ->
            True

        DictSetComparison _ ->
            True


getComparison : Failure -> Comparison
getComparison failure =
    case failure of
        SimpleFailure message ->
            SimpleComparison message

        ComplexFailure complexFailure ->
            complexFailure.reason

        ConditionalFailure conditionalFailure ->
            conditionalFailure.reason


expectationText : List String -> String
expectationText values =
    "[\""
        ++ List.foldl
            (\number value -> value ++ number)
            ""
            (List.intersperse "\",\"" values)
        ++ "\"]"
