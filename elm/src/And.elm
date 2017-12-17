port module And exposing (doNothing, execute, showInEditor, updateAtomState)

import Model.Config exposing (HasConfig)
import Model.Flags exposing (Flags)
import TestInstance.Core as TestInstance exposing (TestInstance)


doNothing : model -> ( model, Cmd message )
doNothing model =
    ( model, Cmd.none )


execute : Cmd message -> model -> ( model, Cmd message )
execute command model =
    ( model, command )


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
