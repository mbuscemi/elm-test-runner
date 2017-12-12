module State.RunStatus
    exposing
        ( RunStatus
        , compileError
        , generatingTests
        , incomplete
        , lastFailed
        , lastPassed
        , noData
        , passFail
        , processing
        , toClass
        , toPrimaryColor
        , toSecondaryColor
        , toText
        )

import Color exposing (Color, rgb)


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


toPrimaryColor : RunStatus -> Color
toPrimaryColor runStatus =
    case runStatus of
        NoData ->
            rgb 16 19 24

        Processing ->
            rgb 48 48 35

        _ ->
            rgb 0 0 0


toSecondaryColor : RunStatus -> Color
toSecondaryColor runStatus =
    case runStatus of
        NoData ->
            rgb 16 19 24

        Processing ->
            rgb 64 64 34

        _ ->
            rgb 0 0 0
