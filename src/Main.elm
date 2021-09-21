
-- Copyright 2021 - 2021, Udit Karode, Rupansh Sekar and BatBin contributors
-- SPDX-License-Identifier: GPL-3.0-or-later
module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Lazy exposing (lazy)
import FontAwesome.Attributes as Icon
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import FontAwesome.Styles as Icon
import Html.Attributes as Attr
import Task
import Theme exposing (darkTheme)


type alias Model =
    { code : String, lines : Int }


logoBord : String -> Element msg
logoBord s =
    el [ Font.color darkTheme.logoBorder ]
        (text s)


logo : Element msg
logo =
    row [ Font.bold, Font.size 24 ]
        [ logoBord "<"
        , text "BatBin"
        , logoBord "/>"
        ]


fontAwesomeHeader : Icon -> Element msg
fontAwesomeHeader icon =
    row [ mouseOver [ Font.color darkTheme.headerButtonHover ] ] [ html <| Icon.viewStyled [ Icon.lg ] icon, text "" ]


header : Element msg
header =
    row [ width fill, height <| fillPortion 1, Background.color darkTheme.headerBackground, paddingXY 16 0, spaceEvenly ]
        [ logo
        , row [ spacing 14 ]
            [ newTabLink [] { label = fontAwesomeHeader Icon.github, url = "https://github.com/batbin-org" }
            , fontAwesomeHeader Icon.save
            ]
        ]


content : Model -> Element Msg
content model =
    row
        [ width fill
        , height <| fillPortion 14
        , Background.color darkTheme.contentBackground
        , scrollbars
        , Font.size 16
        , Events.onClick FocusInput
        ]
        [ column
            [ alignTop
            , Font.color darkTheme.lineIndicator
            , Background.color darkTheme.lineBar
            , paddingEach { top = 0, left = 4, right = 8, bottom = 0 }
            , width (shrink |> maximum 50)
            ]
          <|
            List.map (\i -> el [ alignLeft ] <| text <| String.fromInt i) <|
                List.range 0 (model.lines - 1)
        , Input.multiline
            [ Background.color darkTheme.contentBackground
            , alignTop
            , width fill
            , paddingEach { top = 0, bottom = 12, left = 6, right = 0 }
            , Border.color <| rgba 0 0 0 0
            , focused [ Border.color <| rgba 0 0 0 0 ]
            , Input.focusedOnLoad
            , spacing 0
            , htmlAttribute <| Attr.id "code-input"
            ]
            { onChange = CodeInput
            , text = model.code
            , placeholder = Nothing
            , label = Input.labelHidden "code"
            , spellcheck = False
            }
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "BatBin"
    , body =
        [ layout [] <|
            column [ width fill, height fill, Font.color darkTheme.text, Font.family darkTheme.textFont ]
                [ lazy html Icon.css
                , header
                , lazy content model
                ]
        ]
    }


type Msg
    = CodeInput String
    | FocusInput
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CodeInput c ->
            ( { model | code = c, lines = List.length (String.lines c) }, Cmd.none )

        FocusInput ->
            ( model, Task.attempt (\_ -> NoOp) (Dom.focus "code-input") )

        NoOp ->
            ( model, Cmd.none )


init : () -> ( Model, Cmd Msg )
init _ =
    ( { code = "", lines = 1 }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
