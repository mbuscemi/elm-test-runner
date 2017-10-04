module View.Main exposing (render)

import Html exposing (Html, div, h2, section, span, text)
import Html.Attributes exposing (class)
import State.RunStatus as RunStatus exposing (RunStatus)
import Tree.Tree exposing (Tree)
import View.PassingTestsDisplay
import View.RedGreenDisplay
import View.TestHierarchy
import View.Toolbar


type alias Messages message =
    { toggleClickHandler : message
    , runAllButtonClickHandler : message
    }


render : RunStatus -> Int -> Int -> Tree String -> Messages message -> Html message
render runStatus totalTests passedTests testRuns messages =
    div [ class "etr-main-view" ]
        [ View.Toolbar.render messages.toggleClickHandler messages.runAllButtonClickHandler
        , View.RedGreenDisplay.render runStatus
        , View.PassingTestsDisplay.render totalTests passedTests
        , View.TestHierarchy.render testRuns
        ]
