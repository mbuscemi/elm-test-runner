module Model.Basics exposing (setCompilerErrorMessage, setPaneLocation, setTestMouseIsOver)

import State.PaneLocation as PaneLocation exposing (PaneLocation)


type alias WithBasics r =
    { r
        | compilerError : Maybe String
        , testMouseIsOver : Maybe Int
        , paneLocation : PaneLocation
    }


setCompilerErrorMessage : Maybe String -> WithBasics model -> WithBasics model
setCompilerErrorMessage maybeError model =
    { model | compilerError = maybeError }


setTestMouseIsOver : Maybe Int -> WithBasics model -> WithBasics model
setTestMouseIsOver nodeId model =
    { model | testMouseIsOver = nodeId }


setPaneLocation : String -> WithBasics model -> WithBasics model
setPaneLocation newLocation model =
    { model | paneLocation = PaneLocation.fromString newLocation }
