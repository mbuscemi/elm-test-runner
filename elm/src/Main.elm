module Main exposing (main)

import Html exposing (Html, div)


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
    div [] []
