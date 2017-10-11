module State.RunStatus
    exposing
        ( RunStatus
        , compileError
        , incomplete
        , lastFailed
        , lastPassed
        , noData
        , passFail
        , processing
        , toClass
        , toText
        )


type RunStatus
    = NoData
    | Processing
    | LastPassed
    | LastFailed
    | CompileError
    | Incomplete


lastPassed : RunStatus
lastPassed =
    LastPassed


lastFailed : RunStatus
lastFailed =
    LastFailed


noData : RunStatus
noData =
    NoData


processing : RunStatus
processing =
    Processing


compileError : RunStatus
compileError =
    CompileError


incomplete : RunStatus
incomplete =
    Incomplete


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

        Incomplete ->
            "Incomplete"


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

        Incomplete ->
            "incomplete"
