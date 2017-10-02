port module Main exposing (main)

import Html exposing (Html, div, h2, section, text)
import Html.Attributes exposing (class)
import TestEvent.RunComplete as RunComplete
import TestEvent.RunStart as RunStart
import TestEvent.TestCompleted as TestCompleted


type alias Model =
    {}


type Message
    = RunStart RunStart.RawData
    | TestCompleted TestCompleted.RawData
    | RunComplete RunComplete.RawData


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


port runStart : (RunStart.RawData -> message) -> Sub message


port testCompleted : (TestCompleted.RawData -> message) -> Sub message


port runComplete : (RunComplete.RawData -> message) -> Sub message
