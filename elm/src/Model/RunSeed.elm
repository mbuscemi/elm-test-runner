module Model.RunSeed exposing (clear, set)

import TestEvent.RunStart as RunStart exposing (RunStart)


type alias WithRunSeed r =
    { r
        | runSeed : Maybe Int
    }


set : RunStart -> WithRunSeed model -> WithRunSeed model
set event model =
    { model | runSeed = Just <| RunStart.initialSeed event }


clear : WithRunSeed model -> WithRunSeed model
clear model =
    { model | runSeed = Nothing }
