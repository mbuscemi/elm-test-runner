module Message.Directories exposing (Message, messages, update)

import And
import Model.Directories


type alias Model model =
    { model
        | projectDirectories : List String
        , testableElmDirectories : List String
        , currentWorkingDirectory : String
        , hasRegisteredDirectories : Bool
    }


type Message
    = ProjectUpdate (List String)
    | TestableUpdate (List String)
    | WorkingChanged String


update : Message -> Model model -> ( Model model, Cmd message )
update message model =
    case message of
        ProjectUpdate directories ->
            Model.Directories.setProject directories model
                |> And.doNothing

        TestableUpdate directories ->
            Model.Directories.setTestable directories model
                |> And.doNothing

        WorkingChanged directory ->
            Model.Directories.setWorking directory model
                |> And.doNothing


type alias Messages =
    { updateProject : List String -> Message
    , updateTestable : List String -> Message
    , changeWorking : String -> Message
    }


messages : Messages
messages =
    { updateProject = ProjectUpdate
    , updateTestable = TestableUpdate
    , changeWorking = WorkingChanged
    }
