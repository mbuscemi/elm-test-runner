module State.PaneLocation exposing (PaneLocation, default, fromString, toStyle)


type PaneLocation
    = Right
    | Bottom
    | Left


default : PaneLocation
default =
    Right


fromString : String -> PaneLocation
fromString location =
    case location of
        "bottom" ->
            Bottom

        "left" ->
            Left

        _ ->
            Right


toStyle : PaneLocation -> String
toStyle paneLocation =
    case paneLocation of
        Bottom ->
            "horizontal"

        _ ->
            "vertical"
