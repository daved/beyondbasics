module Login exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Encode as JE
import Json.Decode as JD exposing (field)
import Navigation


-- model


url : String
url =
    "http://localhost:5000/authenticate"


type alias Model =
    { error : Maybe String
    , username : String
    , password : String
    }


initModel : Model
initModel =
    { error = Nothing
    , username = ""
    , password = ""
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


type Msg
    = Error String
    | UsernameInput String
    | PasswordInput String
    | Submit
    | LoginResponse (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg, Maybe String )
update msg model =
    case msg of
        Error error ->
            ( { model | error = Just error }, Cmd.none, Nothing )

        UsernameInput username ->
            ( { model | username = username }, Cmd.none, Nothing )

        PasswordInput password ->
            ( { model | password = password }, Cmd.none, Nothing )

        Submit ->
            let
                body =
                    JE.object
                        [ ( "username", JE.string model.username )
                        , ( "password", JE.string model.password )
                        ]
                        |> JE.encode 4
                        |> Http.stringBody "application/json"

                decoder =
                    field "token" JD.string

                req =
                    Http.post url body decoder

                cmd =
                    Http.send LoginResponse req
            in
                ( model, cmd, Nothing )

        LoginResponse (Ok tkn) ->
            ( initModel, Navigation.newUrl "#/", Just tkn )

        LoginResponse (Err err) ->
            let
                errMsg =
                    case err of
                        Http.BadStatus resp ->
                            case resp.status.code of
                                401 ->
                                    resp.body

                                _ ->
                                    resp.status.message

                        _ ->
                            "Unknown login error."
            in
                ( { model | error = Just errMsg }, Cmd.none, Nothing )



-- view


errorPanel : Maybe String -> Html a
errorPanel error =
    case error of
        Nothing ->
            text ""

        Just msg ->
            div [ class "error" ] [ text msg ]


loginForm : Model -> Html Msg
loginForm model =
    Html.form [ class "add-runner", onSubmit Submit ]
        [ fieldset []
            [ legend [] [ text "Login" ]
            , div []
                [ label [] [ text "User Name" ]
                , input
                    [ type_ "text"
                    , placeholder "username"
                    , value model.username
                    , onInput UsernameInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Password" ]
                , input
                    [ type_ "password"
                    , value model.password
                    , placeholder "password"
                    , onInput PasswordInput
                    ]
                    []
                ]
            , div []
                [ label [] []
                , button [ type_ "submit" ] [ text "Login" ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ errorPanel model.error
        , loginForm model
        ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
