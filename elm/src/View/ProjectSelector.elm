module View.ProjectSelector exposing (render)

import Html exposing (Html, div, option, select, span, text)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onInput)
import String.Extra as String


type alias Data =
    { projectDirectories : List String
    , testableElmDirectories : List String
    }


type alias Messages message =
    { workingDirectoryChanged : String -> message
    }


render : Data -> Messages message -> Html message
render data messages =
    div [ class "project-selector" ]
        [ div [ class "label" ] [ text "Project: " ]
        , div
            [ class "selector"
            , onInput messages.workingDirectoryChanged
            ]
            [ select [ class "form-control" ] (options data.projectDirectories data.testableElmDirectories) ]
        ]


options : List String -> List String -> List (Html message)
options projectDirectories testableElmDirectories =
    List.map
        (\dir ->
            option [ value dir ] [ text <| shortenDir projectDirectories dir ]
        )
        testableElmDirectories


shortenDir : List String -> String -> String
shortenDir projectDirectories fullDir =
    List.foldl
        (\projectDir dir ->
            let
                projectDirLength =
                    String.length projectDir
            in
            if String.left projectDirLength dir == projectDir then
                projectDirBase projectDir ++ String.dropLeft projectDirLength dir
            else
                dir
        )
        fullDir
        projectDirectories


projectDirBase : String -> String
projectDirBase string =
    String.rightOfBack "/" string
