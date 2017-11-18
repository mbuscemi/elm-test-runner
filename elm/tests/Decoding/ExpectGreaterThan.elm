module Decoding.ExpectGreaterThan exposing (parsesCorrectly)

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
                Expect.equal (Failure.getMessage failure) "Expect.greaterThan"
        , test "has no given" <|
            \_ ->
                Expect.true "expected not to find a given" (Maybe.isNothing <| Failure.getGiven failure)
        , test "has a complex comparison" <|
            \_ ->
                Expect.true "expected to find a complex comparison object" (Failure.hasComplexComparison failure)
        , test "has expected expected text" <|
            \_ ->
                Expect.equal (Failure.getExpected failure) "2"
        , test "has expected actual text" <|
            \_ ->
                Expect.equal (Failure.getActual failure) "1"
        , test "should display with diff" <|
            \_ ->
                Expect.false "expected that diff should not occur" (Failure.shouldDiff failure)
        , test "not a todo" <|
            \_ ->
                Expect.false "expected that this is not a todo test" (Failure.isTodo failure)
        ]


failingJsonString : String
failingJsonString =
    """{"event":"testCompleted","status":"fail","labels":["FailureOutputValidation","Expect.greaterThan","basic case","failing on less"],"failures":[{"given":null,"message":"Expect.greaterThan","reason":{"type":"custom","data":{"first":"2","second":"1","comparison":"Expect.greaterThan"}}}],"duration":"2"}"""
