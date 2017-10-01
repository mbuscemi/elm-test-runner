module Main exposing (main)

import Html exposing (Html, div, h2, section, text)
import Html.Attributes exposing (class)


type alias Model =
    {}


type Message
    = None


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


init : ( Model, Cmd Message )
init =
    {} ! []


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    model ! []


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
