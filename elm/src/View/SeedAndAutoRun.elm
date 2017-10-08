module View.SeedAndAutoRun exposing (render)

import Html exposing (Attribute, Html, div, input, span, text)
import Html.Attributes exposing (class, disabled, placeholder, type_, value)


render : Bool -> Maybe Int -> List (Html message)
render autoRunEnabled randomSeed =
    [ div [ class "seed-settings" ]
        [ input [ type_ "checkbox" ] []
        , span [] [ text "Seed:" ]
        , input
            [ type_ "number"
            , placeholder "Generate Random"
            , disabled True
            , seedInputValue randomSeed
            ]
            []
        ]
    , div [ class <| "auto-run-display " ++ enabledString autoRunEnabled ]
        [ text <| "AUTO RUN " ++ (String.toUpper <| enabledString autoRunEnabled)
        ]
    ]


seedInputValue : Maybe Int -> Attribute message
seedInputValue randomSeed =
    case randomSeed of
        Just seed ->
            value <| toString seed

        Nothing ->
            value ""


enabledString : Bool -> String
enabledString enabled =
    if enabled then
        "enabled"
    else
        "disabled"
