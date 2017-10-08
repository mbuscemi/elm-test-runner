module View.SeedAndAutoRun exposing (render)

import Html exposing (Html, div, input, span, text)
import Html.Attributes exposing (class, disabled, placeholder, type_)


render : Bool -> List (Html message)
render enabled =
    [ div [ class "seed-settings" ]
        [ input [ type_ "checkbox" ] []
        , span [] [ text "Seed:" ]
        , input [ type_ "number", placeholder "Generate Random", disabled True ] []
        ]
    , div [ class <| "auto-run-display " ++ enabledString enabled ]
        [ text <| "AUTO RUN " ++ (String.toUpper <| enabledString enabled)
        ]
    ]


enabledString : Bool -> String
enabledString enabled =
    if enabled then
        "enabled"
    else
        "disabled"
