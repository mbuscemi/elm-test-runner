module TestInstance.Reconcile exposing (transform)

import TestInstance.Core exposing (TestInstance)


transform : TestInstance -> TestInstance -> TestInstance
transform new old =
    new
