module View.Main exposing (render)

import Html exposing (Html, div, h2, section, span, text)
import Html.Attributes exposing (class)
import State.RunStatus as RunStatus exposing (RunStatus)
import View.PassingTestsDisplay
import View.RedGreenDisplay
import View.Toolbar


type alias Messages message =
    { runAllButtonClickHandler : message }


render : RunStatus -> Int -> Int -> Messages message -> Html message
render runStatus totalTests passedTests messages =
    div [ class "etr-main-view" ]
        [ h2 [] [ text "Elm Test Runner" ]
        , View.Toolbar.render messages.runAllButtonClickHandler
        , View.RedGreenDisplay.render runStatus
        , View.PassingTestsDisplay.render totalTests passedTests
        ]
