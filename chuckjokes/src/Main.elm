module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Jd exposing (..)
import Json.Decode.Pipeline as Jdp exposing (decode, required, optional)


-- records


type alias Response =
    { id : Int
    , joke : String
    , categories : List String
    }


responseDecoder : Decoder Response
responseDecoder =
    --map3 Response
    --    (field "id" int)
    --    (field "joke" string)
    --    (field "categories" (JDP.list string))
    --    |> at [ "value" ]
    decode Response
        |> Jdp.required "id" int
        |> Jdp.required "joke" string
        |> optional "categories" (Jd.list string) []
        |> at [ "value" ]



-- model


type alias Model =
    String


initModel : Model
initModel =
    "Finding a joke..."


init : ( Model, Cmd Msg )
init =
    ( initModel, randomJoke )


randomJoke : Cmd Msg
randomJoke =
    let
        url =
            "http://api.icndb.com/jokes/random"

        req =
            -- Http.getString url
            Http.get url responseDecoder

        cmd =
            Http.send Joke req
    in
        cmd



-- update


type Msg
    = Joke (Result Http.Error Response)
    | NewJoke


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Joke (Ok res) ->
            ( toString (res.id) ++ " " ++ res.joke, Cmd.none )

        Joke (Err err) ->
            ( (toString err), Cmd.none )

        NewJoke ->
            ( "fetching joke...", randomJoke )



-- view


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ text model ]
        , div []
            [ button
                [ type_ "button"
                , onClick NewJoke
                ]
                [ text "Another!" ]
            ]
        ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
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
