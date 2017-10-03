module State.RunStatus exposing (RunStatus, compileError, noData, passFail, processing, toColor, toText)


type RunStatus
    = NoData
    | Processing
    | LastPassed
    | LastFailed
    | CompileError


noData : RunStatus
noData =
    NoData


processing : RunStatus
processing =
    Processing


compileError : RunStatus
compileError =
    CompileError


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
            "... Running ..."

        LastPassed ->
            "Passed"

        LastFailed ->
            "Failed"

        CompileError ->
            "Compile Error"


toColor : RunStatus -> String
toColor runStatus =
    case runStatus of
        NoData ->
            "grey"

        Processing ->
            "lightBlue"

        LastPassed ->
            "green"

        LastFailed ->
            "red"

        CompileError ->
            "orange"
