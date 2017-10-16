module View.Core exposing (render)

import Duration.Core exposing (Duration)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import State.Failure exposing (Failure)
import State.RunStatus exposing (RunStatus)
import TestInstance.Core exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree)
import View.DurationAndSeedDisplay
import View.OutputDisplay
import View.PassingTestsDisplay
import View.RedGreenDisplay
import View.SeedAndAutoRun
import View.TestHierarchy.Core
import View.Toolbar


type alias Messages message =
    { runAllButtonClickHandler : message
    , testListItemExpand : Int -> message
    , testListItemCollapse : Int -> message
    , testListItemMouseEnter : Int -> message
    , testListItemMouseLeave : message
    , testClickHandler : Int -> Maybe Failure -> message
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
    , selectedNode : Maybe Int
    , selectedNodeFailure : Maybe Failure
    , autoRunEnabled : Bool
    , randomSeed : Maybe Int
    , forceRandomSeedEnabled : Bool
    }


render : DisplayData -> Messages message -> Html message
render data messages =
    div [ class "etr-main-view" ]
        [ div [ class "core" ]
            [ View.Toolbar.render messages.runAllButtonClickHandler
            , View.RedGreenDisplay.render data.runStatus
            , View.PassingTestsDisplay.render data.totalTests data.passedTests
            , View.DurationAndSeedDisplay.render
                data.runDuration
                data.runSeed
                { copySeedClickHandler = messages.copySeedClickHandler
                , setSeedClickHandler = messages.setSeedClickHandler
                }
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
        , div [ class "output-display" ]
            [ View.OutputDisplay.render data.compilerError data.selectedNodeFailure ]
        , div [ class "footer" ]
            (View.SeedAndAutoRun.render
                messages.setForceSeedHandler
                data.autoRunEnabled
                data.forceRandomSeedEnabled
                data.randomSeed
            )
        ]
