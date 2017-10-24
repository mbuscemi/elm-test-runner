module Model.RandomSeed exposing (forJS, set, setForcing)


type alias HasRandomSeed r =
    { r
        | randomSeed : Maybe Int
        , forceRandomSeedEnabled : Bool
    }


set : Maybe Int -> HasRandomSeed model -> HasRandomSeed model
set randomSeed model =
    { model | randomSeed = randomSeed }


setForcing : Bool -> HasRandomSeed model -> HasRandomSeed model
setForcing setting model =
    { model | forceRandomSeedEnabled = setting }


forJS : HasRandomSeed model -> String
forJS model =
    case ( model.forceRandomSeedEnabled, model.randomSeed ) of
        ( True, Just seed ) ->
            toString seed

        _ ->
            ""
