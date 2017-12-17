port module Message.RandomSeed exposing (Message, messages, update)

import And
import Model.RandomSeed


type alias Model model =
    { model
        | randomSeed : Maybe Int
        , forceRandomSeedEnabled : Bool
    }


type Message
    = Copy String
    | Set Int
    | SetForce Bool


update : Message -> Model model -> ( Model model, Cmd message )
update message model =
    case message of
        Copy seed ->
            model
                |> And.execute (copySeed seed)

        Set seed ->
            Model.RandomSeed.set (Just seed) model
                |> Model.RandomSeed.setForcing True
                |> And.doNothing

        SetForce setting ->
            Model.RandomSeed.setForcing setting model
                |> And.doNothing


type alias Messages =
    { copy : String -> Message
    , set : Int -> Message
    , setForce : Bool -> Message
    }


messages : Messages
messages =
    { copy = Copy
    , set = Set
    , setForce = SetForce
    }


port copySeed : String -> Cmd message
