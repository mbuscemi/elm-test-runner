module Message.TestListItem exposing (Message, messages, update)

import And
import And.Editor
import Model.SelectedTest
import Model.TestTree
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree, Tree)


type alias Model model =
    { model
        | projectName : String
        , testRuns : Tree String TestInstance
        , testHierarchy : CollapsibleTree String TestInstance
        , selectedTestNodeId : Maybe Int
        , selectedTestInstance : Maybe TestInstance
        , testMouseIsOver : Maybe Int
        , autoNavigateEnabled : Bool
        , currentWorkingDirectory : String
    }


type Message
    = Expand Int
    | Collapse Int
    | MouseEnter Int
    | MouseLeave
    | Select Int (Maybe TestInstance)


update : Message -> Model model -> ( Model model, Cmd message )
update message model =
    case message of
        Expand nodeId ->
            model
                |> Model.TestTree.toggleNode nodeId True
                |> And.doNothing

        Collapse nodeId ->
            model
                |> Model.TestTree.toggleNode nodeId False
                |> And.doNothing

        MouseEnter nodeId ->
            model
                |> Model.SelectedTest.setTestMouseIsOver (Just nodeId)
                |> And.doNothing

        MouseLeave ->
            model
                |> Model.SelectedTest.setTestMouseIsOver Nothing
                |> And.doNothing

        Select nodeId testInstance ->
            model
                |> Model.SelectedTest.setNodeId (Just nodeId)
                |> Model.SelectedTest.setInstance testInstance
                |> And.Editor.showFile testInstance


type alias Messages =
    { expand : Int -> Message
    , collapse : Int -> Message
    , mouseEnter : Int -> Message
    , mouseLeave : Message
    , select : Int -> Maybe TestInstance -> Message
    }


messages : Messages
messages =
    { expand = Expand
    , collapse = Collapse
    , mouseEnter = MouseEnter
    , mouseLeave = MouseLeave
    , select = Select
    }
