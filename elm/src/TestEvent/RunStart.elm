module TestEvent.RunStart exposing (RawData)


type alias RawData =
    { testCount : String
    , fuzzRuns : String
    , paths : List String
    , initialSeed : String
    }


type alias ParsedData =
    { testCount : Int
    , fuzzRuns : Int
    , paths : List String
    , initialSeed : Int
    }



-- parse : RawData -> ParsedData
-- parse =
--     {}
