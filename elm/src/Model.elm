module Model exposing (Model, default, serialize)

import Animation
import Animation.Flicker
import Animation.Footer
import Duration.Core exposing (Duration)
import Model.Flags exposing (Flags)
import Model.ProjectName
import State.PaneLocation as PaneLocation exposing (PaneLocation)
import State.RunStatus as RunStatus exposing (RunStatus)
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core as Tree exposing (CollapsibleTree, Tree(Node))


type alias Model =
    { projectName : String
    , compilerError : Maybe String
    , runStatus : RunStatus
    , totalTests : Int
    , passedTests : Int
    , runDuration : Maybe Duration
    , runSeed : Maybe Int
    , testRuns : Tree String TestInstance
    , testHierarchy : CollapsibleTree String TestInstance
    , testMouseIsOver : Maybe Int
    , selectedTestNodeId : Maybe Int
    , selectedTestInstance : Maybe TestInstance
    , autoRunEnabled : Bool
    , autoNavigateEnabled : Bool
    , runElmVerifyExamplesEnabled : Bool
    , randomSeed : Maybe Int
    , forceRandomSeedEnabled : Bool
    , statusBarStyle : Animation.State
    , footerStyle : Animation.State
    , footerExpanded : Bool
    , paneLocation : PaneLocation
    }


default : Model
default =
    { projectName = ""
    , compilerError = Nothing
    , runStatus = RunStatus.noData
    , totalTests = 0
    , passedTests = 0
    , runDuration = Nothing
    , runSeed = Nothing
    , testRuns = Node Model.ProjectName.default TestInstance.default []
    , testHierarchy = Tree.make (Node "No Tests" TestInstance.default [])
    , testMouseIsOver = Nothing
    , selectedTestNodeId = Nothing
    , selectedTestInstance = Nothing
    , autoRunEnabled = False
    , autoNavigateEnabled = True
    , runElmVerifyExamplesEnabled = False
    , randomSeed = Nothing
    , forceRandomSeedEnabled = False
    , statusBarStyle = Animation.Flicker.initial
    , footerStyle = Animation.Footer.initial
    , footerExpanded = False
    , paneLocation = PaneLocation.default
    }


serialize : Model -> Flags
serialize model =
    { autoRun = model.autoRunEnabled
    , autoNavigate = model.autoNavigateEnabled
    , useElmVerifyExamples = model.runElmVerifyExamplesEnabled
    }
