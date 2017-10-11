module Tests exposing (suite)

import Dict
import Expect exposing (FloatingPointTolerance(Absolute))
import Json.Decode exposing (decodeString, int)
import Set
import Test exposing (Test, describe, test)
import Tree.Core exposing (Tree(Node))
import Tree.Merge exposing (fromPath)


suite : Test
suite =
    describe "Elm Test Runner" <|
        [ describe "Tree.Merge" <|
            [ test "empty list yields single node" <|
                \_ ->
                    let
                        emptyTree =
                            Node "" {} []
                    in
                    Expect.equal (fromPath [] {} nonTransformer emptyTree) emptyTree
            , test "single element in list yields single child node" <|
                \_ ->
                    let
                        emptyTree =
                            Node "" {} []

                        treeWithChild =
                            Node "child" {} []
                    in
                    Expect.equal (fromPath [ "child" ] {} nonTransformer emptyTree) (Node "" {} [ Node "child" {} [] ])
            , test "list with depth of three generates tree with depth of three" <|
                \_ ->
                    let
                        emptyTree =
                            Node "parent" {} []

                        childrenTree =
                            Node "child1" {} [ Node "child2" {} [ Node "child3" {} [] ] ]

                        treeWithThreeChildren =
                            Node "parent" {} [ childrenTree ]
                    in
                    Expect.equal (fromPath [ "child1", "child2", "child3" ] {} nonTransformer emptyTree) treeWithThreeChildren
            , test "a new field do not duplicate an existing field" <|
                \_ ->
                    let
                        aTree =
                            Node "a" {} []
                    in
                    Expect.equal (fromPath [ "a" ] {} nonTransformer aTree) aTree
            , test "new fields do not duplicate existing fields" <|
                \_ ->
                    let
                        abcTree =
                            Node "b" {} [ Node "c" {} [ Node "d" {} [] ] ]
                    in
                    Expect.equal (fromPath [ "b", "c", "d" ] {} nonTransformer abcTree) abcTree
            , test "new fields are additive" <|
                \_ ->
                    let
                        startTree =
                            Node "e" {} [ Node "f" {} [] ]

                        expectedTree =
                            Node "e" {} [ Node "f" {} [], Node "g" {} [] ]
                    in
                    Expect.equal (fromPath [ "e", "g" ] {} nonTransformer startTree) expectedTree
            , test "multiple additive condition" <|
                \_ ->
                    let
                        startTree =
                            Node "h" {} [ Node "i" {} [], Node "j" {} [], Node "k" {} [] ]

                        expectedTree =
                            Node "h" {} [ Node "i" {} [], Node "j" {} [], Node "k" {} [], Node "l" {} [] ]
                    in
                    Expect.equal (fromPath [ "h", "l" ] {} nonTransformer startTree) expectedTree
            , test "complex condition" <|
                \_ ->
                    let
                        startTree =
                            Node "h" {} [ Node "i" {} [ Node "l" {} [], Node "m" {} [] ], Node "j" {} [], Node "k" {} [ Node "n" {} [], Node "o" {} [] ] ]

                        expectedTree =
                            Node "h" {} [ Node "i" {} [ Node "l" {} [], Node "m" {} [ Node "p" {} [] ] ], Node "j" {} [], Node "k" {} [ Node "n" {} [], Node "o" {} [] ] ]
                    in
                    Expect.equal (fromPath [ "h", "i", "m", "p" ] {} nonTransformer startTree) expectedTree
            , test "expand single base" <|
                \_ ->
                    let
                        startTree =
                            Node "a" {} []

                        expectedTree =
                            Node "a" {} [ Node "b" {} [ Node "c" {} [] ] ]
                    in
                    Expect.equal (fromPath [ "a", "b", "c" ] {} nonTransformer startTree) expectedTree
            , test "add node to second level with two nodes" <|
                \_ ->
                    let
                        startTree =
                            Node "e" {} [ Node "f" {} [], Node "g" {} [] ]

                        expectedTree =
                            Node "e" {} [ Node "f" {} [], Node "g" {} [], Node "h" {} [] ]
                    in
                    Expect.equal (fromPath [ "e", "h" ] {} nonTransformer startTree) expectedTree
            , test "add node to third level with one nodes" <|
                \_ ->
                    let
                        startTree =
                            Node "e" {} [ Node "f" {} [ Node "g" {} [] ] ]

                        expectedTree =
                            Node "e" {} [ Node "f" {} [ Node "g" {} [], Node "h" {} [] ] ]
                    in
                    Expect.equal (fromPath [ "e", "f", "h" ] {} nonTransformer startTree) expectedTree
            ]
        , describe "Failure Output Validation" <|
            [ describe "Expect.equal" <|
                [ describe "basic case" <|
                    [ test "passing" <|
                        \_ ->
                            Expect.equal 3 (1 + 2)
                    , test "failing" <|
                        \_ ->
                            Expect.equal 4 (1 + 2)
                    ]
                , describe "string with additions" <|
                    [ test "passing" <|
                        \_ ->
                            Expect.equal "abcdefghi" "abcdefghi"
                    , test "failing" <|
                        \_ ->
                            Expect.equal "abcdefghi" "abbbcdeeefghhhi"
                    ]
                , describe "string with removals" <|
                    [ test "passing" <|
                        \_ ->
                            Expect.equal "abcdefghi" "abcdefghi"
                    , test "failing" <|
                        \_ ->
                            Expect.equal "abcdefghi" "acdfgi"
                    ]
                ]
            , describe "Expect.notEqual" <|
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
            , describe "Expect.lessThan" <|
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
            , describe "Expect.atMost" <|
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
            , describe "Expect.greaterThan" <|
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
            , describe "Expect.atLeast" <|
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
            , describe "Expect.true" <|
                [ describe "basic case" <|
                    [ test "passing" <|
                        \_ ->
                            Expect.true "this should pass" True
                    , test "failing" <|
                        \_ ->
                            Expect.true "this should fail / true for false" False
                    ]
                ]
            , describe "Expect.false" <|
                [ describe "basic case" <|
                    [ test "passing" <|
                        \_ ->
                            Expect.false "this should pass" False
                    , test "failing" <|
                        \_ ->
                            Expect.false "this should fail / false for true" True
                    ]
                ]
            , describe "Expect.all" <|
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
            , describe "Expect.within" <|
                [ describe "pi" <|
                    [ test "passing" <|
                        \_ ->
                            3.14 |> Expect.within (Absolute 0.01) pi
                    , test "failing" <|
                        \_ ->
                            3.14 |> Expect.within (Absolute 0.001) pi
                    ]
                ]
            , describe "Expect.notWithin" <|
                [ describe "pi" <|
                    [ test "passing" <|
                        \_ ->
                            3.14 |> Expect.notWithin (Absolute 0.001) pi
                    , test "failing" <|
                        \_ ->
                            3.14 |> Expect.notWithin (Absolute 0.01) pi
                    ]
                ]
            , describe "Expect.err" <|
                [ describe "documentation example" <|
                    [ test "passing" <|
                        \_ ->
                            String.toInt "not an int" |> Expect.err
                    , test "failing" <|
                        \_ ->
                            String.toInt "20" |> Expect.err
                    ]
                ]
            , describe "Expect.equalLists" <|
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
            , describe "Expect.equalDicts" <|
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
            , describe "Expect.equalSets" <|
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
            , describe "Expect.pass and Expect.fail" <|
                [ describe "documentation example" <|
                    [ test "passing" <|
                        \_ ->
                            case decodeString int "42" of
                                Ok _ ->
                                    Expect.pass

                                Err err ->
                                    Expect.fail err
                    , test "failing" <|
                        \_ ->
                            case decodeString int "forty-two" of
                                Ok _ ->
                                    Expect.pass

                                Err err ->
                                    Expect.fail err
                    ]
                ]
            , describe "Expect.onFail" <|
                [ describe "documentation example" <|
                    [ test "custom failure message" <|
                        \_ ->
                            "something"
                                |> Expect.equal "something else"
                                |> Expect.onFail "thought those two strings would be the same"
                    ]
                ]
            , describe "final passing test" <|
                [ test "should not cause parent node to pass" <|
                    \_ ->
                        Expect.pass
                ]

            -- , describe "a todo" <|
            --     [ Test.todo "stuff & things"
            --     ]
            ]
        ]


nonTransformer : a -> a -> a
nonTransformer a1 a2 =
    a1
