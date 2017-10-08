module Tests exposing (suite)

import Expect
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
        , describe "Helper Tests" <|
            [ test "basic addition" <|
                \_ ->
                    Expect.equal (1 + 2) 3
            ]
        ]


nonTransformer : a -> a -> a
nonTransformer a1 a2 =
    a1
