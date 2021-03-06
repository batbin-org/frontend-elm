-- Copyright 2021 - 2021, Udit Karode, Rupansh Sekar and BatBin contributors
-- SPDX-License-Identifier: GPL-3.0-or-later


port module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Lazy exposing (lazy)
import FeatherIcons as Icon exposing (Icon)
import Html.Attributes as Attr
import Stats
import Task
import Theme exposing (darkTheme)
import Url
import Url.Parser exposing (Parser, string, (</>), s, oneOf)
import Html exposing (Html, pre, code)
import Url.Builder
import PasteClient exposing (getPaste)


type CodeDisplayMode = Mut | Immut
type alias Model =
    { code : String, extension: Maybe String, key : Nav.Key, codeDisplay : CodeDisplayMode, lines : Int, columns : Int }
type Route = Paste String


logoBord : String -> Element msg
logoBord s =
    el [ Font.color darkTheme.logoBorder ]
        (text s)


logo : Element msg
logo =
    el [ Font.color darkTheme.outerText, Font.size 42, Font.family darkTheme.logoFont ] (text "batbin")


fontAwesomeHeader : List (Attribute msg) -> Icon -> Element msg
fontAwesomeHeader props icon =
    el
        (props
            ++ [ Font.color darkTheme.outerText
               , mouseOver [ alpha 0.6 ]
               ]
        )
        (html <| (icon |> Icon.withSize 34 |> Icon.withStrokeWidth 1 |> Icon.toHtml []))


header : Element msg
header =
    row [ width fill, height <| fillPortion 4, Background.color darkTheme.headerBackground, paddingXY 44 0, spacing 14 ]
        [ logo
        , newTabLink [ alignRight ] { label = fontAwesomeHeader [] Icon.github, url = "https://github.com/batbin-org" }
        , fontAwesomeHeader [ alignRight ] Icon.save
        ]


baseCodeStyle : List (Attribute msg)
baseCodeStyle =
    [Background.color darkTheme.contentBackground
    , paddingEach { top = 12, bottom = 12, left = 6, right = 0 }
    , alignTop
    , width <| fillPortion 130
    , spacing 0
    ]

codeInput : Model -> Element Msg
codeInput model =
    Input.multiline
        (baseCodeStyle ++ [ Border.color <| rgba 0 0 0 0
        , focused [ Border.color <| rgba 0 0 0 0 ]
        , Input.focusedOnLoad
        , htmlAttribute <| Attr.id "code-input"
        ])
        { onChange = CodeInput
        , text = model.code
        , placeholder = Nothing
        , label = Input.labelHidden "code"
        , spellcheck = False
        }

noMarginPre: List (Html msg) -> Html msg
noMarginPre e =
    pre [ Attr.style "margin" "0" ] e

highlightCode: String -> Maybe String -> Html msg
highlightCode c ext =
    code [ Attr.id "code"
    , Attr.style "padding" "0"
    , Attr.class <| Maybe.withDefault "autodetect" <| Maybe.map (\e -> "language-" ++ e) ext
    ] [ Html.text c ] 

highlightBlock : String -> Maybe String -> Element msg
highlightBlock c ext =
    html <| noMarginPre [ highlightCode c ext ]

codeImmut : Model -> Element Msg
codeImmut model =
    el baseCodeStyle (highlightBlock model.code model.extension)

content : Model -> Element Msg
content model =
    let
        codeElem = case model.codeDisplay of
            Mut -> codeInput
            Immut -> codeImmut
    in
    row
        [ width fill
        , height <| fillPortion 36
        , Background.color darkTheme.contentBackground
        , scrollbars
        , Font.size 16
        , Events.onClick FocusInput
        ]
        [ row [ alignTop, width <| fillPortion 4, Background.color darkTheme.lineBar ]
            [ column
                [ alignTop
                , alignRight
                , Font.color darkTheme.lineIndicator
                , paddingEach { top = 12, bottom = 12, left = 0, right = 16 }
                ]
              <|
                List.map (\i -> el [ alignRight ] <| text <| String.fromInt i) <|
                    List.range 0 (model.lines - 1)
            ]
        , codeElem model
        ]


footer : Model -> Element msg
footer model =
    row
        [ width fill
        , height <| fillPortion 1
        , Background.color darkTheme.footerBackground
        , Border.roundEach
            { topLeft = 10
            , topRight = 10
            , bottomLeft = 0
            , bottomRight = 0
            }
        , Border.solid
        , Border.widthEach
            { bottom = 0
            , left = 0
            , right = 0
            , top = 1
            }
        , Border.color darkTheme.footerBorder
        , Font.color darkTheme.outerText
        , Font.size 14
        , paddingXY 32 3
        ]
        [ text <| String.fromInt model.lines ++ " lines, " ++ String.fromInt model.columns ++ " columns"
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "BatBin"
    , body =
        [ layout [] <|
            column [ width fill, height fill, Font.color darkTheme.text, Font.family darkTheme.textFont, Background.color darkTheme.contentBackground ]
                [ header
                , lazy content model
                , lazy footer model
                ]
        ]
    }


type Msg
    = CodeInput String
    | CodeRemote String (Maybe String)
    | FocusInput
    | LinkClick Browser.UrlRequest
    | UrlChange Url.Url
    | Reset
    | NoOp

updateCode : String -> Model -> Model
updateCode c model =
    let
        lines =
            String.lines c
    in
    { model
     | code = c
     , lines = List.length lines
     , columns = Stats.maxColumn lines
    }

resetBase: Nav.Key -> (Model, Cmd Msg)
resetBase key =
    (baseModel key Mut, Nav.pushUrl key <| Url.Builder.relative ["/"] [])

onUrlChange: Url.Url -> Nav.Key -> (Model, Cmd Msg)
onUrlChange url key =
    case Url.Parser.parse routeParser url of
        Nothing ->
            (baseModel key Mut, Cmd.none )
        Just(Paste s) ->
            Maybe.withDefault (resetBase key) <| Maybe.map (\cmd -> (baseModel key Immut, cmd)) <| getPasteRemote s

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CodeInput c ->
            ( updateCode c model, Cmd.none)

        CodeRemote c extension ->
            let
                newModel = updateCode c model
            in
            ( { newModel | extension = extension }, highlight () )

        FocusInput ->
            ( model, Task.attempt (\_ -> NoOp) (Dom.focus "code-input") )

        LinkClick req ->
            case req of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )
                Browser.External href ->
                    ( model, Nav.load href )
    
        UrlChange url ->
            onUrlChange url model.key

        Reset ->
            resetBase model.key

        NoOp ->
            (model, Cmd.none)


remotePasteMap: Maybe String -> Maybe String -> Msg
remotePasteMap m ext =
    Maybe.withDefault Reset <| Maybe.map (\c -> CodeRemote c ext) m

getPasteRemote: String -> Maybe (Cmd Msg)
getPasteRemote id =
    case String.split "." id of
        [pasteid, ext] -> Just <| Cmd.map (\c -> remotePasteMap c (Just ext)) <| getPaste pasteid
        [pasteid] -> Just <| Cmd.map (\c -> remotePasteMap c Nothing) <| getPaste pasteid
        _ -> Nothing


baseModel: Nav.Key -> CodeDisplayMode -> Model
baseModel key codeDisplay =
    { code = ""
    , extension = Nothing
    , key = key
    , codeDisplay = codeDisplay
    , lines = 1
    , columns = 0 
    }

routeParser : Parser (Route -> a) a
routeParser =
    oneOf [ Url.Parser.map Paste string ]

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key = onUrlChange url key

port highlight : () -> Cmd msg

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = (\_ -> NoOp)
        , onUrlRequest = (\_ -> NoOp)
        }
