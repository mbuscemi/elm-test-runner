module Model.Directories exposing (setProject, setTestable, setWorking)


type alias Model model =
    { model
        | projectDirectories : List String
        , testableElmDirectories : List String
        , currentWorkingDirectory : String
        , hasRegisteredDirectories : Bool
    }


setProject : List String -> Model model -> Model model
setProject directories model =
    { model | projectDirectories = directories }


setTestable : List String -> Model model -> Model model
setTestable directories model =
    { model
        | testableElmDirectories = directories
        , currentWorkingDirectory = List.head directories |> Maybe.withDefault ""
        , hasRegisteredDirectories = True
    }


setWorking : String -> Model model -> Model model
setWorking directory model =
    { model | currentWorkingDirectory = directory }
