module Model.ProjectName exposing (default, setFromPath)

import Tree.Core exposing (Tree(Node))


type alias HasProject r a =
    { r
        | projectName : String
        , testRuns : Tree String a
        , currentWorkingDirectory : String
    }


default : String
default =
    "Unknown Project"


setFromPath : HasProject model a -> HasProject model a
setFromPath model =
    { model
        | projectName =
            String.split "/" model.currentWorkingDirectory
                |> List.reverse
                |> List.head
                |> Maybe.withDefault default
    }
        |> setToTopNode


setToTopNode : HasProject model a -> HasProject model a
setToTopNode model =
    let
        (Node _ testInstance children) =
            model.testRuns
    in
    { model
        | testRuns = Node model.projectName testInstance children
    }
