module View.SeedAndSettings exposing (render)

import Html exposing (Attribute, Html, div, input, span, text)
import Html.Attributes exposing (checked, class, disabled, placeholder, type_, value)
import Html.Events exposing (onCheck, onClick)


type alias Messages message =
    { setForceSeedHandler : Bool -> message
    , setAutoRun : Bool -> message
    , setAutoNavigate : Bool -> message
    , setRunElmVerifyExamples : Bool -> message
    , settingsToggle : message
    }


type alias Data =
    { autoRunEnabled : Bool
    , autoNavigateEnabled : Bool
    , elmVerifyExamplesEnabled : Bool
    , forceRandomSeedEnabled : Bool
    , randomSeed : Maybe Int
    }


render : Messages message -> Data -> List (Html message)
render messages data =
    [ div [ class "seed-settings" ]
        [ input
            [ type_ "checkbox"
            , onCheck messages.setForceSeedHandler
            , checked data.forceRandomSeedEnabled
            ]
            []
        , span [] [ text "Seed:" ]
        , input
            [ type_ "number"
            , placeholder "Generate Random"
            , seedInputValue data.randomSeed
            , disabled <| not data.forceRandomSeedEnabled
            ]
            []
        ]
    , div
        [ class "settings-toggle btn btn-xs icon icon-gear"
        , onClick messages.settingsToggle
        ]
        []
    , div
        [ class "expanded-settings" ]
        [ div
            [ class "setting auto-run" ]
            [ text "Auto-Run on Save "
            , input
                [ type_ "checkbox"
                , onCheck messages.setAutoRun
                , checked data.autoRunEnabled
                ]
                []
            ]
        , div
            [ class "setting auto-navigate" ]
            [ text "Auto-Navigate to Test File "
            , input
                [ type_ "checkbox"
                , onCheck messages.setAutoNavigate
                , checked data.autoNavigateEnabled
                ]
                []
            ]
        , div
            [ class "setting auto-navigate" ]
            [ text "Enable elm-verify-examples "
            , input
                [ type_ "checkbox"
                , onCheck messages.setRunElmVerifyExamples
                , checked data.elmVerifyExamplesEnabled
                ]
                []
            ]
        ]
    ]


seedInputValue : Maybe Int -> Attribute message
seedInputValue randomSeed =
    case randomSeed of
        Just seed ->
            value <| toString seed

        Nothing ->
            value ""
