module Message.Settings exposing (Message, messages, update)

import And
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
            Model.Config.invertAutoRun model
                |> And.updateAtomState

        SetAutoRun state ->
            Model.Config.setAutoRun state model
                |> And.updateAtomState

        ToggleAutoNavigate ->
            Model.Config.invertAutoNavigate model
                |> And.updateAtomState

        SetAutoNavigate state ->
            Model.Config.setAutoNavigate state model
                |> And.updateAtomState

        ToggleRunElmVerifyExamples ->
            Model.Config.invertElmVerifyExamples model
                |> And.updateAtomState

        SetRunElmVerifyExamples state ->
            Model.Config.setElmVerifyExamples state model
                |> And.updateAtomState


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
