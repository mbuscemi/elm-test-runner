module View.ProjectSelector exposing (render)

import Html exposing (Html, div, option, select, span, text)
import Html.Attributes exposing (class, value)
import String.Extra as String


type alias Data =
    { projectDirectories : List String
    , testableElmDirectories : List String
    }


render : Data -> Html message
render data =
    div [ class "project-selector" ]
        [ div [ class "label" ] [ text "Project: " ]
        , div [ class "selector" ] [ select [] (options data.projectDirectories data.testableElmDirectories) ]
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
