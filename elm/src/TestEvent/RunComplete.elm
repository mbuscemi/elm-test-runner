module TestEvent.RunComplete exposing (RawData)


type alias RawData =
    { passed : String
    , failed : String
    , duration : String
    }
