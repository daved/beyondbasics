module LeaderBoard exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as JE
import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import WebSocket exposing (..)
import Time
import Date
import Date.Extra.Format as DateFormat
import Date.Extra.Config.Config_en_us as DateConfig


-- model


type alias Runner =
    { id : String
    , name : String
    , location : String
    , age : Int
    , bib : Int
    , estimatedDistance : Float
    , lastMarkerDistance : Float
    , lastMarkerTime : Float
    , pace : Float
    }


type alias RunnerWsMsg =
    { name : String
    , runner : Runner
    }


type alias Model =
    { error : Maybe String
    , query : String
    , runners : List Runner
    , active : Bool
    }


initModel : Model
initModel =
    { error = Nothing
    , query = ""
    , runners = []
    , active = False
    }


url : String
url =
    "ws://localhost:5000/runners"


encodeMsg : String -> JE.Value -> String
encodeMsg name data =
    JE.object
        [ ( "name", JE.string name )
        , ( "data", data )
        ]
        |> JE.encode 0


listenRunnersCmd : Cmd Msg
listenRunnersCmd =
    send url (encodeMsg "listen runners" JE.null)


init : ( Model, Cmd Msg )
init =
    ( initModel, listenRunnersCmd )



-- update


type Msg
    = SearchInput String
    | Search
    | WsMessage String
    | Tick Time.Time


runnerDecoder : JD.Decoder Runner
runnerDecoder =
    JDP.decode Runner
        |> JDP.required "_id" JD.string
        |> JDP.required "name" JD.string
        |> JDP.required "location" JD.string
        |> JDP.required "age" JD.int
        |> JDP.required "bib" JD.int
        |> JDP.hardcoded 0
        |> JDP.required "lastMarkerDistance" JD.float
        |> JDP.required "lastMarkerTime" JD.float
        |> JDP.required "pace" JD.float


msgDecoder : JD.Decoder RunnerWsMsg
msgDecoder =
    JDP.decode RunnerWsMsg
        |> JDP.required "name" JD.string
        |> JDP.required "data" runnerDecoder


wsMessage : String -> Model -> ( Model, Cmd Msg )
wsMessage wsMsg model =
    case JD.decodeString msgDecoder wsMsg of
        Ok { name, runner } ->
            case name of
                "new runner" ->
                    ( { model | runners = runner :: model.runners }, Cmd.none )

                "update runner" ->
                    let
                        updatedRunners =
                            List.map
                                (\r ->
                                    if r.id == runner.id then
                                        runner
                                    else
                                        r
                                )
                                model.runners
                    in
                        ( { model | runners = updatedRunners }, Cmd.none )

                _ ->
                    ( { model
                        | error = Just ("Unrecognized message: " ++ name)
                      }
                    , Cmd.none
                    )

        Err err ->
            ( { model | error = Just err }, Cmd.none )


advanceDistance : Float -> Runner -> Runner
advanceDistance time runner =
    let
        elapsedMinutes =
            (time - runner.lastMarkerTime) / 1000
    in
        if runner.lastMarkerTime > 0 then
            { runner
                | estimatedDistance =
                    runner.lastMarkerDistance + (runner.pace * elapsedMinutes)
            }
        else
            runner


tick : Model -> Time.Time -> Model
tick model time =
    let
        updatedRunners =
            List.map (advanceDistance time) model.runners
    in
        { model | runners = updatedRunners }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchInput query ->
            ( { model | query = query }, Cmd.none )

        Search ->
            ( model, Cmd.none )

        WsMessage wsMsg ->
            wsMessage wsMsg model

        Tick time ->
            ( tick model time, Cmd.none )



-- view


errorPanel : Maybe String -> Html a
errorPanel error =
    case error of
        Nothing ->
            text ""

        Just msg ->
            div [ class "error" ]
                [ text msg
                , button [ type_ "button" ] [ text "x" ]
                ]


searchForm : String -> Html Msg
searchForm query =
    Html.form [ onSubmit Search ]
        [ input
            [ type_ "text"
            , placeholder "Search for runner..."
            , value query
            , onInput SearchInput
            ]
            []
        , button [ type_ "submit" ] [ text "Search" ]
        ]


formatDistance : Float -> String
formatDistance distance =
    if distance <= 0 then
        ""
    else
        distance * 100 |> round |> toFloat |> flip (/) 100 |> toString


formatTime : Float -> String
formatTime time =
    if time > 0 then
        time
            |> Date.fromTime
            |> DateFormat.format DateConfig.config
                "%H:%M:%S %P"
    else
        ""


lastMarker : Runner -> Html Msg
lastMarker runner =
    if runner.lastMarkerTime > 0 then
        text
            ((formatDistance runner.lastMarkerDistance)
                ++ " mi @ "
                ++ formatTime (runner.lastMarkerTime)
            )
    else
        text ""


runner : Runner -> Html Msg
runner runner =
    let
        { name, location, age, bib, estimatedDistance } =
            runner
    in
        tr []
            [ td [] [ text name ]
            , td [] [ text location ]
            , td [] [ text (toString age) ]
            , td [] [ text (toString bib) ]
            , td []
                [ lastMarker runner ]
            , td [] [ text (formatDistance estimatedDistance) ]
            ]


runnersHeader : Html Msg
runnersHeader =
    thead []
        [ tr []
            [ th [] [ text "Name" ]
            , th [] [ text "From" ]
            , th [] [ text "Age" ]
            , th [] [ text "Bib #" ]
            , th [] [ text "Last Marker" ]
            , th [] [ text "Est. Miles" ]
            ]
        ]


runners : Model -> Html Msg
runners { query, runners } =
    runners
        |> List.map runner
        |> tbody []
        |> (\r -> runnersHeader :: [ r ])
        |> table []


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ errorPanel model.error
        , searchForm model.query
        , runners model
        ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ listen url WsMessage
        , Time.every Time.second Tick
        ]
