module Animation.Flicker exposing (animation, initial)

import Animation exposing (State, Step, interrupt, opacity, repeat, set, style, wait)


initial : State
initial =
    style [ opacity 1.0 ]


animation : State -> State
animation =
    interrupt
        [ onAndOff 1 5.0
        , onAndOff 1 10.0
        , onAndOff 3 20.0
        , onAndOff 2 50.0
        , onAndOff 1 100.0
        ]


onAndOff : Int -> Float -> Step
onAndOff times milliseconds =
    repeat
        times
        [ set [ opacity 0.0 ]
        , wait milliseconds
        , set [ opacity 1.0 ]
        , wait milliseconds
        ]
