port module And exposing (doNothing, execute, executeOnDelay)

import Process
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
