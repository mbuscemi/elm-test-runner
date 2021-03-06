module View.Toolbar exposing (render)

import Animation exposing (State)
import Html exposing (Attribute, Html, div, span, strong, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import State.RunStatus as RunStatus exposing (RunStatus)


type alias Data =
    { totalTests : Int
    , passedTests : Int
    , runStatus : RunStatus
    , statusBarTextStyle : State
    , statusBarColorStyle : State
    }


render : Data -> message -> Html message
render data runAllButtonClickHandler =
    div [ class "toolbar" ]
        [ div
            (class "status-bar" :: Animation.render data.statusBarColorStyle)
            [ strong
                (class "title" :: Animation.render data.statusBarTextStyle)
                [ text <| RunStatus.toText data.runStatus ]
            , span
                (class "passing-tests" :: Animation.render data.statusBarTextStyle)
                [ span [ class "number-field passing" ] [ text <| toString data.passedTests ]
                , span [] [ text " / " ]
                , span [ class "number-field total" ] [ text <| toString data.totalTests ]
                ]
            ]
        , div [ class "run-all-button" ]
            [ div
                [ class <| buttonClass data.runStatus
                , onClick runAllButtonClickHandler
                ]
                [ text "Run All" ]
            ]
        ]


buttonClass : RunStatus -> String
buttonClass runStatus =
    if RunStatus.canStartNewTestRun runStatus then
        "btn icon icon-sync"
    else
        "btn icon icon-sync disabled"
