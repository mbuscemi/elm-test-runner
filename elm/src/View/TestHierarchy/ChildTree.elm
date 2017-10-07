module View.TestHierarchy.ChildTree exposing (render)

import Html exposing (Attribute, Html, li)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import TestInstance.Core exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree, Tree(Node))


type alias Messages message =
    { mouseIn : Int -> message
    , mouseOut : message
    , testClick : Int -> message
    }


type alias NodeData =
    { nodeMouseIsOver : Maybe Int
    , selectedNode : Maybe Int
    }


render : Messages message -> NodeData -> CollapsibleTree String TestInstance -> Html message -> Html message
render highlightMessages nodeData ((Node ( _, _, nodeId ) _ children) as tree) renderedChildren =
    li
        (List.append
            (mouseEvents highlightMessages nodeId children)
            (mouseOverHighlight nodeId nodeData)
        )
        [ renderedChildren ]


mouseEvents : Messages message -> Int -> List (CollapsibleTree String TestInstance) -> List (Attribute message)
mouseEvents messages nodeId children =
    if List.isEmpty children then
        [ onMouseEnter <| messages.mouseIn nodeId
        , onMouseLeave <| messages.mouseOut
        , onClick <| messages.testClick nodeId
        ]
    else
        []


mouseOverHighlight : Int -> NodeData -> List (Attribute message)
mouseOverHighlight nodeId nodeData =
    case ( nodeData.nodeMouseIsOver, nodeData.selectedNode ) of
        ( Just mouseOverId, Just selectedId ) ->
            if nodeId == selectedId then
                selectedNodeBackgroundColorStyle
            else if nodeId == mouseOverId then
                mouseOverNodeBackgroundColorStyle
            else
                []

        ( Nothing, Just selectedId ) ->
            if nodeId == selectedId then
                selectedNodeBackgroundColorStyle
            else
                []

        ( Just mouseOverId, Nothing ) ->
            if nodeId == mouseOverId then
                mouseOverNodeBackgroundColorStyle
            else
                []

        ( Nothing, Nothing ) ->
            []


mouseOverNodeBackgroundColorStyle : List (Attribute message)
mouseOverNodeBackgroundColorStyle =
    testNodeBackgroundColorStyle mouseOverHexColor


selectedNodeBackgroundColorStyle : List (Attribute message)
selectedNodeBackgroundColorStyle =
    testNodeBackgroundColorStyle selectedHexColor


testNodeBackgroundColorStyle : String -> List (Attribute message)
testNodeBackgroundColorStyle hexColor =
    [ style [ ( "background-color", "#" ++ hexColor ) ] ]


selectedHexColor : String
selectedHexColor =
    "343f51"


mouseOverHexColor : String
mouseOverHexColor =
    "2c333e"
