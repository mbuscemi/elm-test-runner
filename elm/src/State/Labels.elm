module State.Labels exposing (Labels, empty, fromList)


type Labels
    = Basic (List String)


type alias PathAndTestDescription =
    ( String, String )


empty : Labels
empty =
    Basic []


fromList : List String -> Labels
fromList rawLabels =
    Basic rawLabels


toList : Labels -> List String
toList labels =
    case labels of
        Basic list ->
            list


getPathAndTestDescription : Labels -> PathAndTestDescription
getPathAndTestDescription labels =
    case labels of
        Basic list ->
            buildPathAndDescription "" list


buildPathAndDescription : String -> List String -> PathAndTestDescription
buildPathAndDescription intermediatePath labels =
    case labels of
        [ lastLabel ] ->
            ( intermediatePath, lastLabel )

        nextLabel :: rest ->
            buildPathAndDescription (intermediatePath ++ nextLabel ++ "/") rest

        [] ->
            ( intermediatePath, "" )
