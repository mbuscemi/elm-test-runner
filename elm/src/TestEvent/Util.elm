module TestEvent.Util exposing (parseInt)


parseInt : String -> Int
parseInt string =
    Result.withDefault 0 (String.toInt string)
