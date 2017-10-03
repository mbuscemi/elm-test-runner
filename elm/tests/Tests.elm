module Tests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    describe "Elm Test Runner" <|
        [ describe "boilerplate" <|
            [ test "something dumb" <|
                \_ ->
                    Expect.equal (2 + 2) 4
            , test "something else" <|
                \_ ->
                    Expect.equal ("a" ++ "b") "ab"
            ]
        , describe "blarg and frangle" <|
            [ test "blarg" <|
                \_ ->
                    Expect.atMost 5 3
            , test "frangle" <|
                \_ ->
                    Expect.atLeast 3 5
            , test "blarg & frangle" <|
                \_ ->
                    Expect.true "your mom?" True
            ]
        ]
