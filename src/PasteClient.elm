module PasteClient exposing (getPaste)

import Consts exposing (consts)
import Http
import Json.Decode exposing (Decoder, field, string, map2)

type alias PasteResponse =
    { message: String
    , status: String
    }

type Ret = Paste (Result Http.Error PasteResponse)

pasteDecoder: Decoder PasteResponse
pasteDecoder =
    map2 PasteResponse
        (field "message" string)
        (field "status" string)

pasteMapper: Ret -> Maybe String
pasteMapper r =
    case r of
        Paste (Ok resp) ->
            if resp.status == "success" then Just resp.message else Nothing
        _ ->
            Nothing

fetchPaste: String -> Cmd Ret
fetchPaste id =
    Http.get
        { url = consts.backendBase ++ "id"
        , expect = Http.expectJson Paste pasteDecoder
        }

getPaste: String -> Cmd (Maybe String)
getPaste id =
    Cmd.map pasteMapper <| fetchPaste id