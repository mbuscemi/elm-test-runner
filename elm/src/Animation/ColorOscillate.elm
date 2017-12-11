module Animation.ColorOscillate exposing (halt, processingAnimation, processingInitial)

import Animation exposing (State, Step, backgroundColor, easing, interrupt, loop, style, toWith)
import Color exposing (Color, rgb)
import Ease exposing (linear, outQuad)


duration : Float
duration =
    660


processingColor1 : Color
processingColor1 =
    rgb 48 48 35


processingColor2 : Color
processingColor2 =
    rgb 64 64 34


processingInitial : State
processingInitial =
    style [ backgroundColor processingColor1 ]


processingAnimation : State -> State
processingAnimation =
    animation processingColor1 processingColor2


halt : State -> State
halt =
    interrupt []


animation : Color -> Color -> State -> State
animation color1 color2 =
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
