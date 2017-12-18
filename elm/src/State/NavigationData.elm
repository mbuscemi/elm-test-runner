module State.NavigationData exposing (NavigationData, make)

import TestInstance.Core as TestInstance exposing (TestInstance)


type alias NavigationData =
    ( String, List String, String )


make : String -> TestInstance -> NavigationData
make workingDirectory testInstance =
    let
        pathAndDescription =
            TestInstance.pathAndDescription testInstance
    in
    ( workingDirectory, Tuple.first pathAndDescription, Tuple.second pathAndDescription )
