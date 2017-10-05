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
            let
                transformedData =
                    transformer newData data
            in
            if node == x then
                Node node transformedData (mergeChildren xs newData transformedData transformer children)
            else
                Node node transformedData (listToTree x newData xs :: children)


listToTree : a -> b -> List a -> Tree a b
listToTree first data path =
    case path of
        [] ->
            Node first data []

        x :: xs ->
            Node first data [ listToTree x data xs ]


mergeChildren : List a -> b -> b -> DataTransformer b -> List (Tree a b) -> List (Tree a b)
mergeChildren path originalData newData transformer children =
    case path of
        [] ->
            children

        x :: xs ->
            case children of
                ((Node node data nodeChildren) as current) :: rest ->
                    if node == x then
                        Node node newData (mergeChildren xs originalData newData transformer nodeChildren) :: rest
                    else
                        current :: mergeChildren path originalData originalData transformer rest

                [] ->
                    [ listToTree x originalData xs ]
