module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Login
import LeaderBoard
import Navigation exposing (..)


-- model


type Page
    = LeaderBoardPage
    | AddRunnerPage
    | LoginPage
    | NotFoundPage


pageToHash : Page -> String
pageToHash page =
    case page of
        LeaderBoardPage ->
            "#"

        AddRunnerPage ->
            "#add"

        LoginPage ->
            "#login"

        NotFoundPage ->
            "#notfound"


hashToPage : String -> Page
hashToPage hash =
    case hash of
        "" ->
            LeaderBoardPage

        "#add" ->
            AddRunnerPage

        "#login" ->
            LoginPage

        _ ->
            NotFoundPage


type alias Model =
    { page : Page
    , leaderBoard : LeaderBoard.Model
    , login : Login.Model
    }


initModel : Page -> Model
initModel page =
    { page = page
    , leaderBoard = LeaderBoard.initModel
    , login = Login.initModel
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        page =
            hashToPage location.hash
    in
        ( initModel page, Cmd.none )



-- update


type Msg
    = Navigate Page
    | ChangePage Page
    | LeaderBoardMsg LeaderBoard.Msg
    | LoginMsg Login.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate page ->
            ( model, newUrl <| pageToHash page )

        ChangePage page ->
            ( { model | page = page }, Cmd.none )

        LeaderBoardMsg lbMsg ->
            ( { model | leaderBoard = LeaderBoard.update lbMsg model.leaderBoard }, Cmd.none )

        LoginMsg lMsg ->
            ( { model | login = Login.update lMsg model.login }, Cmd.none )



-- view


viewPage : String -> Html Msg
viewPage pageDesc =
    div []
        [ h3 [] [ text pageDesc ]
        , p [] [ text <| "TODO: make " ++ pageDesc ]
        ]


view : Model -> Html Msg
view model =
    let
        page =
            case model.page of
                LeaderBoardPage ->
                    Html.map LeaderBoardMsg (LeaderBoard.view model.leaderBoard)

                AddRunnerPage ->
                    viewPage "Add Runner Page"

                LoginPage ->
                    Html.map LoginMsg (Login.view model.login)

                NotFoundPage ->
                    viewPage "Not Found Page"
    in
        div []
            [ header []
                [ a [ onClick (Navigate LeaderBoardPage) ]
                    [ text "LeaderBoard" ]
                , text " | "
                , a [ onClick (Navigate AddRunnerPage) ]
                    [ text "Add Runner" ]
                , text " | "
                , a [ onClick (Navigate LoginPage) ]
                    [ text "Login" ]
                ]
            , hr [] []
            , page
            ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- main


locationToMsg : Location -> Msg
locationToMsg location =
    location.hash
        |> hashToPage
        |> ChangePage


main : Program Never Model Msg
main =
    Navigation.program locationToMsg
        { init = init
        , update = update
        :q
        :q
        , view = view
        , subscriptions = subscriptions
        }
