module Tree.Merge exposing (fromPath)

import Tree.Tree exposing (Tree(Node))


fromPath : List String -> Tree String -> Tree String
fromPath list tree =
    case ( list, tree ) of
        ( listField :: rest, Node treeField [] ) ->
            if listField == treeField then
                fromPath rest (Node listField [])
            else
                Node treeField [ fromPath rest (Node listField []) ]

        ( listField :: nextField :: rest, Node treeField subNodes ) ->
            if listField == treeField then
                Node treeField (List.append (excludeSubNode nextField subNodes) [ fromPath rest (Node nextField []) ])
            else
                Node treeField (List.append subNodes [ fromPath (nextField :: rest) (Node listField []) ])

        ( listField :: rest, Node treeField subNodes ) ->
            Node treeField (List.append subNodes [ fromPath rest (Node listField []) ])

        ( [], Node treeField [] ) ->
            Node treeField []

        ( [], Node treeField subNodes ) ->
            Node treeField subNodes


excludeSubNode : String -> List (Tree String) -> List (Tree String)
excludeSubNode field subNodes =
    List.filter
        (\(Node nodeField _) -> nodeField /= field)
        subNodes


merge : String -> Tree String -> Tree String -> Tree String
merge field (Node _ subNodesA) (Node _ subNodesB) =
    Node field (List.append subNodesA subNodesB)


containsNodeWith : String -> List (Tree String) -> Bool
containsNodeWith field treeList =
    List.filter
        (\(Node nodeField _) ->
            field == nodeField
        )
        treeList
        |> List.length
        |> (>=) 1
