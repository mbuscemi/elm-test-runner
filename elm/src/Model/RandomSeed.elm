module Model.RandomSeed exposing (forJS, set, setForcing)


type alias Model model =
    { model
        | randomSeed : Maybe Int
        , forceRandomSeedEnabled : Bool
    }


set : Maybe Int -> Model model -> Model model
set randomSeed model =
    { model | randomSeed = randomSeed }


setForcing : Bool -> Model model -> Model model
setForcing setting model =
    { model | forceRandomSeedEnabled = setting }


forJS : Model model -> String
forJS model =
    case ( model.forceRandomSeedEnabled, model.randomSeed ) of
        ( True, Just seed ) ->
            toString seed

        _ ->
            ""
