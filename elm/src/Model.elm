module Model exposing (Model, default)

import Animation
import Animation.Color
import Animation.Flicker
import Animation.Footer
import Model.ProjectName
import State.Duration exposing (Duration)
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
    , statusBarTextStyle : Animation.State
    , statusBarColorStyle : Animation.State
    , footerStyle : Animation.State
    , footerExpanded : Bool
    , paneLocation : PaneLocation
    , projectDirectories : List String
    , testableElmDirectories : List String
    , currentWorkingDirectory : String
    , hasRegisteredDirectories : Bool
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
    , statusBarTextStyle = Animation.Flicker.initial
    , statusBarColorStyle = Animation.Color.initial RunStatus.noData
    , footerStyle = Animation.Footer.initial
    , footerExpanded = False
    , paneLocation = PaneLocation.default
    , projectDirectories = []
    , testableElmDirectories = []
    , currentWorkingDirectory = ""
    , hasRegisteredDirectories = False
    }
