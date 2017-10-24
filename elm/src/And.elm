port module And exposing (execute, noCommand, updateAtomState)

import Model exposing (Model)
import Model.Flags exposing (Flags)


noCommand : model -> ( model, Cmd message )
noCommand model =
    ( model, Cmd.none )


execute : Cmd message -> model -> ( model, Cmd message )
execute command model =
    ( model, command )


updateAtomState : Model -> ( Model, Cmd message )
updateAtomState model =
    Model.serialize model
        |> updatePersistentState
        |> flip execute model


port updatePersistentState : Flags -> Cmd message
