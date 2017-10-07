module View.Core exposing (render)

import Duration.Core exposing (Duration)
import Html exposing (Html, div, h2, section, span, text)
import Html.Attributes exposing (class)
import State.RunStatus as RunStatus exposing (RunStatus)
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree)
import View.AutoRunOnSave
import View.DurationAndSeedDisplay
import View.PassingTestsDisplay
import View.RedGreenDisplay
import View.TestHierarchy.Core
import View.Toolbar


type alias Messages message =
    { toggleClickHandler : message
    , runAllButtonClickHandler : message
    , testListItemExpand : Int -> message
    , testListItemCollapse : Int -> message
    , testListItemMouseEnter : Int -> message
    , testListItemMouseLeave : message
    , testClickHandler : Int -> message
    }


type alias DisplayData =
    { runStatus : RunStatus
    , totalTests : Int
    , passedTests : Int
    , runDuration : Maybe Duration
    , runSeed : Maybe Int
    , testHierarchy : CollapsibleTree String TestInstance
    , nodeMouseIsOver : Maybe Int
    , selectedNode : Maybe Int
    , autoRunEnabled : Bool
    }


render : DisplayData -> Messages message -> Html message
render data messages =
    div [ class "etr-main-view" ]
        [ div [ class "core" ]
            [ View.Toolbar.render messages.toggleClickHandler messages.runAllButtonClickHandler
            , View.RedGreenDisplay.render data.runStatus
            , View.PassingTestsDisplay.render data.totalTests data.passedTests
            , View.DurationAndSeedDisplay.render data.runDuration data.runSeed
            ]
        , div [ class "test-hierarchy" ]
            [ View.TestHierarchy.Core.render
                { expand = messages.testListItemExpand
                , collapse = messages.testListItemCollapse
                }
                { mouseIn = messages.testListItemMouseEnter
                , mouseOut = messages.testListItemMouseLeave
                , testClick = messages.testClickHandler
                }
                { nodeMouseIsOver = data.nodeMouseIsOver
                , selectedNode = data.selectedNode
                }
                data.testHierarchy
            ]
        , div [ class "output-display" ] []
        , div [ class "footer" ]
            [ View.AutoRunOnSave.render data.autoRunEnabled
            ]
        ]
