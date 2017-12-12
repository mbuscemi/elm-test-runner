module View.Core exposing (render)

import Animation exposing (State)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import State.PaneLocation as PaneLocation exposing (PaneLocation)
import State.RunStatus exposing (RunStatus)
import Tree.Core exposing (CollapsibleTree)
import State.Duration exposing (Duration)
import View.DurationAndSeedDisplay
import View.OutputDisplay
import View.SeedAndSettings
import View.TestHierarchy.Core
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
                , View.DurationAndSeedDisplay.render
                    data.runDuration
                    data.runSeed
                    { copySeedClickHandler = messages.copySeedClickHandler
                    , setSeedClickHandler = messages.setSeedClickHandler
                    }
                ]
            , div [ class "test-hierarchy" ]
                [ View.TestHierarchy.Core.render
                    { statusIndicator = data.statusIndicator
                    , conditionallyEmbolden = data.conditionallyEmbolden
                    }
                    { expand = messages.testListItemExpand
                    , collapse = messages.testListItemCollapse
                    }
                    { mouseIn = messages.testListItemMouseEnter
                    , mouseOut = messages.testListItemMouseLeave
                    , testClick = messages.testClickHandler
                    }
                    { nodeMouseIsOver = data.nodeMouseIsOver
                    , selectedNode = data.selectedNodeId
                    }
                    data.testHierarchy
                ]
            ]
        , div [ class "section-two" ]
            [ div [ class "output-display native-key-bindings" ]
                [ View.OutputDisplay.render data.compilerError data.failure ]
            , div (class "footer" :: Animation.render data.footerStyle)
                (View.SeedAndSettings.render
                    { setForceSeedHandler = messages.setForceSeedHandler
                    , setAutoRun = messages.setAutoRun
                    , setAutoNavigate = messages.setAutoNavigate
                    , setRunElmVerifyExamples = messages.setRunElmVerifyExamples
                    , settingsToggle = messages.settingsToggle
                    }
                    { autoRunEnabled = data.autoRunEnabled
                    , autoNavigateEnabled = data.autoNavigateEnabled
                    , elmVerifyExamplesEnabled = data.elmVerifyExamplesEnabled
                    , forceRandomSeedEnabled = data.forceRandomSeedEnabled
                    , randomSeed = data.randomSeed
                    }
                )
            ]
        ]
