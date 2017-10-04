module Tree.Merge exposing (fromPath)

import Tree.Tree exposing (Tree(Node))


fromPath : List a -> Tree a -> Tree a
fromPath path ((Node node children) as tree) =
    case path of
        [] ->
            tree

        x :: xs ->
            if node == x then
                Node node (mergeChildren xs children)
            else
                Node node (listToTree x xs :: children)


listToTree : a -> List a -> Tree a
listToTree first path =
    case path of
        [] ->
            Node first []

        x :: xs ->
            Node first [ listToTree x xs ]


mergeChildren : List a -> List (Tree a) -> List (Tree a)
mergeChildren path children =
    case path of
        [] ->
            children

        x :: xs ->
            case children of
                ((Node node nodeChildren) as current) :: rest ->
                    if node == x then
                        Node node (mergeChildren xs nodeChildren) :: rest
                    else
                        current :: mergeChildren path rest

                [] ->
                    [ listToTree x xs ]
