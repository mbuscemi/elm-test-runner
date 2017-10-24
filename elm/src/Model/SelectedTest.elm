module Model.SelectedTest exposing (setInstance, setNodeId)

import TestInstance.Core exposing (TestInstance)


type alias HasSelectedTest r =
    { r
        | selectedTestNodeId : Maybe Int
        , selectedTestInstance : Maybe TestInstance
    }


setNodeId : Maybe Int -> HasSelectedTest model -> HasSelectedTest model
setNodeId nodeId model =
    { model | selectedTestNodeId = nodeId }


setInstance : Maybe TestInstance -> HasSelectedTest model -> HasSelectedTest model
setInstance testInstance model =
    { model | selectedTestInstance = testInstance }
