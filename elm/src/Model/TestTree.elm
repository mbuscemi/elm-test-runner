module Model.TestTree exposing (build, expandFailingAndTodoNodes, purgeObsoleteNodes, reset, selectLastNodeWithFailureData, toggleNode, updateHierarchy)

import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)
import TestInstance.Core as TestInstance exposing (TestInstance)
import TestInstance.Reconcile
import Tree.Core as Tree exposing (CollapsibleTree, Tree(Node))
import Tree.Merge
import Tree.Node
import Tree.Traverse


type alias Model model =
    { model
        | projectName : String
        , testRuns : Tree String TestInstance
        , testHierarchy : CollapsibleTree String TestInstance
        , selectedTestNodeId : Maybe Int
        , selectedTestInstance : Maybe TestInstance
    }


build : TestCompleted -> Model model -> Model model
build event model =
    { model
        | testRuns =
            Tree.Merge.fromPath
                (model.projectName :: TestCompleted.labels event)
                (TestInstance.fromEvent event)
                TestInstance.Reconcile.transform
                model.testRuns
    }


reset : Model model -> Model model
reset model =
    { model | testRuns = Tree.Traverse.update (TestInstance.setStatus "pending") model.testRuns }


purgeObsoleteNodes : Model model -> Model model
purgeObsoleteNodes model =
    { model | testRuns = Tree.Traverse.purge (not << TestInstance.isPending) model.testRuns }


updateHierarchy : Model model -> Model model
updateHierarchy model =
    { model | testHierarchy = Tree.make model.testRuns }


toggleNode : Int -> Bool -> Model model -> Model model
toggleNode nodeId newState model =
    { model | testHierarchy = Tree.Node.toggle nodeId newState model.testHierarchy }


expandFailingAndTodoNodes : Model model -> Model model
expandFailingAndTodoNodes model =
    { model | testHierarchy = toggleFailingAndTodoNodes model.testHierarchy }


toggleFailingAndTodoNodes : CollapsibleTree String TestInstance -> CollapsibleTree String TestInstance
toggleFailingAndTodoNodes (Node ( name, _, nodeId ) testInstance children) =
    Node ( name, TestInstance.isFailingOrTodo testInstance, nodeId ) testInstance (List.map toggleFailingAndTodoNodes children)


selectLastNodeWithFailureData : Model model -> Model model
selectLastNodeWithFailureData model =
    let
        maybeNode =
            lastNodeWithFailureData model.testHierarchy
    in
    { model
        | selectedTestNodeId = Maybe.map Tuple.first maybeNode
        , selectedTestInstance = Maybe.map Tuple.second maybeNode
    }


lastNodeWithFailureData : CollapsibleTree String TestInstance -> Maybe ( Int, TestInstance )
lastNodeWithFailureData testHierarchy =
    Tree.Traverse.findChildlessNodes TestInstance.hasFailureData testHierarchy
        |> Maybe.map (\tree -> ( Tree.getId tree, Tree.getData tree ))
