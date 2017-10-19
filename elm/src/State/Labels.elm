module State.Labels exposing (Labels, empty, fromList, getPathAndTestDescription)

import Char
import String.Extra as String


type Labels
    = Basic (List String)


type alias PathAndTestDescription =
    ( String, List String )


empty : Labels
empty =
    Basic []


fromList : List String -> Labels
fromList rawLabels =
    Basic rawLabels


getPathAndTestDescription : Labels -> PathAndTestDescription
getPathAndTestDescription labels =
    case labels of
        Basic list ->
            buildPathAndDescription "" list


buildPathAndDescription : String -> List String -> PathAndTestDescription
buildPathAndDescription path labels =
    case labels of
        nextLabel :: rest ->
            if firstCharIsUpper nextLabel then
                buildPathAndDescription
                    (addToPath nextLabel path)
                    rest
            else
                ( lastSlashToElmSuffix path, [ nextLabel ] ++ rest )

        [] ->
            ( path, [] )


addToPath : String -> String -> String
addToPath next path =
    path ++ dotsToSlashes next ++ "/"


dotsToSlashes : String -> String
dotsToSlashes string =
    String.replace "." "/" string


lastSlashToElmSuffix : String -> String
lastSlashToElmSuffix string =
    String.dropRight 1 string ++ ".elm"


firstCharIsUpper : String -> Bool
firstCharIsUpper string =
    case String.uncons string of
        Just ( char, _ ) ->
            Char.isUpper char

        Nothing ->
            False
