module TestEvent.TestCompleted exposing (RawData)


type alias RawData =
    { status : String
    , labels : List String
    , failures : List String
    , duration : String
    }
