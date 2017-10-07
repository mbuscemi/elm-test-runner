module View.TestHierarchy.Core exposing (render)

import Html exposing (Attribute, Html, li, span, strong, text, ul)
import Html.Attributes exposing (class, style)
import State.Failure exposing (Failure)
import TestInstance.Core as TestInstance exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree, NodeId, Tree(Node))
import View.TestHierarchy.ChildTree
import View.TestHierarchy.Root


type alias ToggleMessages message =
    { collapse : Int -> message
    , expand : Int -> message
    }


type alias HighlightAndSelectionMessages message =
    { mouseIn : Int -> message
    , mouseOut : message
    , testClick : Int -> Maybe Failure -> message
    }


type alias NodeData =
    { nodeMouseIsOver : Maybe Int
    , selectedNode : Maybe Int
    }


render : ToggleMessages message -> HighlightAndSelectionMessages message -> NodeData -> CollapsibleTree String TestInstance -> Html message
render toggleMessages highlightMessages nodeData testHierarchy =
    viewTree toggleMessages highlightMessages nodeData testHierarchy


viewTree : ToggleMessages message -> HighlightAndSelectionMessages message -> NodeData -> CollapsibleTree String TestInstance -> Html message
viewTree toggleMessages highlightMessages nodeData (Node ( nodeName, isExpanded, nodeId ) nodeInternals children) =
    ul
        [ class "test-list" ]
        (View.TestHierarchy.Root.render toggleMessages nodeInternals (List.isEmpty children) isExpanded nodeName nodeId
            :: viewChildren toggleMessages highlightMessages isExpanded nodeData children
        )


viewChildren : ToggleMessages message -> HighlightAndSelectionMessages message -> Bool -> NodeData -> List (CollapsibleTree String TestInstance) -> List (Html message)
viewChildren toggleMessages highlightMessages shouldShow nodeData children =
    if shouldShow then
        viewForest toggleMessages highlightMessages nodeData children
    else
        []


viewForest : ToggleMessages message -> HighlightAndSelectionMessages message -> NodeData -> List (CollapsibleTree String TestInstance) -> List (Html message)
viewForest toggleMessages highlightMessages nodeData children =
    List.map (childTree toggleMessages highlightMessages nodeData) children


childTree : ToggleMessages message -> HighlightAndSelectionMessages message -> NodeData -> CollapsibleTree String TestInstance -> Html message
childTree toggleMessages highlightMessages nodeData tree =
    View.TestHierarchy.ChildTree.render
        highlightMessages
        nodeData
        tree
        (viewTree toggleMessages highlightMessages nodeData tree)
