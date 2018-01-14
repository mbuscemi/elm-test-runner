module Model.Basics exposing (setCompilerErrorMessage, setPaneLocation)

import State.PaneLocation as PaneLocation exposing (PaneLocation)


type alias Model model =
    { model
        | compilerError : Maybe String
        , paneLocation : PaneLocation
    }


setCompilerErrorMessage : Maybe String -> Model model -> Model model
setCompilerErrorMessage maybeError model =
    { model | compilerError = maybeError }


setPaneLocation : String -> Model model -> Model model
setPaneLocation newLocation model =
    { model | paneLocation = PaneLocation.fromString newLocation }
