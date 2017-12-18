port module And exposing (doNothing, execute, executeOnDelay, showInEditor, updateAtomState)

import Model.Config exposing (HasConfig)
import Model.Flags exposing (Flags)
import Process
import Task
import TestInstance.Core as TestInstance exposing (TestInstance)


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


showInEditor : Maybe TestInstance -> Bool -> model -> ( model, Cmd message )
showInEditor testInstance autoNavigateEnabled =
    case ( testInstance, autoNavigateEnabled ) of
        ( Just instance, True ) ->
            execute <| navigateToFile (TestInstance.pathAndDescription instance)

        _ ->
            doNothing


port updatePersistentState : Flags -> Cmd message


port navigateToFile : ( List String, String ) -> Cmd message
