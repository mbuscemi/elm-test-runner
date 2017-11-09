port module Model.SelectedTest exposing (setInstance, setNodeId, showInEditor)

import And
import TestInstance.Core as TestInstance exposing (TestInstance)


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


showInEditor : Maybe TestInstance -> Bool -> model -> ( model, Cmd message )
showInEditor testInstance autoNavigateEnabled =
    case ( testInstance, autoNavigateEnabled ) of
        ( Just instance, True ) ->
            And.execute <| navigateToFile (TestInstance.pathAndDescription instance)

        _ ->
            And.noCommand


port navigateToFile : ( String, List String ) -> Cmd message
