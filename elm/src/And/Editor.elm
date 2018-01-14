port module And.Editor exposing (showFile, updateState)

import And
import Model.Config exposing (Model)
import Model.Flags exposing (Flags)
import State.NavigationData as NavigationData exposing (NavigationData)
import TestInstance.Core exposing (TestInstance)


updateState : Model model -> ( Model model, Cmd message )
updateState model =
    Model.Config.serialize model
        |> updatePersistentState
        |> flip And.execute model


type alias ShowFileModel model =
    { model
        | autoNavigateEnabled : Bool
        , currentWorkingDirectory : String
    }


showFile : Maybe TestInstance -> ShowFileModel model -> ( ShowFileModel model, Cmd message )
showFile maybeTestInstance model =
    case ( maybeTestInstance, model.autoNavigateEnabled ) of
        ( Just instance, True ) ->
            And.execute (navigateToFile <| NavigationData.make model.currentWorkingDirectory instance) model

        _ ->
            And.doNothing model


port updatePersistentState : Flags -> Cmd message


port navigateToFile : NavigationData -> Cmd message
