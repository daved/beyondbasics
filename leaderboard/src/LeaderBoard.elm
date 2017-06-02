module LeaderBoard exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


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


tempRunners : List Runner
tempRunners =
    [ Runner "1" "James Moore" "Turlock CA" 42 1234 0 1 1463154945381 0.125
    , Runner "2" "Sum Gai" "Yreka CA" 41 1236 0 1 1463154945381 0.09
    ]


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
    , runners = tempRunners
    , active = False
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


type Msg
    = SearchInput String
    | Search


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchInput query ->
            ( { model | query = query }, Cmd.none )

        Search ->
            ( model, Cmd.none )



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


runner : Runner -> Html Msg
runner { name, location, age, bib, estimatedDistance } =
    tr []
        [ td [] [ text name ]
        , td [] [ text location ]
        , td [] [ text (toString age) ]
        , td [] [ text (toString bib) ]
        , td [] [ text "1 mi @ 08:30AM (TODO)" ]
        , td [] [ text (toString estimatedDistance) ]
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
    Sub.none
