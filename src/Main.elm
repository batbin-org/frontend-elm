-- Copyright 2021 - 2021, Udit Karode, Rupansh Sekar and BatBin contributors
-- SPDX-License-Identifier: GPL-3.0-or-later


module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Consts exposing (consts)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Lazy exposing (lazy)
import FeatherIcons as Icon exposing (Icon)
import Html.Attributes as Attr
import Regex exposing (Regex)
import Stats
import Task
import Theme exposing (darkTheme)


type alias Model =
    { code : String, lines : Int, columns : Int }


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


content : Model -> Element Msg
content model =
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
        , Input.multiline
            [ Background.color darkTheme.contentBackground
            , alignTop
            , width <| fillPortion 130
            , paddingEach { top = 12, bottom = 12, left = 6, right = 0 }
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
    | FocusInput
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CodeInput c ->
            let
                lines =
                    String.lines c
            in
            ( { model
                | code = c
                , lines = List.length lines
                , columns = Stats.maxColumn lines
              }
            , Cmd.none
            )

        FocusInput ->
            ( model, Task.attempt (\_ -> NoOp) (Dom.focus "code-input") )

        NoOp ->
            ( model, Cmd.none )


init : () -> ( Model, Cmd Msg )
init _ =
    ( { code = "", lines = 1, columns = 0 }, Cmd.none )


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
