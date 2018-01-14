port module Model.SelectedTest exposing (setInstance, setNodeId, setTestMouseIsOver)


type alias Model model testInstance =
    { model
        | selectedTestNodeId : Maybe Int
        , selectedTestInstance : Maybe testInstance
        , testMouseIsOver : Maybe Int
    }


setNodeId : Maybe Int -> Model model testInstance -> Model model testInstance
setNodeId nodeId model =
    { model | selectedTestNodeId = nodeId }


setInstance : Maybe testInstance -> Model model testInstance -> Model model testInstance
setInstance testInstance model =
    { model | selectedTestInstance = testInstance }


setTestMouseIsOver : Maybe Int -> Model model testInstance -> Model model testInstance
setTestMouseIsOver nodeId model =
    { model | testMouseIsOver = nodeId }
