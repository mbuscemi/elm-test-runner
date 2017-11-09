module State.Labels exposing (Labels, empty, fromList, getPotentialPathPiecesAndTestDescription)

import List.Extra as List


type Labels
    = Basic (List String)


type alias PathAndTestDescription =
    ( List String, String )


empty : Labels
empty =
    Basic []


fromList : List String -> Labels
fromList rawLabels =
    Basic rawLabels


getPotentialPathPiecesAndTestDescription : Labels -> PathAndTestDescription
getPotentialPathPiecesAndTestDescription labels =
    case labels of
        Basic list ->
            splitDots list
                |> toPathAndTestDescription


splitDots : List String -> List String
splitDots list =
    List.map (\string -> String.split "." string) list
        |> List.concat


toPathAndTestDescription : List String -> PathAndTestDescription
toPathAndTestDescription list =
    ( allButLastLabel list, lastLabel list )


allButLastLabel : List String -> List String
allButLastLabel list =
    List.reverse list
        |> List.drop 1
        |> List.reverse


lastLabel : List String -> String
lastLabel list =
    List.last list
        |> Maybe.withDefault ""
