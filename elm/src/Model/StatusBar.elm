module Model.StatusBar exposing (initiateTextFlicker, updateFlicker)

import Animation
import Animation.Flicker


type alias HasStatusBar r =
    { r
        | statusBarStyle : Animation.State
    }


updateFlicker : Animation.Msg -> HasStatusBar model -> HasStatusBar model
updateFlicker animationMessage model =
    { model | statusBarStyle = Animation.update animationMessage model.statusBarStyle }


initiateTextFlicker : HasStatusBar model -> HasStatusBar model
initiateTextFlicker model =
    { model | statusBarStyle = Animation.Flicker.animation model.statusBarStyle }
