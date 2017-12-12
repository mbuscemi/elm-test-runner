module Animation.Color exposing (initial, oscillate, pulse)

import Animation exposing (State, Step, backgroundColor, easing, interrupt, loop, style, toWith)
import Ease exposing (inQuad, linear, outQuad)
import State.RunStatus exposing (RunStatus, toPrimaryColor, toSecondaryColor)


fadeDuration : Float
fadeDuration =
    330


oscillateDuration : Float
oscillateDuration =
    660


initial : RunStatus -> State
initial runStatus =
    style [ backgroundColor (toPrimaryColor runStatus) ]


oscillate : RunStatus -> State -> State
oscillate runStatus =
    interrupt
        [ loop
            [ toWith
                (easing { duration = oscillateDuration, ease = linear })
                [ backgroundColor <| toPrimaryColor runStatus ]
            , toWith
                (easing { duration = oscillateDuration, ease = linear })
                [ backgroundColor <| toSecondaryColor runStatus ]
            ]
        ]


pulse : RunStatus -> State -> State
pulse runStatus =
    interrupt
        [ toWith
            (easing { duration = 120, ease = outQuad })
            [ backgroundColor <| toSecondaryColor runStatus ]
        , toWith
            (easing { duration = 540, ease = inQuad })
            [ backgroundColor <| toPrimaryColor runStatus ]
        ]
