module View.OutputDisplay exposing (render)

import Diff.Core exposing (Change(Added, NoChange, Removed), diff)
import Html exposing (Html, div, span, strong, text)
import Html.Attributes exposing (class)
import State.Failure
    exposing
        ( Failure
        , getActual
        , getComparison
        , getExpected
        , getMessage
        , hasComplexComparison
        , shouldDiff
        )


render : Maybe Failure -> Html message
render failure =
    div [ class "failure" ] (failureText failure)


failureText : Maybe Failure -> List (Html message)
failureText maybeFailure =
    case maybeFailure of
        Just failure ->
            let
                ( expected, actual ) =
                    process failure
            in
            [ div [ class "failure-header" ]
                [ text <| "Failed on: "
                , strong [] [ text <| getMessage failure ]
                ]
            , div [ class "actual" ] actual
            , barTop failure
            , barMiddle (getMessage failure) failure
            , barBottom failure
            , div [ class "expected" ] expected
            ]

        Nothing ->
            [ text "" ]


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
