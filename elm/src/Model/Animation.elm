module Model.Animation exposing (initiateStatusBarTextFlicker, toggleFooter, updateFooter, updateStatusBar)

import Animation
import Animation.Flicker
import Animation.Footer


type alias HasAnimationProperties r =
    { r
        | statusBarStyle : Animation.State
        , footerStyle : Animation.State
        , footerExpanded : Bool
    }


updateStatusBar : Animation.Msg -> HasAnimationProperties model -> HasAnimationProperties model
updateStatusBar animationMessage model =
    { model | statusBarStyle = Animation.update animationMessage model.statusBarStyle }


initiateStatusBarTextFlicker : HasAnimationProperties model -> HasAnimationProperties model
initiateStatusBarTextFlicker model =
    { model | statusBarStyle = Animation.Flicker.animation model.statusBarStyle }


updateFooter : Animation.Msg -> HasAnimationProperties model -> HasAnimationProperties model
updateFooter animationMessage model =
    { model | footerStyle = Animation.update animationMessage model.footerStyle }


toggleFooter : HasAnimationProperties model -> HasAnimationProperties model
toggleFooter model =
    if model.footerExpanded then
        retractFooter model
    else
        expandFooter model


expandFooter : HasAnimationProperties model -> HasAnimationProperties model
expandFooter model =
    { model
        | footerStyle = Animation.Footer.animateUp model.footerStyle
        , footerExpanded = True
    }


retractFooter : HasAnimationProperties model -> HasAnimationProperties model
retractFooter model =
    { model
        | footerStyle = Animation.Footer.animateDown model.footerStyle
        , footerExpanded = False
    }
