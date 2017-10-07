module View.AutoRunOnSave exposing (render)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


render : Bool -> Html message
render enabled =
    div [ class <| "auto-run-display " ++ enabledString enabled ]
        [ text <| "AUTO RUN " ++ (String.toUpper <| enabledString enabled)
        ]


enabledString : Bool -> String
enabledString enabled =
    if enabled then
        "enabled"
    else
        "disabled"
