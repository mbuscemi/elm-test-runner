module TestEvent.TestStatus exposing (TestStatus, default, isFail, isPass, isTodo, testStatus)

import Json.Decode exposing (Decoder, map, string)


type TestStatus
    = Pass
    | Fail
    | Todo


testStatus : Decoder TestStatus
testStatus =
    map fromString string


fromString : String -> TestStatus
fromString string =
    case string of
        "pass" ->
            Pass

        "todo" ->
            Todo

        _ ->
            Fail


default : TestStatus
default =
    Fail


isPass : TestStatus -> Bool
isPass testStatus =
    case testStatus of
        Pass ->
            True

        _ ->
            False


isFail : TestStatus -> Bool
isFail testStatus =
    case testStatus of
        Fail ->
            True

        _ ->
            False


isTodo : TestStatus -> Bool
isTodo testStatus =
    case testStatus of
        Todo ->
            True

        _ ->
            False
