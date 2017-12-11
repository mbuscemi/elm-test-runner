module State.RunStatus
    exposing
        ( RunStatus(Processing)
        , compileError
        , generatingTests
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
    | GeneratingTests
    | Processing
    | LastPassed
    | LastFailed
    | CompileError
    | Incomplete


noData : RunStatus
noData =
    NoData


processing : RunStatus
processing =
    Processing


generatingTests : RunStatus
generatingTests =
    GeneratingTests


lastPassed : RunStatus
lastPassed =
    LastPassed


lastFailed : RunStatus
lastFailed =
    LastFailed


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

        GeneratingTests ->
            "... Generating Tests ... "

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

        GeneratingTests ->
            "generating-tests"

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
