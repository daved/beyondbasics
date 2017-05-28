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
    }


initModel : Model
initModel =
    { wsDump = ""
    , isStreaming = False
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


type Msg
    = ToggleStream
    | Ping
    | RecvResp String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleStream ->
            let
                req =
                    if model.isStreaming then
                        "stop"
                    else
                        "start"

                cmd =
                    send wsUrl req

                isStreaming =
                    not model.isStreaming
            in
                ( { model | isStreaming = isStreaming }, cmd )

        Ping ->
            ( model, (send wsUrl "ping") )

        RecvResp resp ->
            let
                wsDump =
                    model.wsDump ++ "\n" ++ resp
            in
                ( { model | wsDump = wsDump }, Cmd.none )



-- view


view : Model -> Html Msg
view model =
    let
        streamBtnLabel =
            if model.isStreaming then
                "Stop"
            else
                "Start"
    in
        div []
            [ textarea [ cols 40, rows 40 ]
                [ text model.wsDump ]
            , button [ onClick ToggleStream ] [ text streamBtnLabel ]
            , button [ onClick Ping ] [ text "Ping" ]
            ]



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


subscriptions : Model -> Sub Msg
subscriptions model =
    listen wsUrl decodeResponse



--if model.isStreaming then
--    listen wsUrl decodeResponse
--else
--    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
