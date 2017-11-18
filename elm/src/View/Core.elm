module View.Core exposing (render)

import Animation exposing (State)
import Duration.Core exposing (Duration)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import State.PaneLocation as PaneLocation exposing (PaneLocation)
import State.RunStatus exposing (RunStatus)
import Tree.Core exposing (CollapsibleTree)
import View.DurationAndSeedDisplay
import View.OutputDisplay
import View.SeedAndSettings
import View.TestHierarchy.Core
import View.Toolbar


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
    }


type alias DisplayData message testInstance =
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
    , randomSeed : Maybe Int
    , forceRandomSeedEnabled : Bool
    , statusBarTextStyle : State
    , paneLocation : PaneLocation
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


render : DisplayData message testInstance -> Messages message testInstance -> Html message
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
            [ div [ class "output-display" ]
                [ View.OutputDisplay.render data.compilerError data.failure ]
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
