module View.TestHierarchy.Core exposing (render)

import Html exposing (Attribute, Html, li, span, strong, text, ul)
import Html.Attributes exposing (class, style)
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree, NodeId, Tree(Node))
import View.TestHierarchy.ChildTree
import View.TestHierarchy.Root


type alias ToggleMessages message =
    { collapse : Int -> message
    , expand : Int -> message
    }


type alias HighlightMessages message =
    { mouseIn : Int -> message
    , mouseOut : message
    }


render : Maybe Int -> CollapsibleTree String TestInstance -> ToggleMessages message -> HighlightMessages message -> Html message
render nodeMouseIsOver testHierarchy toggleMessages highlightMessages =
    viewTree toggleMessages highlightMessages nodeMouseIsOver testHierarchy


viewTree : ToggleMessages message -> HighlightMessages message -> Maybe Int -> CollapsibleTree String TestInstance -> Html message
viewTree toggleMessages highlightMessages nodeMouseIsOver (Node ( nodeName, isExpanded, nodeId ) nodeData children) =
    ul
        [ class "test-list" ]
        (View.TestHierarchy.Root.render toggleMessages nodeData (List.isEmpty children) isExpanded nodeName nodeId
            :: viewChildren toggleMessages highlightMessages isExpanded nodeMouseIsOver children
        )


viewChildren : ToggleMessages message -> HighlightMessages message -> Bool -> Maybe Int -> List (CollapsibleTree String TestInstance) -> List (Html message)
viewChildren toggleMessages highlightMessages shouldShow nodeMouseIsOver children =
    if shouldShow then
        viewForest toggleMessages highlightMessages nodeMouseIsOver children
    else
        []


viewForest : ToggleMessages message -> HighlightMessages message -> Maybe Int -> List (CollapsibleTree String TestInstance) -> List (Html message)
viewForest toggleMessages highlightMessages nodeMouseIsOver children =
    List.map (childTree toggleMessages highlightMessages nodeMouseIsOver) children


childTree : ToggleMessages message -> HighlightMessages message -> Maybe Int -> CollapsibleTree String TestInstance -> Html message
childTree toggleMessages highlightMessages nodeMouseIsOver tree =
    View.TestHierarchy.ChildTree.render
        highlightMessages
        nodeMouseIsOver
        tree
        (viewTree toggleMessages highlightMessages nodeMouseIsOver tree)
