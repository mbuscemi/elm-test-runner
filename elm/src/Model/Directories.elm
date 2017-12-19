module Model.Directories exposing (setProject, setTestable, setWorking)


type alias HasDirectories r =
    { r
        | projectDirectories : List String
        , testableElmDirectories : List String
        , currentWorkingDirectory : String
        , hasRegisteredDirectories : Bool
    }


setProject : List String -> HasDirectories model -> HasDirectories model
setProject directories model =
    { model | projectDirectories = directories }


setTestable : List String -> HasDirectories model -> HasDirectories model
setTestable directories model =
    { model
        | testableElmDirectories = directories
        , currentWorkingDirectory = List.head directories |> Maybe.withDefault ""
        , hasRegisteredDirectories = True
    }


setWorking : String -> HasDirectories model -> HasDirectories model
setWorking directory model =
    { model | currentWorkingDirectory = directory }
