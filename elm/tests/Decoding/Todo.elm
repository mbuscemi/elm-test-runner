module Decoding.Todo exposing (parsesCorrectly)

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
                Expect.true "expected todo test" (TestInstance.isTodo testInstance)
        , test "has a failure" <|
            \_ ->
                Expect.true "expected a failure in the failures list" (Maybe.isJust maybeFailure)
        , test "has correct message" <|
            \_ ->
                Expect.equal (Failure.getMessage failure) "stuff & things"
        , test "has no given" <|
            \_ ->
                Expect.true "expected not to find a given" (Maybe.isNothing <| Failure.getGiven failure)
        , test "has a complex comparison" <|
            \_ ->
                Expect.false "expected not to find a complex comparison object" (Failure.hasComplexComparison failure)
        , test "has no expected text" <|
            \_ ->
                Expect.equal (Failure.getExpected failure) ""
        , test "has no actual text" <|
            \_ ->
                Expect.equal (Failure.getActual failure) ""
        , test "should not display with diff" <|
            \_ ->
                Expect.false "expected that diff should not occur" (Failure.shouldDiff failure)
        , test "not a todo" <|
            \_ ->
                Expect.true "expected that this is a todo" (Failure.isTodo failure)
        ]


failingJsonString : String
failingJsonString =
    """{"event":"testCompleted","status":"todo","labels":["FailureOutputValidation","Todo Functionality"],"failures":["stuff & things"],"duration":"0"}"""
