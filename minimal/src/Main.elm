port module Main exposing (..)

import Html exposing (..)


-- model


title : String
title =
    "This is the title."


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    let
        cmd =
            setDocTitle title
    in
        ( Model, cmd )



-- update


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )



-- view


view : Model -> Html Msg
view model =
    text "test"



-- port


port setDocTitle : String -> Cmd msg



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
        , subscriptions = subscriptions
        , view = view
        }
