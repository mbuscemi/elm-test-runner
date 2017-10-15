module View.OutputDisplay exposing (render)

import Diff.Core exposing (Change(Added, NoChange, Removed), diff)
import Html exposing (Html, br, div, span, strong, text)
import Html.Attributes exposing (class)
import State.Failure
    exposing
        ( Failure
        , getActual
        , getExpected
        , getGiven
        , getMessage
        , hasComplexComparison
        , isTodo
        , shouldDiff
        )


render : Maybe String -> Maybe Failure -> Html message
render compilerError failure =
    case ( compilerError, failure ) of
        ( Just error, _ ) ->
            div [ class "failure" ] (errorText error)

        ( Nothing, Just failure ) ->
            div [ class "failure" ] (failureText failure)

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


failureText : Failure -> List (Html message)
failureText failure =
    let
        ( expected, actual ) =
            process failure
    in
    [ div [ class "failure-header" ]
        [ text <| headerText failure
        , strong [] [ text <| getMessage failure ]
        ]
    , givenDisplay failure
    , div [ class "actual" ] actual
    , barTop failure
    , barMiddle (getMessage failure) failure
    , barBottom failure
    , div [ class "expected" ] expected
    ]


process : Failure -> ( List (Html message), List (Html message) )
process failure =
    let
        expected =
            getExpected failure

        actual =
            getActual failure
    in
    if shouldDiff failure then
        diffed expected actual
    else
        ( [ text expected ], [ text actual ] )


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


headerText : Failure -> String
headerText failure =
    if isTodo failure then
        "TODO: "
    else
        "Failed on: "


givenDisplay : Failure -> Html message
givenDisplay failure =
    case getGiven failure of
        Just givenText ->
            div [ class "given-display" ] [ text <| "Given: " ++ givenText ]

        Nothing ->
            text ""


barTop : Failure -> Html message
barTop =
    barPiece "╷" ""


barMiddle : String -> Failure -> Html message
barMiddle comparison =
    barPiece "│ " comparison


barBottom : Failure -> Html message
barBottom =
    barPiece "╵" ""


barPiece : String -> String -> Failure -> Html message
barPiece piece extra failure =
    if hasComplexComparison failure then
        div [] [ text <| piece ++ extra ]
    else
        text extra
