module View.OutputDisplay exposing (render)

import Diff.Core exposing (Change(Added, NoChange, Removed), diff)
import Html exposing (Html, div, span, strong, text)
import Html.Attributes exposing (class)
import State.Failure exposing (Failure, getActual, getComparison, getExpected, getMessage)


render : Maybe Failure -> Html message
render failure =
    div [ class "failure" ] (failureText failure)


failureText : Maybe Failure -> List (Html message)
failureText maybeFailure =
    case maybeFailure of
        Just failure ->
            let
                ( expectedHtml, actualHtml ) =
                    diffedHtml (getExpected failure) (getActual failure)
            in
            [ div [ class "failure-header" ]
                [ text <| "Failed on: "
                , strong [] [ text <| getMessage failure ]
                ]
            , actualHtml
            , div [] [ text <| "╷" ]
            , div [] [ text <| "│ " ++ getComparison failure ]
            , div [] [ text <| "╵" ]
            , expectedHtml
            ]

        Nothing ->
            [ text "" ]


diffedHtml : String -> String -> ( Html message, Html message )
diffedHtml expected actual =
    diff (String.toList expected) (String.toList actual)
        |> foldChanges
        |> (\diffedActual -> ( div [ class "expected" ] [ text expected ], div [ class "actual" ] diffedActual ))


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
