module Tests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    describe "Placeholder" <|
        [ test "something dumb" <|
            \_ ->
                Expect.equal (2 + 2) 4
        , test "something else" <|
            \_ ->
                Expect.equal ("a" ++ "b") "ab"
        ]
