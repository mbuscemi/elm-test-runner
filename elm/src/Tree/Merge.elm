module Tree.Merge exposing (fromPath)

import List.Extra as List
import Maybe exposing (withDefault)
import Tree.Tree exposing (Tree(Node))


fromPath : List String -> Tree String -> Tree String
fromPath list tree =
    case ( list, tree ) of
        ( listField :: rest, Node treeField [] ) ->
            -- let
            --     check =
            --         Debug.log "group" "1"
            --
            --     check1 =
            --         Debug.log "listField :: rest" (listField :: rest)
            --
            --     check2 =
            --         Debug.log "Node treeField []" (Node treeField [])
            -- in
            if listField == treeField then
                fromPath rest (Node listField [])
            else
                Node treeField [ fromPath rest (Node listField []) ]

        ( listField :: nextField :: rest, Node treeField subNodes ) ->
            -- let
            --     check =
            --         Debug.log "group" "2"
            --
            --     check1 =
            --         Debug.log "listField :: nextField :: rest" (listField :: nextField :: rest)
            --
            --     check2 =
            --         Debug.log "Node treeField subNodes" (Node treeField subNodes)
            -- in
            if listField == treeField then
                Node treeField (List.append (excludeSubNode nextField subNodes) [ fromPath rest (findSubNode nextField subNodes) ])
            else
                Node treeField (List.append subNodes [ fromPath (nextField :: rest) (Node listField []) ])

        ( listField :: rest, Node treeField subNodes ) ->
            -- let
            --     check =
            --         Debug.log "group" "3"
            --
            --     check1 =
            --         Debug.log "listField :: rest" (listField :: rest)
            --
            --     check2 =
            --         Debug.log "Node treeField subNodes" (Node treeField subNodes)
            -- in
            Node treeField (List.append (excludeSubNode listField subNodes) [ fromPath rest (Node listField []) ])

        ( [], Node treeField [] ) ->
            -- let
            --     check =
            --         Debug.log "group" "4"
            --
            --     check2 =
            --         Debug.log "Node treeField []" (Node treeField [])
            -- in
            Node treeField []

        ( [], Node treeField subNodes ) ->
            -- let
            --     check =
            --         Debug.log "group" "5"
            --
            --     check2 =
            --         Debug.log "Node treeField subNodes" (Node treeField subNodes)
            -- in
            Node treeField subNodes


excludeSubNode : String -> List (Tree String) -> List (Tree String)
excludeSubNode field subNodes =
    List.filter
        (\(Node nodeField _) -> nodeField /= field)
        subNodes


findSubNode : String -> List (Tree String) -> Tree String
findSubNode field subNodes =
    List.find
        (\(Node nodeField _) -> nodeField == field)
        subNodes
        |> withDefault (Node field [])


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
