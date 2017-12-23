module State.Duration exposing (Duration, asMilliseconds, asSeconds, inMilliseconds)


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


asSeconds : Duration -> Float
asSeconds duration =
    case duration of
        Milliseconds ms ->
            toFloat ms / 1000

        Seconds s ->
            s
