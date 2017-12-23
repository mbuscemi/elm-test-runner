module Message.TestListItem exposing (Message, messages, update)

import And
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
            Model.TestTree.toggleNode nodeId True model
                |> And.doNothing

        Collapse nodeId ->
            Model.TestTree.toggleNode nodeId False model
                |> And.doNothing

        MouseEnter nodeId ->
            Model.SelectedTest.setTestMouseIsOver (Just nodeId) model
                |> And.doNothing

        MouseLeave ->
            Model.SelectedTest.setTestMouseIsOver Nothing model
                |> And.doNothing

        Select nodeId testInstance ->
            Model.SelectedTest.setNodeId (Just nodeId) model
                |> Model.SelectedTest.setInstance testInstance
                |> Model.SelectedTest.andShowInEditor testInstance


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
