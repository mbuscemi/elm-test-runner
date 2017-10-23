module View.TestHierarchy.ChildTree exposing (render)

import Html exposing (Attribute, Html, li)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Tree.Core exposing (CollapsibleTree, Tree(Node))


type alias Messages message testInstance =
    { mouseIn : Int -> message
    , mouseOut : message
    , testClick : Int -> Maybe testInstance -> message
    }


type alias NodeData =
    { nodeMouseIsOver : Maybe Int
    , selectedNode : Maybe Int
    }


render : Messages message testInstance -> NodeData -> CollapsibleTree String testInstance -> Html message -> Html message
render highlightMessages nodeData (Node ( _, _, nodeId ) testInstance children) renderedChildren =
    li
        (List.append
            (mouseEvents highlightMessages nodeId testInstance children)
            (mouseOverHighlight nodeId nodeData)
        )
        [ renderedChildren ]


mouseEvents : Messages message testInstance -> Int -> testInstance -> List (CollapsibleTree String testInstance) -> List (Attribute message)
mouseEvents messages nodeId testInstance children =
    if List.isEmpty children then
        [ onMouseEnter <| messages.mouseIn nodeId
        , onMouseLeave <| messages.mouseOut
        , onClick <| messages.testClick nodeId (Just testInstance)
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
