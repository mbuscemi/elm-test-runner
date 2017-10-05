module TestInstance.Reconcile exposing (transform)

import TestInstance.Core as Core exposing (TestInstance)


transform : TestInstance -> TestInstance -> TestInstance
transform new old =
    updateStatusPreferringFail new old


updateStatusPreferringFail : TestInstance -> TestInstance -> TestInstance
updateStatusPreferringFail new old =
    if Core.isFailing new || Core.isFailing old then
        Core.setStatus "fail" old
    else
        Core.setStatus "pass" old
