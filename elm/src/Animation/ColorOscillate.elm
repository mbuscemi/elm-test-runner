module Animation.ColorOscillate exposing (animation, halt, initial)

import Animation exposing (State, Step, backgroundColor, easing, interrupt, loop, style, toWith)
import Color exposing (Color, rgb)
import Ease exposing (linear, outQuad)
import State.RunStatus exposing (RunStatus, toPrimaryColor, toSecondaryColor)


duration : Float
duration =
    660


initial : RunStatus -> State
initial runStatus =
    style [ backgroundColor (toPrimaryColor runStatus) ]


animation : RunStatus -> State -> State
animation runStatus =
    doAnimation (toPrimaryColor runStatus) (toSecondaryColor runStatus)


halt : State -> State
halt =
    interrupt []


doAnimation : Color -> Color -> State -> State
doAnimation color1 color2 =
    interrupt [ loop <| oscillate color1 color2 ]


oscillate : Color -> Color -> List Step
oscillate color1 color2 =
    [ toWith
        (easing { duration = duration, ease = linear })
        [ backgroundColor <| color1 ]
    , toWith
        (easing { duration = duration, ease = linear })
        [ backgroundColor <| color2 ]
    ]
