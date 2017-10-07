module Duration.Core exposing (Duration, asMilliseconds, inMilliseconds)


type Duration
    = Seconds Float
    | Milliseconds Int


inMilliseconds : Int -> Duration
inMilliseconds milliseconds =
    Milliseconds milliseconds


asMilliseconds : Duration -> Int
asMilliseconds duration =
    case duration of
        Milliseconds ms ->
            ms

        Seconds s ->
            round <| s * 1000
