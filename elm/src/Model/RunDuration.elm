module Model.RunDuration exposing (clear, set)

import State.Duration exposing (Duration)
import TestEvent.RunComplete as RunComplete exposing (RunComplete)


type alias Model model =
    { model
        | runDuration : Maybe Duration
    }


set : RunComplete -> Model model -> Model model
set event model =
    { model | runDuration = Just <| RunComplete.duration event }


clear : Model model -> Model model
clear model =
    { model | runDuration = Nothing }
