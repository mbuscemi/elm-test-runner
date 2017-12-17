port module Model.SelectedTest exposing (setInstance, setNodeId, setTestMouseIsOver)

import And
import TestInstance.Core as TestInstance exposing (TestInstance)


type alias HasSelectedTest r =
    { r
        | selectedTestNodeId : Maybe Int
        , selectedTestInstance : Maybe TestInstance
        , testMouseIsOver : Maybe Int
    }


setNodeId : Maybe Int -> HasSelectedTest model -> HasSelectedTest model
setNodeId nodeId model =
    { model | selectedTestNodeId = nodeId }


setInstance : Maybe TestInstance -> HasSelectedTest model -> HasSelectedTest model
setInstance testInstance model =
    { model | selectedTestInstance = testInstance }


setTestMouseIsOver : Maybe Int -> HasSelectedTest model -> HasSelectedTest model
setTestMouseIsOver nodeId model =
    { model | testMouseIsOver = nodeId }
