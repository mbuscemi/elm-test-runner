module View.OutputDisplay exposing (render)

import Html exposing (Html, br, div, span, strong, text)
import Html.Attributes exposing (class)
import Util.Diff exposing (Change(Added, NoChange, Removed), diff)


type alias FailureData =
    { actual : String
    , expected : String
    , given : Maybe String
    , message : String
    , hasComplexComparison : Bool
    , isTodo : Bool
    , shouldDiff : Bool
    }


render : Maybe String -> Maybe FailureData -> Html message
render compilerError maybeFailureData =
    case ( compilerError, maybeFailureData ) of
        ( Just error, _ ) ->
            div [ class "failure" ] (errorText error)

        ( Nothing, Just failureData ) ->
            div [ class "failure" ] (failureText failureData)

        ( Nothing, Nothing ) ->
            div [] []


errorText : String -> List (Html message)
errorText errorMessage =
    [ div [] [ strong [] [ text "Compiler Error:" ] ]
    , div [] (errorHtml errorMessage)
    ]


errorHtml : String -> List (Html message)
errorHtml message =
    String.split "\n" message
        |> List.map text
        |> List.intersperse (br [] [])


failureText : FailureData -> List (Html message)
failureText failureData =
    let
        ( expected, actual ) =
            process failureData
    in
    [ div [ class "failure-header" ]
        [ text <| headerText failureData
        , strong [] [ text <| failureData.message ]
        ]
    , givenDisplay failureData
    , div [ class "actual" ] actual
    , barTop failureData
    , barMiddle failureData.message failureData
    , barBottom failureData
    , div [ class "expected" ] expected
    ]


process : FailureData -> ( List (Html message), List (Html message) )
process failureData =
    if failureData.shouldDiff then
        diffed failureData.expected failureData.actual
    else
        ( [ text failureData.expected ], [ text failureData.actual ] )


diffed : String -> String -> ( List (Html message), List (Html message) )
diffed expected actual =
    diff (String.toList expected) (String.toList actual)
        |> foldChanges
        |> (\diffedActual -> ( [ text expected ], diffedActual ))


foldChanges : List (Change Char) -> List (Html message)
foldChanges list =
    List.foldr foldChangeIntoHtml [] list


foldChangeIntoHtml : Change Char -> List (Html message) -> List (Html message)
foldChangeIntoHtml change list =
    toHtml change :: list


toHtml : Change Char -> Html message
toHtml change =
    case change of
        Added char ->
            span [ class "addition" ] [ text <| String.fromChar char ]

        Removed char ->
            span [ class "removal" ] [ text <| String.fromChar char ]

        NoChange char ->
            text <| String.fromChar char


headerText : FailureData -> String
headerText failureData =
    if failureData.isTodo then
        "TODO: "
    else
        "Failed on: "


givenDisplay : FailureData -> Html message
givenDisplay failureData =
    case failureData.given of
        Just givenText ->
            div [ class "given-display" ] [ text <| "Given: " ++ givenText ]

        Nothing ->
            text ""


barTop : FailureData -> Html message
barTop =
    barPiece "╷" ""


barMiddle : String -> FailureData -> Html message
barMiddle comparison =
    barPiece "│ " comparison


barBottom : FailureData -> Html message
barBottom =
    barPiece "╵" ""


barPiece : String -> String -> FailureData -> Html message
barPiece piece extra failureData =
    if failureData.hasComplexComparison then
        div [] [ text <| piece ++ extra ]
    else
        text extra
