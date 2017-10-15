module Decoding.ExpectEqual exposing (parsesCorrectly)

import Expect
import Maybe.Extra as Maybe
import State.Failure as Failure exposing (Failure)
import Test exposing (Test, describe, test)
import TestEvent.TestCompleted exposing (TestCompleted, parse, toTestInstance)
import TestInstance.Core as TestInstance exposing (TestInstance)


parsesCorrectly : Test
parsesCorrectly =
    let
        event : TestCompleted
        event =
            parse failingJsonString

        testInstance : TestInstance
        testInstance =
            toTestInstance event

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
        , test "has no given" <|
            \_ ->
                Expect.true "expected not to find a given" (Maybe.isNothing <| Failure.getGiven failure)
        , test "has a complex comparison" <|
            \_ ->
                Expect.true "expected to find a complex comparison object" (Failure.hasComplexComparison failure)
        , test "has expected expected text" <|
            \_ ->
                Expect.equal (Failure.getExpected failure) "4"
        , test "has expected actual text" <|
            \_ ->
                Expect.equal (Failure.getActual failure) "3"
        , test "should display with diff" <|
            \_ ->
                Expect.true "expected that diff should occur" (Failure.shouldDiff failure)
        ]


failingJsonString : String
failingJsonString =
    """{"event":"testCompleted","status":"fail","labels":["FailureOutputValidation","Expect.equal","basic case","failing"],"failures":[{"given":null,"message":"Expect.equal","reason":{"type":"custom","data":{"expected":"4","actual":"3","comparison":"Expect.equal"}}}],"duration":"3"}"""
