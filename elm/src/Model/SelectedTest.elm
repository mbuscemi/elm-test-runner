port module Model.SelectedTest exposing (andShowInEditor, setInstance, setNodeId, setTestMouseIsOver)

import And
import State.NavigationData as NavigationData
import TestInstance.Core as TestInstance exposing (TestInstance)


type alias HasSelectedTest r =
    { r
        | selectedTestNodeId : Maybe Int
        , selectedTestInstance : Maybe TestInstance
        , testMouseIsOver : Maybe Int
    }


type alias ForNavigation r =
    { r
        | autoNavigateEnabled : Bool
        , currentWorkingDirectory : String
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


andShowInEditor : Maybe TestInstance -> ForNavigation model -> ( ForNavigation model, Cmd message )
andShowInEditor testInstance model =
    case ( testInstance, model.autoNavigateEnabled ) of
        ( Just instance, True ) ->
            And.showInEditor (NavigationData.make model.currentWorkingDirectory instance) model

        _ ->
            And.doNothing model
