module State.RunStatus exposing (RunStatus, compileError, noData, passFail, processing, toClass, toText)


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


toClass : RunStatus -> String
toClass runStatus =
    case runStatus of
        NoData ->
            "no-data"

        Processing ->
            "processing"

        LastPassed ->
            "last-passed"

        LastFailed ->
            "last-failed"

        CompileError ->
            "compile-error"
