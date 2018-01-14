module Model.ProjectName exposing (default, setFromPath)

import Tree.Core exposing (Tree(Node))


type alias Model model testInstance =
    { model
        | projectName : String
        , testRuns : Tree String testInstance
        , currentWorkingDirectory : String
    }


default : String
default =
    "Unknown Project"


setFromPath : Model model testInstance -> Model model testInstance
setFromPath model =
    { model
        | projectName =
            String.split "/" model.currentWorkingDirectory
                |> List.reverse
                |> List.head
                |> Maybe.withDefault default
    }
        |> setToTopNode


setToTopNode : Model model testInstance -> Model model testInstance
setToTopNode model =
    let
        (Node _ testInstance children) =
            model.testRuns
    in
    { model
        | testRuns = Node model.projectName testInstance children
    }
