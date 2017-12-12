module View.TestHierarchy exposing (render)

import Html exposing (Html, ul)
import Html.Attributes exposing (class)
import Tree.Core exposing (CollapsibleTree, Tree(Node))
import View.TestHierarchy.ChildTree
import View.TestHierarchy.Root


type alias TestInstanceView testInstance message =
    { statusIndicator : testInstance -> Html message
    , conditionallyEmbolden : Bool -> String -> testInstance -> Html message
    }


type alias NodeData =
    { nodeMouseIsOver : Maybe Int
    , selectedNode : Maybe Int
    }


type alias ToggleMessages message =
    { collapse : Int -> message
    , expand : Int -> message
    }


type alias SelectionMessages testInstance message =
    { mouseIn : Int -> message
    , mouseOut : message
    , testClick : Int -> Maybe testInstance -> message
    }


type alias TestTree testInstance =
    CollapsibleTree String testInstance


render :
    TestInstanceView testInstance message
    -> NodeData
    -> ToggleMessages message
    -> SelectionMessages testInstance message
    -> TestTree testInstance
    -> Html message
render testInstanceView nodeData toggleMessages selectionMessages (Node ( nodeName, isExpanded, nodeId ) nodeInternals children) =
    ul
        [ class "test-list" ]
        (View.TestHierarchy.Root.render (List.isEmpty children) isExpanded nodeName nodeId testInstanceView nodeInternals toggleMessages
            :: viewChildren testInstanceView toggleMessages selectionMessages isExpanded nodeData children
        )


viewChildren :
    TestInstanceView testInstance message
    -> ToggleMessages message
    -> SelectionMessages testInstance message
    -> Bool
    -> NodeData
    -> List (TestTree testInstance)
    -> List (Html message)
viewChildren testInstanceView toggleMessages selectionMessages shouldShow nodeData children =
    if shouldShow then
        viewForest testInstanceView toggleMessages selectionMessages nodeData children
    else
        []


viewForest :
    TestInstanceView testInstance message
    -> ToggleMessages message
    -> SelectionMessages testInstance message
    -> NodeData
    -> List (TestTree testInstance)
    -> List (Html message)
viewForest testInstanceView toggleMessages selectionMessages nodeData children =
    List.map (childTree testInstanceView toggleMessages selectionMessages nodeData) children


childTree :
    TestInstanceView testInstance message
    -> ToggleMessages message
    -> SelectionMessages testInstance message
    -> NodeData
    -> TestTree testInstance
    -> Html message
childTree testInstanceView toggleMessages selectionMessages nodeData tree =
    View.TestHierarchy.ChildTree.render
        nodeData
        selectionMessages
        tree
        (render testInstanceView nodeData toggleMessages selectionMessages tree)
