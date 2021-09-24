module Stats exposing (maxColumn)

import Consts exposing (consts)
import Regex


spW : Float
spW =
    1.0 / toFloat consts.tabSize


getSW : Char -> Float -> Float
getSW c r =
    case c of
        '\t' ->
            r + 1

        ' ' ->
            r + spW

        _ ->
            0


columnIn : String -> Int
columnIn s =
    truncate <| String.foldl getSW 0.0 s


numColumns : String -> Int
numColumns s =
    Maybe.withDefault 0 <| Maybe.map (\t -> columnIn t.match) <| List.head <| Regex.find consts.tabMatch s


maxColumn : List String -> Int
maxColumn s =
    Maybe.withDefault 0 <| List.maximum <| List.map numColumns s
