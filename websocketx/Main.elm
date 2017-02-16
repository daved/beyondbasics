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
    { dump : String
    , stream : Bool
    }


initModel : Model
initModel =
    { dump = ""
    , stream = False
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
update msg mdl =
    case msg of
        ToggleStream ->
            let
                req =
                    if mdl.stream then
                        "stop"
                    else
                        "start"

                cmd =
                    send wsUrl req

                stream =
                    not mdl.stream
            in
                ( { mdl | stream = stream }, cmd )

        Ping ->
            ( mdl, (send wsUrl "ping") )

        RecvResp resp ->
            let
                dump =
                    mdl.dump ++ "\n" ++ resp
            in
                ( { mdl | dump = dump }, Cmd.none )



-- view


view : Model -> Html Msg
view mdl =
    let
        streamBtnLabel =
            if mdl.stream then
                "Stop"
            else
                "Start"
    in
        div []
            [ textarea [ cols 40, rows 40 ]
                [ text mdl.dump ]
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
subscriptions mdl =
    listen wsUrl decodeResponse



--if mdl.stream then
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
