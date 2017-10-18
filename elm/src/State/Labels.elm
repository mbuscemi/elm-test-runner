module State.Labels exposing (Labels, empty, fromList, getPathAndTestDescription)


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


getPathAndTestDescription : Labels -> PathAndTestDescription
getPathAndTestDescription labels =
    case labels of
        Basic list ->
            buildPathAndDescription "" list


buildPathAndDescription : String -> List String -> PathAndTestDescription
buildPathAndDescription intermediatePath labels =
    case labels of
        nextToLastLabel :: [ lastLabel ] ->
            ( intermediatePath ++ nextToLastLabel ++ ".elm", lastLabel )

        nextLabel :: rest ->
            buildPathAndDescription (intermediatePath ++ nextLabel ++ "/") rest

        [] ->
            ( intermediatePath, "" )
