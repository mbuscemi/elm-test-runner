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


toPrimaryColor : RunStatus -> Color
toPrimaryColor runStatus =
    case runStatus of
        NoData ->
            rgb 16 19 24

        GeneratingTests ->
            rgb 70 27 75

        LastPassed ->
            rgb 32 64 32

        LastFailed ->
            rgb 98 12 12

        CompileError ->
            rgb 85 54 10

        Processing ->
            rgb 48 48 35

        Incomplete ->
            rgb 7 61 111


toSecondaryColor : RunStatus -> Color
toSecondaryColor runStatus =
    case runStatus of
        NoData ->
            rgb 16 19 24

        GeneratingTests ->
            rgb 97 17 106

        Processing ->
            rgb 64 64 34

        LastPassed ->
            rgb 30 86 30

        LastFailed ->
            rgb 163 15 15

        CompileError ->
            rgb 140 86 8

        Incomplete ->
            rgb 13 91 164
