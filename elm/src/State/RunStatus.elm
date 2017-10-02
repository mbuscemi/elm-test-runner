module State.RunStatus exposing (RunStatus, noData, passFail, processing, toColor, toText)


type RunStatus
    = NoData
    | Processing
    | LastPassed
    | LastFailed


noData : RunStatus
noData =
    NoData


processing : RunStatus
processing =
    Processing


passFail : Bool -> RunStatus
passFail didPass =
    if didPass then
        LastPassed
    else
        LastFailed


toText : RunStatus -> String
toText runStatus =
    case runStatus of
        NoData ->
            "No Data"

        Processing ->
            "... Processing ..."

        LastPassed ->
            "Passed!"

        LastFailed ->
            "Failed"


toColor : RunStatus -> String
toColor runStatus =
    case runStatus of
        NoData ->
            "grey"

        Processing ->
            "yellow"

        LastPassed ->
            "green"

        LastFailed ->
            "red"
