module Model.RunDuration exposing (clear, set)

import Duration.Core exposing (Duration)
import TestEvent.RunComplete as RunComplete exposing (RunComplete)


type alias WithRunDuration r =
    { r
        | runDuration : Maybe Duration
    }


set : RunComplete -> WithRunDuration model -> WithRunDuration model
set event model =
    { model | runDuration = Just <| RunComplete.duration event }


clear : WithRunDuration model -> WithRunDuration model
clear model =
    { model | runDuration = Nothing }
