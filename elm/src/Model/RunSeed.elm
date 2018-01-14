module Model.RunSeed exposing (clear, set)

import TestEvent.RunStart as RunStart exposing (RunStart)


type alias Model model =
    { model
        | runSeed : Maybe Int
    }


set : RunStart -> Model model -> Model model
set event model =
    { model | runSeed = Just <| RunStart.initialSeed event }


clear : Model model -> Model model
clear model =
    { model | runSeed = Nothing }
