port module And exposing (doNothing, execute, executeOnDelay, showInEditor, updateAtomState)

import Model.Config exposing (HasConfig)
import Model.Flags exposing (Flags)
import Process
import State.NavigationData exposing (NavigationData)
import Task


doNothing : model -> ( model, Cmd message )
doNothing model =
    ( model, Cmd.none )


execute : Cmd message -> model -> ( model, Cmd message )
execute command model =
    ( model, command )


executeOnDelay : message -> model -> ( model, Cmd message )
executeOnDelay message model =
    ( model
    , Process.sleep 100
        |> Task.andThen (always <| Task.succeed message)
        |> Task.perform identity
    )


updateAtomState : HasConfig model -> ( HasConfig model, Cmd message )
updateAtomState model =
    Model.Config.serialize model
        |> updatePersistentState
        |> flip execute model


showInEditor : NavigationData -> model -> ( model, Cmd message )
showInEditor data =
    execute <| navigateToFile data


port updatePersistentState : Flags -> Cmd message


port navigateToFile : NavigationData -> Cmd message
