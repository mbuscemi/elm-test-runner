module View exposing (render)

import Animation exposing (State)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import State.Duration exposing (Duration)
import State.PaneLocation as PaneLocation exposing (PaneLocation)
import State.RunStatus exposing (RunStatus)
import Tree.Core exposing (CollapsibleTree)
import View.DurationAndSeedDisplay
import View.OutputDisplay
import View.ProjectSelector
import View.SeedAndSettings
import View.TestHierarchy
import View.Toolbar


type alias Data message testInstance =
    { runStatus : RunStatus
    , compilerError : Maybe String
    , totalTests : Int
    , passedTests : Int
    , runDuration : Maybe Duration
    , runSeed : Maybe Int
    , testHierarchy : CollapsibleTree String testInstance
    , statusIndicator : testInstance -> Html message
    , conditionallyEmbolden : Bool -> String -> testInstance -> Html message
    , nodeMouseIsOver : Maybe Int
    , selectedNodeId : Maybe Int
    , selectedTestInstance : Maybe testInstance
    , failure : Maybe Failure
    , autoRunEnabled : Bool
    , autoNavigateEnabled : Bool
    , elmVerifyExamplesEnabled : Bool
    , randomSeed : Maybe Int
    , forceRandomSeedEnabled : Bool
    , statusBarTextStyle : State
    , statusBarColorStyle : State
    , footerStyle : State
    , paneLocation : PaneLocation
    , projectDirectories : List String
    , testableElmDirectories : List String
    }


type alias Messages message testInstance =
    { runAllButtonClickHandler : message
    , testListItemExpand : Int -> message
    , testListItemCollapse : Int -> message
    , testListItemMouseEnter : Int -> message
    , testListItemMouseLeave : message
    , testClickHandler : Int -> Maybe testInstance -> message
    , copySeedClickHandler : String -> message
    , setSeedClickHandler : Int -> message
    , setForceSeedHandler : Bool -> message
    , setAutoRun : Bool -> message
    , setAutoNavigate : Bool -> message
    , setRunElmVerifyExamples : Bool -> message
    , settingsToggle : message
    , workingDirectoryChanged : String -> message
    }


type alias Failure =
    { actual : String
    , expected : String
    , given : Maybe String
    , message : String
    , hasComplexComparison : Bool
    , isTodo : Bool
    , shouldDiff : Bool
    }


render : Data message testInstance -> Messages message testInstance -> Html message
render data messages =
    div [ class <| "etr-main-view " ++ PaneLocation.toStyle data.paneLocation ]
        [ div [ class "section-one" ]
            [ div [ class "core" ]
                [ View.Toolbar.render
                    { totalTests = data.totalTests
                    , passedTests = data.passedTests
                    , runStatus = data.runStatus
                    , statusBarTextStyle = data.statusBarTextStyle
                    , statusBarColorStyle = data.statusBarColorStyle
                    }
                    messages.runAllButtonClickHandler
                , View.ProjectSelector.render
                    { projectDirectories = data.projectDirectories
                    , testableElmDirectories = data.testableElmDirectories
                    }
                    { workingDirectoryChanged = messages.workingDirectoryChanged }
                , View.DurationAndSeedDisplay.render
                    { runDuration = data.runDuration
                    , runSeed = data.runSeed
                    }
                    { copySeedClickHandler = messages.copySeedClickHandler
                    , setSeedClickHandler = messages.setSeedClickHandler
                    }
                ]
            , div [ class "test-hierarchy" ]
                [ View.TestHierarchy.render
                    { statusIndicator = data.statusIndicator
                    , conditionallyEmbolden = data.conditionallyEmbolden
                    }
                    { nodeMouseIsOver = data.nodeMouseIsOver
                    , selectedNode = data.selectedNodeId
                    }
                    { expand = messages.testListItemExpand
                    , collapse = messages.testListItemCollapse
                    }
                    { mouseIn = messages.testListItemMouseEnter
                    , mouseOut = messages.testListItemMouseLeave
                    , testClick = messages.testClickHandler
                    }
                    data.testHierarchy
                ]
            ]
        , div [ class "section-two" ]
            [ div [ class "output-display native-key-bindings" ]
                [ View.OutputDisplay.render data.compilerError data.failure ]
            , div (class "footer" :: Animation.render data.footerStyle)
                (View.SeedAndSettings.render
                    { autoRunEnabled = data.autoRunEnabled
                    , autoNavigateEnabled = data.autoNavigateEnabled
                    , elmVerifyExamplesEnabled = data.elmVerifyExamplesEnabled
                    , forceRandomSeedEnabled = data.forceRandomSeedEnabled
                    , randomSeed = data.randomSeed
                    }
                    { setForceSeedHandler = messages.setForceSeedHandler
                    , setAutoRun = messages.setAutoRun
                    , setAutoNavigate = messages.setAutoNavigate
                    , setRunElmVerifyExamples = messages.setRunElmVerifyExamples
                    , settingsToggle = messages.settingsToggle
                    }
                )
            ]
        ]
