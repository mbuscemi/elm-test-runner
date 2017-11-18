module View.Core exposing (render)

import Animation exposing (State)
import Duration.Core exposing (Duration)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import State.PaneLocation as PaneLocation exposing (PaneLocation)
import State.RunStatus exposing (RunStatus)
import TestInstance.Core as TestInstance exposing (TestInstance)
import TestInstance.View
import Tree.Core exposing (CollapsibleTree)
import View.DurationAndSeedDisplay
import View.OutputDisplay
import View.SeedAndSettings
import View.TestHierarchy.Core
import View.Toolbar


type alias Messages message =
    { runAllButtonClickHandler : message
    , testListItemExpand : Int -> message
    , testListItemCollapse : Int -> message
    , testListItemMouseEnter : Int -> message
    , testListItemMouseLeave : message
    , testClickHandler : Int -> Maybe TestInstance -> message
    , copySeedClickHandler : String -> message
    , setSeedClickHandler : Int -> message
    , setForceSeedHandler : Bool -> message
    }


type alias DisplayData =
    { runStatus : RunStatus
    , compilerError : Maybe String
    , totalTests : Int
    , passedTests : Int
    , runDuration : Maybe Duration
    , runSeed : Maybe Int
    , testHierarchy : CollapsibleTree String TestInstance
    , nodeMouseIsOver : Maybe Int
    , selectedNodeId : Maybe Int
    , selectedTestInstance : Maybe TestInstance
    , autoRunEnabled : Bool
    , autoNavigateEnabled : Bool
    , randomSeed : Maybe Int
    , forceRandomSeedEnabled : Bool
    , statusBarTextStyle : State
    , paneLocation : PaneLocation
    }


render : DisplayData -> Messages message -> Html message
render data messages =
    div [ class <| "etr-main-view " ++ PaneLocation.toStyle data.paneLocation ]
        [ div [ class "section-one" ]
            [ div [ class "core" ]
                [ View.Toolbar.render data.totalTests data.passedTests data.runStatus data.statusBarTextStyle messages.runAllButtonClickHandler
                , View.DurationAndSeedDisplay.render
                    data.runDuration
                    data.runSeed
                    { copySeedClickHandler = messages.copySeedClickHandler
                    , setSeedClickHandler = messages.setSeedClickHandler
                    }
                ]
            , div [ class "test-hierarchy" ]
                [ View.TestHierarchy.Core.render
                    { statusIndicator = TestInstance.View.statusIndicator
                    , conditionallyEmbolden = TestInstance.View.conditionallyEmbolden
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
            [ div [ class "output-display" ]
                [ View.OutputDisplay.render data.compilerError <| TestInstance.getFailureData data.selectedTestInstance ]
            , div [ class "footer" ]
                (View.SeedAndSettings.render
                    messages.setForceSeedHandler
                    data.autoRunEnabled
                    data.autoNavigateEnabled
                    data.forceRandomSeedEnabled
                    data.randomSeed
                )
            ]
        ]
