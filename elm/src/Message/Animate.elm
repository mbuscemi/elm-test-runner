module Message.Animate exposing (Message, messages, update)

import And
import Animation
import Model.Animation
import State.RunStatus exposing (RunStatus)


type alias Model model =
    { model
        | runStatus : RunStatus
        , statusBarTextStyle : Animation.State
        , statusBarColorStyle : Animation.State
        , footerStyle : Animation.State
        , footerExpanded : Bool
    }


type Message
    = Flicker Animation.Msg
    | OscillateColor Animation.Msg
    | SettingsTransition Animation.Msg


update : Message -> Model model -> ( Model model, Cmd message )
update message model =
    case message of
        Flicker animateMessage ->
            model
                |> Model.Animation.updateStatusBarText animateMessage
                |> And.doNothing

        OscillateColor animateMessage ->
            model
                |> Model.Animation.updateStatusBarColor animateMessage
                |> And.doNothing

        SettingsTransition animateMessage ->
            model
                |> Model.Animation.updateFooter animateMessage
                |> And.doNothing


type alias Messages =
    { flicker : Animation.Msg -> Message
    , oscillateColor : Animation.Msg -> Message
    , settingsTransition : Animation.Msg -> Message
    }


messages : Messages
messages =
    { flicker = Flicker
    , oscillateColor = OscillateColor
    , settingsTransition = SettingsTransition
    }
