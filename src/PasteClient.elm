-- Copyright 2021 - 2021, Udit Karode, Rupansh Sekar and BatBin contributors
-- SPDX-License-Identifier: GPL-3.0-or-later


module PasteClient exposing (getPaste)

import Consts exposing (consts)
import Http
import Json.Decode exposing (Decoder, field, string, map2)

type alias PasteResponse =
    { message: String
    , status: String
    }

type Ret = Paste (Result Http.Error String)

pasteDecoder: Decoder PasteResponse
pasteDecoder =
    map2 PasteResponse
        (field "message" string)
        (field "status" string)

pasteMapper: Ret -> Maybe String
pasteMapper r =
    case r of
        Paste (Ok resp) ->
            Result.withDefault (Just resp) <| Result.map (\_ -> Nothing) <| Json.Decode.decodeString pasteDecoder resp
        _ ->
            Nothing

fetchPaste: String -> Cmd Ret
fetchPaste id =
    Http.get
        { url = consts.backendBase ++ id
        , expect = Http.expectString Paste
        }

getPaste: String -> Cmd (Maybe String)
getPaste id =
    Cmd.map pasteMapper <| fetchPaste id