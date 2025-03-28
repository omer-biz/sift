module Types.Theme exposing (..)


type Theme
    = Light
    | Dark
    | System


toString : Theme -> String
toString theme =
    case theme of
        Dark ->
            "dark"

        Light ->
            "light"

        System ->
            "system"


fromMaybeString : Maybe String -> Theme
fromMaybeString str =
    case str of
        Just "dark" ->
            Dark

        Just "light" ->
            Light

        _ ->
            System
