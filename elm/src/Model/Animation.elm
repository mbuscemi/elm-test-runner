module Model.Animation
    exposing
        ( haltColorOscillation
        , initiateColorOscillation
        , initiateStatusBarTextFlicker
        , toggleFooter
        , updateFooter
        , updateStatusBarColor
        , updateStatusBarText
        )

import Animation
import Animation.ColorOscillate
import Animation.Flicker
import Animation.Footer
import State.RunStatus exposing (RunStatus)


type alias HasAnimationProperties r =
    { r
        | runStatus : RunStatus
        , statusBarTextStyle : Animation.State
        , statusBarColorStyle : Animation.State
        , footerStyle : Animation.State
        , footerExpanded : Bool
    }


initiateColorOscillation : HasAnimationProperties model -> HasAnimationProperties model
initiateColorOscillation model =
    { model | statusBarColorStyle = Animation.ColorOscillate.animation model.runStatus model.statusBarColorStyle }


updateStatusBarColor : Animation.Msg -> HasAnimationProperties model -> HasAnimationProperties model
updateStatusBarColor animationMessage model =
    { model | statusBarColorStyle = Animation.update animationMessage model.statusBarColorStyle }


haltColorOscillation : HasAnimationProperties model -> HasAnimationProperties model
haltColorOscillation model =
    { model | statusBarColorStyle = Animation.ColorOscillate.halt model.statusBarColorStyle }


initiateStatusBarTextFlicker : HasAnimationProperties model -> HasAnimationProperties model
initiateStatusBarTextFlicker model =
    { model | statusBarTextStyle = Animation.Flicker.animation model.statusBarTextStyle }


updateStatusBarText : Animation.Msg -> HasAnimationProperties model -> HasAnimationProperties model
updateStatusBarText animationMessage model =
    { model | statusBarTextStyle = Animation.update animationMessage model.statusBarTextStyle }


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
