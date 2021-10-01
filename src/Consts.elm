module Consts exposing (..)
import Regex

consts =
    {
        tabSize = 4,
        tabMatch = Maybe.withDefault Regex.never <| Regex.fromString "^[ \\t]+",
        backendBase = "https://batbin.me/api/paste/"
    }