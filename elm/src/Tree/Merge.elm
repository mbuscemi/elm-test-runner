module Tree.Merge exposing (fromPath)

import Tree.Core exposing (Tree(Node))


type alias DataTransformer b =
    b -> b -> b


fromPath : List a -> b -> DataTransformer b -> Tree a b -> Tree a b
fromPath path newData transformer ((Node node data children) as tree) =
    case path of
        [] ->
            tree

        x :: xs ->
            if node == x then
                Node node data (mergeChildren xs newData transformer children)
            else
                Node node data (listToTree x newData xs :: children)


listToTree : a -> b -> List a -> Tree a b
listToTree first data path =
    case path of
        [] ->
            Node first data []

        x :: xs ->
            Node first data [ listToTree x data xs ]


mergeChildren : List a -> b -> DataTransformer b -> List (Tree a b) -> List (Tree a b)
mergeChildren path newData transformer children =
    case path of
        [] ->
            children

        x :: xs ->
            case children of
                ((Node node data nodeChildren) as current) :: rest ->
                    let
                        transformedData =
                            transformer newData data
                    in
                    if node == x then
                        Node node newData (mergeChildren xs transformedData transformer nodeChildren) :: rest
                    else
                        current :: mergeChildren path transformedData transformer rest

                [] ->
                    [ listToTree x newData xs ]
