module Animation.Footer exposing (animateDown, animateUp, initial)

import Animation exposing (State, easing, height, interrupt, px, style, toWith)
import Ease exposing (inQuad, outQuad)


initialHeight : Float
initialHeight =
    45


expandedHeight : Float
expandedHeight =
    120


duration : Float
duration =
    700


initial : State
initial =
    style [ height <| px initialHeight ]


animateUp : State -> State
animateUp =
    interrupt
        [ toWith
            (easing { duration = duration, ease = inQuad })
            [ height <| px expandedHeight ]
        ]


animateDown : State -> State
animateDown =
    interrupt
        [ toWith
            (easing { duration = duration, ease = outQuad })
            [ height <| px initialHeight ]
        ]
