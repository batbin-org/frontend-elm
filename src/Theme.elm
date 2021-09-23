-- Copyright 2021 - 2021, Udit Karode, Rupansh Sekar and BatBin contributors
-- SPDX-License-Identifier: GPL-3.0-or-later
module Theme exposing (darkTheme)

import Element exposing (rgb255)
import Element.Font as Font


darkTheme =
    { headerBackground = rgb255 0x25 0x25 0x25
    , outerText = rgb255 0xc7 0xf3 0xe3
    , text = rgb255 0xfb 0xfb 0xfb
    , contentBackground = rgb255 6 6 6
    , logoBorder = rgb255 0x6b 0xa2 0xf0
    , textFont = [ Font.typeface "Fira Mono", Font.monospace ]
    , logoFont = [ Font.typeface "Roboto Mono", Font.monospace ]
    , lineIndicator = rgb255 0xd1 0xd0 0xd0
    , lineBar = rgb255 0x2f 0x2f 0x2f
    , footerBackground = rgb255 0x23 0x23 0x23
    , footerBorder = rgb255 0x4B 0x4B 0x4B
    }