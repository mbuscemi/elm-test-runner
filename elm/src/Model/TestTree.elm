module Model.TestTree exposing (build, purgeObsoleteNodes, reset)

import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)
import TestInstance.Core as TestInstance exposing (TestInstance)
import TestInstance.Reconcile
import Tree.Core exposing (Tree)
import Tree.Merge
import Tree.Traverse


type alias WithTestRuns r =
    { r
        | projectName : String
        , testRuns : Tree String TestInstance
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
