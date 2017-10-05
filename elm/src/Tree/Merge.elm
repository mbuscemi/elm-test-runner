module Tree.Merge exposing (fromPath)

import Tree.Core exposing (Tree(Node))


fromPath : List a -> b -> Tree a b -> Tree a b
fromPath path newData ((Node node data children) as tree) =
    case path of
        [] ->
            tree

        x :: xs ->
            if node == x then
                Node node data (mergeChildren newData xs children)
            else
                Node node data (listToTree x newData xs :: children)


listToTree : a -> b -> List a -> Tree a b
listToTree first data path =
    case path of
        [] ->
            Node first data []

        x :: xs ->
            Node first data [ listToTree x data xs ]


mergeChildren : b -> List a -> List (Tree a b) -> List (Tree a b)
mergeChildren newData path children =
    case path of
        [] ->
            children

        x :: xs ->
            case children of
                ((Node node data nodeChildren) as current) :: rest ->
                    if node == x then
                        Node node newData (mergeChildren newData xs nodeChildren) :: rest
                    else
                        current :: mergeChildren newData path rest

                [] ->
                    [ listToTree x newData xs ]
