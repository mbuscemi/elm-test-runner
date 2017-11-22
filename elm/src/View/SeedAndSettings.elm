module View.SeedAndSettings exposing (render)

import Html exposing (Attribute, Html, div, input, span, text)
import Html.Attributes exposing (checked, class, disabled, placeholder, type_, value)
import Html.Events exposing (onCheck, onClick)


type alias Messages message =
    { setForceSeedHandler : Bool -> message
    , settingsToggle : message
    }


type alias Data =
    { autoRunEnabled : Bool
    , autoNavigateEnabled : Bool
    , forceRandomSeedEnabled : Bool
    , randomSeed : Maybe Int
    }


render : Messages message -> Data -> List (Html message)
render messages data =
    [ div [ class "seed-settings" ]
        [ input
            (List.append
                [ type_ "checkbox"
                , onCheck messages.setForceSeedHandler
                ]
                (seedCheckboxStyles data.forceRandomSeedEnabled)
            )
            []
        , span [] [ text "Seed:" ]
        , input
            (List.append
                [ type_ "number"
                , placeholder "Generate Random"
                , seedInputValue data.randomSeed
                ]
                (seedTextInputStyles data.forceRandomSeedEnabled)
            )
            []
        ]
    , div
        [ class "settings-toggle btn btn-xs icon icon-gear"
        , onClick messages.settingsToggle
        ]
        []
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
