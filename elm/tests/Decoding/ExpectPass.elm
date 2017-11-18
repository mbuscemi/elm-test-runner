module Decoding.ExpectPass exposing (parsesCorrectly)

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
                Expect.false "expected no failing tests" (TestInstance.isFailing testInstance)
        , test "has a failure" <|
            \_ ->
                Expect.true "expected no failures in the failures list" (Maybe.isNothing maybeFailure)
        ]


failingJsonString : String
failingJsonString =
    """{"event":"testCompleted","status":"pass","labels":["FailureOutputValidation","Expect.pass and Expect.fail","documentation example","passing"],"failures":[],"duration":"0"}"""
