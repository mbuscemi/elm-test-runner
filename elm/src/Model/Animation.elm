module Model.Animation
    exposing
        ( initiateColorOscillation
        , initiateStatusBarTextFlicker
        , pulseToStatusColor
        , toggleFooter
        , updateFooter
        , updateStatusBarColor
        , updateStatusBarText
        )

import Animation
import Animation.Color
import Animation.Flicker
import Animation.Footer
import State.RunStatus exposing (RunStatus)


type alias Model model =
    { model
        | runStatus : RunStatus
        , statusBarTextStyle : Animation.State
        , statusBarColorStyle : Animation.State
        , footerStyle : Animation.State
        , footerExpanded : Bool
    }


initiateColorOscillation : Model model -> Model model
initiateColorOscillation model =
    { model | statusBarColorStyle = Animation.Color.oscillate model.runStatus model.statusBarColorStyle }


updateStatusBarColor : Animation.Msg -> Model model -> Model model
updateStatusBarColor animationMessage model =
    { model | statusBarColorStyle = Animation.update animationMessage model.statusBarColorStyle }


pulseToStatusColor : Model model -> Model model
pulseToStatusColor model =
    { model | statusBarColorStyle = Animation.Color.pulse model.runStatus model.statusBarColorStyle }


initiateStatusBarTextFlicker : Model model -> Model model
initiateStatusBarTextFlicker model =
    { model | statusBarTextStyle = Animation.Flicker.animation model.statusBarTextStyle }


updateStatusBarText : Animation.Msg -> Model model -> Model model
updateStatusBarText animationMessage model =
    { model | statusBarTextStyle = Animation.update animationMessage model.statusBarTextStyle }


updateFooter : Animation.Msg -> Model model -> Model model
updateFooter animationMessage model =
    { model | footerStyle = Animation.update animationMessage model.footerStyle }


toggleFooter : Model model -> Model model
toggleFooter model =
    if model.footerExpanded then
        retractFooter model
    else
        expandFooter model


expandFooter : Model model -> Model model
expandFooter model =
    { model
        | footerStyle = Animation.Footer.animateUp model.footerStyle
        , footerExpanded = True
    }


retractFooter : Model model -> Model model
retractFooter model =
    { model
        | footerStyle = Animation.Footer.animateDown model.footerStyle
        , footerExpanded = False
    }
