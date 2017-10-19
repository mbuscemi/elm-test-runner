module View.SeedAndSettings exposing (render)

import Html exposing (Attribute, Html, div, input, span, text)
import Html.Attributes exposing (checked, class, disabled, placeholder, style, type_, value)
import Html.Events exposing (onCheck)


render : (Bool -> message) -> Bool -> Bool -> Bool -> Maybe Int -> List (Html message)
render setForceSeedHandler autoRunEnabled autoNavigateEnabled forceRandomSeedEnabled randomSeed =
    [ div [ class "seed-settings" ]
        [ input
            (List.append
                [ type_ "checkbox"
                , onCheck setForceSeedHandler
                ]
                (seedCheckboxStyles forceRandomSeedEnabled)
            )
            []
        , span [] [ text "Seed:" ]
        , input
            (List.append
                [ type_ "number"
                , placeholder "Generate Random"
                , seedInputValue randomSeed
                ]
                (seedTextInputStyles forceRandomSeedEnabled)
            )
            []
        ]
    , div [ class <| "auto-run-display " ++ enabledString autoRunEnabled ] [ text "AUTO-RUN" ]
    , div [ class "divider" ] [ text " | " ]
    , div [ class <| "auto-navigate-display " ++ enabledString autoNavigateEnabled ] [ text "AUTO-NAVIGATE" ]
    ]


seedCheckboxStyles : Bool -> List (Attribute message)
seedCheckboxStyles forceRandomSeedEnabled =
    [ checked forceRandomSeedEnabled ]


seedTextInputStyles : Bool -> List (Attribute message)
seedTextInputStyles forceRandomSeedEnabled =
    [ disabled <| not forceRandomSeedEnabled ]


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
