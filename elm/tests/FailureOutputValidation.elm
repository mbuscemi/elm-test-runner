module FailureOutputValidation
    exposing
        ( expectAll
        , expectAtLeast
        , expectAtMost
        , expectEqual
        , expectEqualDicts
        , expectEqualLists
        , expectEqualSets
        , expectErr
        , expectFalse
        , expectGreaterThan
        , expectLessThan
        , expectNotEqual
        , expectNotWithin
        , expectOnFail
        , expectPassAndExpectFail
        , expectTrue
        , expectWithin
        , fuzzTests
        , todo
        )

import Dict
import Expect exposing (FloatingPointTolerance(Absolute))
import Fuzz exposing (int)
import Json.Decode exposing (decodeString, int)
import Set
import Test exposing (Test, describe, fuzz, skip, test)


expectEqual : Test
expectEqual =
    describe "Expect.equal" <|
        [ skip <|
            describe "basic case" <|
                [ test "passing" <|
                    \_ ->
                        Expect.equal 3 (1 + 2)
                , test "failing" <|
                    \_ ->
                        Expect.equal 4 (1 + 2)
                ]
        , skip <|
            describe "string with additions" <|
                [ test "passing" <|
                    \_ ->
                        Expect.equal "abcdefghi" "abcdefghi"
                , test "failing" <|
                    \_ ->
                        Expect.equal "abcdefghi" "abbbcdeeefghhhi"
                ]
        , skip <|
            describe "string with removals" <|
                [ test "passing" <|
                    \_ ->
                        Expect.equal "abcdefghi" "abcdefghi"
                , test "failing" <|
                    \_ ->
                        Expect.equal "abcdefghi" "acdfgi"
                ]
        ]


expectNotEqual : Test
expectNotEqual =
    skip <|
        describe "Expect.notEqual" <|
            [ describe "basic case" <|
                [ test "passing" <|
                    \_ ->
                        Expect.notEqual (1 + 2) 4
                , test "failing" <|
                    \_ ->
                        Expect.notEqual (1 + 2) 3
                ]
            , describe "string" <|
                [ test "passing" <|
                    \_ ->
                        Expect.notEqual "abcdefghi" "abcdefgh"
                , test "failing" <|
                    \_ ->
                        Expect.notEqual "abcdefghi" "abcdefghi"
                ]
            ]


expectLessThan : Test
expectLessThan =
    skip <|
        describe "Expect.lessThan" <|
            [ describe "basic case" <|
                [ test "passing" <|
                    \_ ->
                        Expect.lessThan 2 1
                , test "failing on equal" <|
                    \_ ->
                        Expect.lessThan 2 2
                , test "failing on greater" <|
                    \_ ->
                        Expect.lessThan 2 3
                ]
            ]


expectAtMost : Test
expectAtMost =
    skip <|
        describe "Expect.atMost" <|
            [ describe "basic case" <|
                [ test "passing" <|
                    \_ ->
                        Expect.atMost 2 1
                , test "passing on equal" <|
                    \_ ->
                        Expect.atMost 2 2
                , test "failing on greater" <|
                    \_ ->
                        Expect.atMost 2 3
                ]
            ]


expectGreaterThan : Test
expectGreaterThan =
    skip <|
        describe "Expect.greaterThan" <|
            [ describe "basic case" <|
                [ test "passing" <|
                    \_ ->
                        Expect.greaterThan 2 3
                , test "failing on equal" <|
                    \_ ->
                        Expect.greaterThan 2 2
                , test "failing on less" <|
                    \_ ->
                        Expect.greaterThan 2 1
                ]
            ]


expectAtLeast : Test
expectAtLeast =
    skip <|
        describe "Expect.atLeast" <|
            [ describe "basic case" <|
                [ test "passing" <|
                    \_ ->
                        Expect.atLeast 2 3
                , test "passing on equal" <|
                    \_ ->
                        Expect.atLeast 2 2
                , test "failing on less" <|
                    \_ ->
                        Expect.atLeast 2 1
                ]
            ]


expectTrue : Test
expectTrue =
    skip <|
        describe "Expect.true" <|
            [ describe "basic case" <|
                [ test "passing" <|
                    \_ ->
                        Expect.true "this should pass" True
                , test "failing" <|
                    \_ ->
                        Expect.true "this should fail / true for false" False
                ]
            ]


expectFalse : Test
expectFalse =
    skip <|
        describe "Expect.false" <|
            [ describe "basic case" <|
                [ test "passing" <|
                    \_ ->
                        Expect.false "this should pass" False
                , test "failing" <|
                    \_ ->
                        Expect.false "this should fail / false for true" True
                ]
            ]


expectAll : Test
expectAll =
    skip <|
        describe "Expect.all" <|
            [ describe "three grouped checks" <|
                [ test "all pass" <|
                    \_ ->
                        Expect.all
                            [ Expect.greaterThan -3
                            , Expect.lessThan 3
                            , Expect.equal 0
                            ]
                            0
                , test "first fails" <|
                    \_ ->
                        Expect.all
                            [ Expect.greaterThan 0
                            , Expect.lessThan 3
                            , Expect.equal 0
                            ]
                            0
                , test "second fails" <|
                    \_ ->
                        Expect.all
                            [ Expect.greaterThan -3
                            , Expect.lessThan 0
                            , Expect.equal 0
                            ]
                            0
                , test "third fails" <|
                    \_ ->
                        Expect.all
                            [ Expect.greaterThan -3
                            , Expect.lessThan 3
                            , Expect.equal 1
                            ]
                            0
                , test "all fail" <|
                    \_ ->
                        Expect.all
                            [ Expect.greaterThan 3
                            , Expect.lessThan -3
                            , Expect.equal 1
                            ]
                            0
                ]
            ]


expectWithin : Test
expectWithin =
    skip <|
        describe "Expect.within" <|
            [ describe "pi" <|
                [ test "passing" <|
                    \_ ->
                        3.14 |> Expect.within (Absolute 0.01) pi
                , test "failing" <|
                    \_ ->
                        3.14 |> Expect.within (Absolute 0.001) pi
                ]
            ]


expectNotWithin : Test
expectNotWithin =
    skip <|
        describe "Expect.notWithin" <|
            [ describe "pi" <|
                [ test "passing" <|
                    \_ ->
                        3.14 |> Expect.notWithin (Absolute 0.001) pi
                , test "failing" <|
                    \_ ->
                        3.14 |> Expect.notWithin (Absolute 0.01) pi
                ]
            ]


expectErr : Test
expectErr =
    skip <|
        describe "Expect.err" <|
            [ describe "documentation example" <|
                [ test "passing" <|
                    \_ ->
                        String.toInt "not an int" |> Expect.err
                , test "failing" <|
                    \_ ->
                        String.toInt "20" |> Expect.err
                ]
            ]


expectEqualLists : Test
expectEqualLists =
    skip <|
        describe "Expect.equalLists" <|
            [ describe "documentation example" <|
                [ test "passing" <|
                    \_ ->
                        [ 1, 2, 3 ]
                            |> Expect.equalLists [ 1, 2, 3 ]
                , test "failing" <|
                    \_ ->
                        [ 1, 2, 4, 6 ]
                            |> Expect.equalLists [ 1, 2, 5 ]
                ]
            ]


expectEqualDicts : Test
expectEqualDicts =
    skip <|
        describe "Expect.equalDicts" <|
            [ describe "documentation example" <|
                [ test "passing" <|
                    \_ ->
                        Dict.fromList [ ( 1, "one" ), ( 2, "two" ) ]
                            |> Expect.equalDicts (Dict.fromList [ ( 1, "one" ), ( 2, "two" ) ])
                , test "failing" <|
                    \_ ->
                        Dict.fromList [ ( 1, "one" ), ( 2, "too" ) ]
                            |> Expect.equalDicts (Dict.fromList [ ( 1, "one" ), ( 2, "two" ), ( 3, "three" ) ])
                ]
            ]


expectEqualSets : Test
expectEqualSets =
    skip <|
        describe "Expect.equalSets" <|
            [ describe "documentation example" <|
                [ test "passing" <|
                    \_ ->
                        Set.fromList [ 1, 2 ]
                            |> Expect.equalSets (Set.fromList [ 1, 2 ])
                , test "failing" <|
                    \_ ->
                        Set.fromList [ 1, 2, 4, 6 ]
                            |> Expect.equalSets (Set.fromList [ 1, 2, 5 ])
                ]
            ]


expectPassAndExpectFail : Test
expectPassAndExpectFail =
    skip <|
        describe "Expect.pass and Expect.fail" <|
            [ describe "documentation example" <|
                [ test "passing" <|
                    \_ ->
                        case decodeString Json.Decode.int "42" of
                            Ok _ ->
                                Expect.pass

                            Err err ->
                                Expect.fail err
                , test "failing" <|
                    \_ ->
                        case decodeString Json.Decode.int "forty-two" of
                            Ok _ ->
                                Expect.pass

                            Err err ->
                                Expect.fail err
                ]
            ]


expectOnFail : Test
expectOnFail =
    skip <|
        describe "Expect.onFail" <|
            [ describe "documentation example" <|
                [ test "custom failure message" <|
                    \_ ->
                        "something"
                            |> Expect.equal "something else"
                            |> Expect.onFail "thought those two strings would be the same"
                ]
            ]


fuzzTests : Test
fuzzTests =
    skip <|
        describe "fuzz tests" <|
            [ describe "simple example / adding one" <|
                [ fuzz Fuzz.int "passing" <|
                    \num ->
                        (\x -> x + 1) num |> Expect.equal (num + 1)
                , fuzz Fuzz.float "failing" <|
                    \num ->
                        (\x -> x + 1.0000000001) num |> Expect.equal (num + 1)
                ]
            ]


todo : Test
todo =
    skip <|
        describe "Todo Functionality" <|
            [ Test.todo "stuff & things"
            ]
