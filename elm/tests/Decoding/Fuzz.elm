module Decoding.Fuzz exposing (parsesCorrectly)

import Expect
import Maybe.Extra as Maybe
import State.Failure as Failure exposing (Failure)
import Test exposing (Test, describe, test)
import TestEvent.TestCompleted exposing (TestCompleted, parseString)
import TestInstance.Core as TestInstance exposing (TestInstance, fromEvent)


parsesCorrectly : Test
parsesCorrectly =
    let
        event : TestCompleted
        event =
            parseString failingJsonString

        testInstance : TestInstance
        testInstance =
            fromEvent event

        maybeFailure : Maybe Failure
        maybeFailure =
            TestInstance.getFailure testInstance

        failure : Failure
        failure =
            Maybe.withDefault Failure.nullInstance maybeFailure
    in
    describe "parsesCorrectly" <|
        [ test "has correct status" <|
            \_ ->
                Expect.true "expected failing test" (TestInstance.isFailing testInstance)
        , test "has a failure" <|
            \_ ->
                Expect.true "expected a failure in the failures list" (Maybe.isJust maybeFailure)
        , test "has correct message" <|
            \_ ->
                Expect.equal (Failure.getMessage failure) "Expect.equal"
        , test "has a given" <|
            \_ ->
                Expect.true "expected to find a given" (Maybe.isJust <| Failure.getGiven failure)
        , test "given is expected value" <|
            \_ ->
                Expect.equal (Failure.getGiven failure) (Just "0.000001")
        , test "has a complex comparison" <|
            \_ ->
                Expect.true "expected to find a complex comparison object" (Failure.hasComplexComparison failure)
        , test "has expected expected text" <|
            \_ ->
                Expect.equal (Failure.getExpected failure) "1.000001"
        , test "has expected actual text" <|
            \_ ->
                Expect.equal (Failure.getActual failure) "1.0000010001"
        , test "should display with diff" <|
            \_ ->
                Expect.true "expected that diff should occur" (Failure.shouldDiff failure)
        , test "not a todo" <|
            \_ ->
                Expect.false "expected that this is not a todo test" (Failure.isTodo failure)
        ]


failingJsonString : String
failingJsonString =
    """{"event":"testCompleted","status":"fail","labels":["FailureOutputValidation","fuzz tests","simple example / adding one","failing"],"failures":[{"given":"0.000001","message":"Expect.equal","reason":{"type":"custom","data":{"expected":"1.000001","actual":"1.0000010001","comparison":"Expect.equal"}}}],"duration":"11"}"""
