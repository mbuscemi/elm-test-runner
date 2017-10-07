module View.TestHierarchy.ChildTree exposing (render)

import Html exposing (Attribute, Html, li)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseEnter, onMouseLeave)
import TestInstance.Core exposing (TestInstance)
import Tree.Core exposing (CollapsibleTree, Tree(Node))


type alias Messages message =
    { mouseIn : Int -> message
    , mouseOut : message
    }


render : Messages message -> Maybe Int -> CollapsibleTree String TestInstance -> Html message -> Html message
render highlightMessages nodeMouseIsOver ((Node ( _, _, nodeId ) _ children) as tree) renderedChildren =
    li
        (List.append
            (mouseEvents highlightMessages nodeId children)
            (mouseOverHighlight nodeId nodeMouseIsOver)
        )
        [ renderedChildren ]


mouseEvents : Messages message -> Int -> List (CollapsibleTree String TestInstance) -> List (Attribute message)
mouseEvents messages nodeId children =
    if List.isEmpty children then
        [ onMouseEnter <| messages.mouseIn nodeId
        , onMouseLeave <| messages.mouseOut
        ]
    else
        []


mouseOverHighlight : Int -> Maybe Int -> List (Attribute message)
mouseOverHighlight nodeId nodeMouseIsOver =
    case nodeMouseIsOver of
        Just mouseNodeId ->
            if nodeId == mouseNodeId then
                [ style [ ( "background-color", "#2c333e" ) ] ]
                -- save this color for later [ style [ ( "background-color", "#343f51" ) ] ]
            else
                []

        Nothing ->
            []
