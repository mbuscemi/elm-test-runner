module View.Main exposing (render)

import Duration.Core exposing (Duration)
import Html exposing (Html, div, h2, section, span, text)
import Html.Attributes exposing (class)
import State.RunStatus as RunStatus exposing (RunStatus)
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree)
import View.DurationAndSeedDisplay
import View.PassingTestsDisplay
import View.RedGreenDisplay
import View.TestHierarchy
import View.Toolbar


type alias Messages message =
    { toggleClickHandler : message
    , runAllButtonClickHandler : message
    , testListItemExpand : Int -> message
    , testListItemCollapse : Int -> message
    }


type alias DisplayData =
    { runStatus : RunStatus
    , totalTests : Int
    , passedTests : Int
    , runDuration : Maybe Duration
    , runSeed : Maybe Int
    , testHierarchy : CollapsibleTree String TestInstance
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
            [ View.TestHierarchy.render data.testHierarchy { expand = messages.testListItemExpand, collapse = messages.testListItemCollapse }
            ]
        , div [ class "output-display" ] []
        , div [ class "footer" ] []
        ]
