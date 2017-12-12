module Animation.Color exposing (fadeTo, initial, oscillate)

import Animation exposing (State, Step, backgroundColor, easing, interrupt, loop, style, toWith)
import Ease exposing (linear)
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


fadeTo : RunStatus -> State -> State
fadeTo runStatus =
    interrupt
        [ toWith
            (easing { duration = fadeDuration, ease = linear })
            [ backgroundColor <| toPrimaryColor runStatus ]
        ]


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
