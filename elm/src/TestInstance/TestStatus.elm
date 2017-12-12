module TestInstance.TestStatus
    exposing
        ( TestStatus
        , default
        , fromString
        , fromTestCompletedEvent
        , isFail
        , isPending
        , isTodo
        , toClass
        , toIcon
        )

import TestEvent.TestCompleted as TestCompleted exposing (TestCompleted)


type TestStatus
    = Pass
    | Fail
    | Pending
    | Todo


default : TestStatus
default =
    Pending


isFail : TestStatus -> Bool
isFail testStatus =
    testStatus == Fail


isPending : TestStatus -> Bool
isPending testStatus =
    testStatus == Pending


isTodo : TestStatus -> Bool
isTodo testStatus =
    testStatus == Todo


toIcon : TestStatus -> String
toIcon testStatus =
    case testStatus of
        Pass ->
            "✓"

        Fail ->
            "✗"

        Pending ->
            "○"

        Todo ->
            "»"


toClass : TestStatus -> String
toClass testStatus =
    case testStatus of
        Pass ->
            "passed"

        Fail ->
            "failed"

        Pending ->
            "pending"

        Todo ->
            "todo"


fromString : String -> TestStatus
fromString newStatus =
    case newStatus of
        "pass" ->
            Pass

        "fail" ->
            Fail

        "pending" ->
            Pending

        "todo" ->
            Todo

        _ ->
            default


fromTestCompletedEvent : TestCompleted -> TestStatus
fromTestCompletedEvent event =
    if TestCompleted.passed event then
        Pass
    else if TestCompleted.isTodo event then
        Todo
    else
        Fail
