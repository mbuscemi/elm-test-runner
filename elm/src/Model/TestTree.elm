module Model.TestTree
    exposing
        ( build
        , expandFailingAndTodoNodes
        , purgeObsoleteNodes
        , reset
        , selectLastNodeWithFailureData
        , toggleNode
        , updateHierarchy
        )

import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)
import TestInstance.Core as TestInstance exposing (TestInstance)
import TestInstance.Reconcile
import Tree.Core as Tree exposing (CollapsibleTree, Tree(Node))
import Tree.Merge
import Tree.Node
import Tree.Traverse


type alias WithTestRuns r =
    { r
        | projectName : String
        , testRuns : Tree String TestInstance
        , testHierarchy : CollapsibleTree String TestInstance
        , selectedTestNodeId : Maybe Int
        , selectedTestInstance : Maybe TestInstance
    }


build : TestCompleted -> WithTestRuns model -> WithTestRuns model
build event model =
    { model
        | testRuns =
            Tree.Merge.fromPath
                (model.projectName :: TestCompleted.labels event)
                (TestInstance.fromEvent event)
                TestInstance.Reconcile.transform
                model.testRuns
    }


reset : WithTestRuns model -> WithTestRuns model
reset model =
    { model
        | testRuns =
            Tree.Traverse.update
                (TestInstance.setStatus "pending")
                model.testRuns
    }


purgeObsoleteNodes : WithTestRuns model -> WithTestRuns model
purgeObsoleteNodes model =
    { model
        | testRuns =
            Tree.Traverse.purge
                (not << TestInstance.isPending)
                model.testRuns
    }


updateHierarchy : WithTestRuns model -> WithTestRuns model
updateHierarchy model =
    { model
        | testHierarchy =
            model.testRuns
                |> Tree.make
    }


toggleNode : Int -> Bool -> WithTestRuns model -> WithTestRuns model
toggleNode nodeId newState model =
    { model | testHierarchy = Tree.Node.toggle nodeId newState model.testHierarchy }


expandFailingAndTodoNodes : WithTestRuns model -> WithTestRuns model
expandFailingAndTodoNodes model =
    { model | testHierarchy = toggleFailingAndTodoNodes model.testHierarchy }


toggleFailingAndTodoNodes : CollapsibleTree String TestInstance -> CollapsibleTree String TestInstance
toggleFailingAndTodoNodes (Node ( name, _, nodeId ) testInstance children) =
    let
        expanded =
            TestInstance.isFailing testInstance || TestInstance.isTodo testInstance
    in
    Node ( name, expanded, nodeId ) testInstance <|
        List.map toggleFailingAndTodoNodes children


selectLastNodeWithFailureData : WithTestRuns model -> WithTestRuns model
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
