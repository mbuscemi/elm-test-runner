module Model.Basics exposing (setCompilerErrorMessage, setPaneLocation)

import State.PaneLocation as PaneLocation exposing (PaneLocation)


type alias WithBasics r =
    { r
        | compilerError : Maybe String
        , paneLocation : PaneLocation
    }


setCompilerErrorMessage : Maybe String -> WithBasics model -> WithBasics model
setCompilerErrorMessage maybeError model =
    { model | compilerError = maybeError }


setPaneLocation : String -> WithBasics model -> WithBasics model
setPaneLocation newLocation model =
    { model | paneLocation = PaneLocation.fromString newLocation }
