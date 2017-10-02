port module Main exposing (main)

import Html exposing (Html, div, h2, section, text)
import Html.Attributes exposing (class)


type alias Model =
    {}


type Message
    = RunStart RunStartRawData
    | TestCompleted TestCompletedRawData
    | RunComplete RunCompleteRawData


type alias RunStartRawData =
    { testCount : String
    , fuzzRuns : String
    , paths : List String
    , initialSeed : String
    }


type alias TestCompletedRawData =
    { status : String
    , labels : List String
    , failures : List String
    , duration : String
    }


type alias RunCompleteRawData =
    { passed : String
    , failed : String
    , duration : String
    }


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Message )
init =
    {} ! []


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        RunStart data ->
            model ! []

        TestCompleted data ->
            model ! []

        RunComplete data ->
            model ! []


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none


view : Model -> Html Message
view model =
    div [ class "etr-main-view" ]
        [ h2 [] [ text "Elm Test Runner" ]
        , section [ class "input-block" ]
            [ div [ class "button-toolbar" ]
                [ div [ class "button-group" ]
                    [ div [ class "btn icon icon-sync" ] [ text "Run All" ]
                    ]
                ]
            ]
        ]


port runStart : (RunStartRawData -> message) -> Sub message


port testCompleted : (TestCompletedRawData -> message) -> Sub message


port runComplete : (RunCompleteRawData -> message) -> Sub message
