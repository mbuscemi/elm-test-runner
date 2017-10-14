module Tests exposing (suite)

import Test exposing (Test, describe, fuzz, test)


suite : Test
suite =
    describe "Elm Test Runner" <|
        [ describe "Failure Output Validation" <|
            []
        , describe "Todo Functionality" <|
            [ Test.todo "stuff & things"
            ]
        ]
