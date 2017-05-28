module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket exposing (..)
import Json.Decode exposing (..)


-- general


wsUrl : String
wsUrl =
    "ws://localhost:3000/ws/example"



-- model


type alias Model =
    { wsDump : String
    , isStreaming : Bool
    , isConnected : Bool
    }


initModel : Model
initModel =
    { wsDump = ""
    , isStreaming = False
    , isConnected = False
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


type Msg
    = Connect
    | Disconnect
    | ToggleStream
    | Ping
    | RecvResp String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Connect ->
            ( { model | isConnected = True }, Cmd.none )

        Disconnect ->
            ( { model | isConnected = False }, Cmd.none )

        ToggleStream ->
            if model.isConnected then
                let
                    mdl =
                        { model | isStreaming = not model.isStreaming }

                    req =
                        if model.isStreaming then
                            "stop"
                        else
                            "start"
                in
                    ( mdl, send wsUrl req )
            else
                ( model, Cmd.none )

        Ping ->
            if model.isConnected then
                ( model, send wsUrl "ping" )
            else
                ( model, Cmd.none )

        RecvResp resp ->
            let
                mdl =
                    { model | wsDump = model.wsDump ++ "\n" ++ resp }
            in
                ( mdl, Cmd.none )



-- view


txtArea : String -> Html msg
txtArea txt =
    textarea [ cols 40, rows 40 ] [ text txt ]


connView : Model -> Html Msg
connView model =
    let
        streamBtnLabel =
            if model.isStreaming then
                "Stop"
            else
                "Start"
    in
        div []
            [ txtArea model.wsDump
            , button [ onClick ToggleStream ] [ text streamBtnLabel ]
            , button [ onClick Ping ] [ text "Ping" ]
            , button [ onClick Disconnect ] [ text "Disconnect" ]
            ]


noconnView : Model -> Html Msg
noconnView model =
    div []
        [ txtArea model.wsDump
        , button [ onClick Connect ] [ text "Connect" ]
        ]


view : Model -> Html Msg
view model =
    if model.isConnected then
        connView model
    else
        noconnView model



-- subscription


decodeResponse : String -> Msg
decodeResponse resp =
    decodeString
        (oneOf
            [ (at [ "time" ] string)
            , (at [ "msg" ] string)
            , (at [ "ping" ] string)
            ]
        )
        resp
        |> Result.withDefault "error decoding response"
        |> RecvResp



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.isConnected then
        listen wsUrl decodeResponse
    else
        Sub.none



-- main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
