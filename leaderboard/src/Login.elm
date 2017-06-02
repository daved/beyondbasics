module Login exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


-- model


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Error error ->
            ( { model | error = Just error }, Cmd.none )

        UsernameInput username ->
            ( { model | username = username }, Cmd.none )

        PasswordInput password ->
            ( { model | password = password }, Cmd.none )

        Submit ->
            ( model, Cmd.none )



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
