module Message.Settings exposing (Message, messages, update)

import And.Editor
import Model.Config


type alias Model model =
    { model
        | autoRunEnabled : Bool
        , autoNavigateEnabled : Bool
        , runElmVerifyExamplesEnabled : Bool
    }


type Message
    = ToggleAutoRun
    | SetAutoRun Bool
    | ToggleAutoNavigate
    | SetAutoNavigate Bool
    | ToggleRunElmVerifyExamples
    | SetRunElmVerifyExamples Bool


update : Message -> Model model -> ( Model model, Cmd message )
update message model =
    case message of
        ToggleAutoRun ->
            model
                |> Model.Config.invertAutoRun
                |> And.Editor.updateState

        SetAutoRun state ->
            model
                |> Model.Config.setAutoRun state
                |> And.Editor.updateState

        ToggleAutoNavigate ->
            model
                |> Model.Config.invertAutoNavigate
                |> And.Editor.updateState

        SetAutoNavigate state ->
            model
                |> Model.Config.setAutoNavigate state
                |> And.Editor.updateState

        ToggleRunElmVerifyExamples ->
            model
                |> Model.Config.invertElmVerifyExamples
                |> And.Editor.updateState

        SetRunElmVerifyExamples state ->
            model
                |> Model.Config.setElmVerifyExamples state
                |> And.Editor.updateState


type alias Messages =
    { autoRun :
        { toggle : Message
        , set : Bool -> Message
        }
    , autoNavigate :
        { toggle : Message
        , set : Bool -> Message
        }
    , runElmVerifyExamples :
        { toggle : Message
        , set : Bool -> Message
        }
    }


messages : Messages
messages =
    { autoRun =
        { toggle = ToggleAutoRun
        , set = SetAutoRun
        }
    , autoNavigate =
        { toggle = ToggleAutoNavigate
        , set = SetAutoNavigate
        }
    , runElmVerifyExamples =
        { toggle = ToggleRunElmVerifyExamples
        , set = SetRunElmVerifyExamples
        }
    }
