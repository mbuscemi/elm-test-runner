module Model.ProjectName exposing (default, setFromPath)

import Tree.Core exposing (Tree(Node))


type alias HasProject r a =
    { r
        | projectName : String
        , testRuns : Tree String a
    }


default : String
default =
    "Unknown Project"


setFromPath : String -> HasProject model a -> HasProject model a
setFromPath projectPath model =
    { model
        | projectName =
            String.split "/" projectPath
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
