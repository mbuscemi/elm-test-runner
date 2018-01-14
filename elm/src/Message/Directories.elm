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
            model
                |> Model.Directories.setProject directories
                |> And.doNothing

        TestableUpdate directories ->
            model
                |> Model.Directories.setTestable directories
                |> And.doNothing

        WorkingChanged directory ->
            model
                |> Model.Directories.setWorking directory
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
