port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Login
import LeaderBoard
import Navigation exposing (..)
import Runner


-- model


type Page
    = NotFoundPage
    | LoginPage
    | LeaderBoardPage
    | AddRunnerPage


pageToHash : Page -> String
pageToHash page =
    case page of
        NotFoundPage ->
            "#notfound"

        LoginPage ->
            "#login"

        LeaderBoardPage ->
            "#/"

        AddRunnerPage ->
            "#add"


hashToPage : String -> Page
hashToPage hash =
    case hash of
        "#login" ->
            LoginPage

        "#/" ->
            LeaderBoardPage

        "" ->
            LeaderBoardPage

        "#add" ->
            AddRunnerPage

        _ ->
            NotFoundPage


type alias Model =
    { page : Page
    , leaderBoard : LeaderBoard.Model
    , login : Login.Model
    , runner : Runner.Model
    , token : Maybe String
    , loggedIn : Bool
    }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        page =
            hashToPage location.hash

        ( loginInitModel, loginCmd ) =
            Login.init

        ( leaderBoardInitModel, leaderBoardCmd ) =
            LeaderBoard.init

        ( runnerInitModel, runnerCmd ) =
            Runner.init

        initModel =
            { page = page
            , login = loginInitModel
            , leaderBoard = leaderBoardInitModel
            , runner = runnerInitModel
            , token = flags.token
            , loggedIn = flags.token /= Nothing
            }

        cmds =
            Cmd.batch
                [ Cmd.map LeaderBoardMsg leaderBoardCmd
                , Cmd.map LoginMsg loginCmd
                , Cmd.map RunnerMsg runnerCmd
                ]
    in
        ( initModel, cmds )



-- update


type Msg
    = Navigate Page
    | SetPage Page
    | LoginMsg Login.Msg
    | LeaderBoardMsg LeaderBoard.Msg
    | RunnerMsg Runner.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate page ->
            ( model, newUrl <| pageToHash page )

        SetPage page ->
            ( { model | page = page }, Cmd.none )

        LoginMsg msg ->
            let
                ( loginModel, cmd, token ) =
                    Login.update msg model.login

                loggedIn =
                    token /= Nothing

                saveTokenCmd =
                    case token of
                        Just jwt ->
                            saveToken jwt

                        Nothing ->
                            Cmd.none
            in
                ( { model
                    | login = loginModel
                    , token = token
                    , loggedIn = loggedIn
                  }
                , Cmd.batch
                    [ Cmd.map LoginMsg cmd
                    , saveTokenCmd
                    ]
                )

        LeaderBoardMsg msg ->
            let
                ( leaderBoardModel, cmd ) =
                    LeaderBoard.update msg model.leaderBoard
            in
                ( { model | leaderBoard = leaderBoardModel }
                , Cmd.map LeaderBoardMsg cmd
                )

        RunnerMsg msg ->
            let
                ( runnerModel, cmd ) =
                    Runner.update msg model.runner
            in
                ( { model | runner = runnerModel }
                , Cmd.map RunnerMsg cmd
                )



-- view


viewPage : String -> Html Msg
viewPage pageDesc =
    div []
        [ h3 [] [ text pageDesc ]
        , p [] [ text <| "TODO: make " ++ pageDesc ]
        ]


pageHeader : Model -> Html Msg
pageHeader model =
    header []
        [ a [ onClick (Navigate LeaderBoardPage) ]
            [ text "Race Results" ]
        , ul []
            [ li []
                [ a [ onClick (Navigate AddRunnerPage) ]
                    [ text "Add Runner" ]
                ]
            ]
        , ul []
            [ li []
                [ a [ onClick (Navigate LoginPage) ] [ text "Login" ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    let
        page =
            case model.page of
                NotFoundPage ->
                    viewPage "Not Found Page"

                LoginPage ->
                    Html.map LoginMsg (Login.view model.login)

                LeaderBoardPage ->
                    Html.map LeaderBoardMsg (LeaderBoard.view model.leaderBoard)

                AddRunnerPage ->
                    Html.map RunnerMsg (Runner.view model.runner)
    in
        div []
            [ pageHeader model
            , page
            ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        loginSub =
            Login.subscriptions model.login

        leaderBoardSub =
            LeaderBoard.subscriptions model.leaderBoard

        runnerSub =
            Runner.subscriptions model.runner
    in
        Sub.batch
            [ Sub.map LoginMsg loginSub
            , Sub.map LeaderBoardMsg leaderBoardSub
            , Sub.map RunnerMsg runnerSub
            ]



-- ports


port saveToken : String -> Cmd msg



-- main


locationToMsg : Location -> Msg
locationToMsg location =
    location.hash
        |> hashToPage
        |> SetPage


type alias Flags =
    { token : Maybe String
    }


main : Program Flags Model Msg
main =
    Navigation.programWithFlags locationToMsg
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
