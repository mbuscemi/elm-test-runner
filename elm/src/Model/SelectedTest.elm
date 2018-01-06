port module Model.SelectedTest exposing (andShowInEditor, setInstance, setNodeId, setTestMouseIsOver)

import And
import State.NavigationData as NavigationData
import TestInstance.Core exposing (TestInstance)


type alias TestSelectionModel model testInstance =
    { model
        | selectedTestNodeId : Maybe Int
        , selectedTestInstance : Maybe testInstance
        , testMouseIsOver : Maybe Int
    }


type alias NavigationModel model =
    { model
        | autoNavigateEnabled : Bool
        , currentWorkingDirectory : String
    }


setNodeId : Maybe Int -> TestSelectionModel model testInstance -> TestSelectionModel model testInstance
setNodeId nodeId model =
    { model | selectedTestNodeId = nodeId }


setInstance : Maybe testInstance -> TestSelectionModel model testInstance -> TestSelectionModel model testInstance
setInstance testInstance model =
    { model | selectedTestInstance = testInstance }


setTestMouseIsOver : Maybe Int -> TestSelectionModel model testInstance -> TestSelectionModel model testInstance
setTestMouseIsOver nodeId model =
    { model | testMouseIsOver = nodeId }


andShowInEditor : Maybe TestInstance -> NavigationModel model -> ( NavigationModel model, Cmd message )
andShowInEditor testInstance model =
    case ( testInstance, model.autoNavigateEnabled ) of
        ( Just instance, True ) ->
            And.showInEditor (NavigationData.make model.currentWorkingDirectory instance) model

        _ ->
            And.doNothing model
