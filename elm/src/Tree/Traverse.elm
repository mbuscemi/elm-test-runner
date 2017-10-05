module Tree.Traverse exposing (update)

import Tree.Core exposing (Tree(Node))


type alias DataUpdater b =
    b -> b


update : DataUpdater b -> Tree a b -> Tree a b
update updater (Node node data children) =
    let
        updatedData =
            updater data
    in
    Node node updatedData (List.map (update updater) children)
