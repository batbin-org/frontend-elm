-- Copyright 2021 - 2021, Udit Karode, Rupansh Sekar and BatBin contributors
-- SPDX-License-Identifier: GPL-3.0-or-later
module Theme exposing (darkTheme)

import Element exposing (rgb255)
import Element.Font as Font exposing (Font)

type alias Theme =
    { headerBackground : Element.Color
    , text : Element.Color
    , contentBackground : Element.Color
    , logoBorder : Element.Color
    , textFont : List Font
    , buttonBorder : Element.Color
    , headerButtonHover : Element.Color
    , lineIndicator : Element.Color
    , lineBar: Element.Color
    }


darkTheme: Theme 
darkTheme =
    { headerBackground = rgb255 1 1 1
    , text = rgb255 0xfb 0xfb 0xfb
    , contentBackground = rgb255 0x10 0x10 0x10
    , logoBorder = rgb255 0x6b 0xa2 0xf0
    , textFont = [ Font.typeface "Fira Mono", Font.monospace ]
    , buttonBorder = rgb255 0xfb 0xfb 0xfb
    , headerButtonHover = rgb255 0xa0 0xa0 0xa0
    , lineIndicator = rgb255 0xb0 0xb0 0xb0
    , lineBar = rgb255 0x20 0x20 0x20
    }