module Runner exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String


-- model


type alias Model =
    { error : Maybe String
    , id : String
    , nameError : Maybe String
    , name : String
    , locationError : Maybe String
    , location : String
    , ageError : Maybe String
    , age : String
    , bibError : Maybe String
    , bib : String
    }


initModel : Model
initModel =
    { error = Nothing
    , id = ""
    , nameError = Nothing
    , name = ""
    , locationError = Nothing
    , location = ""
    , ageError = Nothing
    , age = ""
    , bibError = Nothing
    , bib = ""
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


type Msg
    = NameInput String
    | LocationInput String
    | AgeInput String
    | BibInput String
    | Save


ageInput : Model -> String -> ( Model, Cmd Msg )
ageInput model age =
    let
        ageInt =
            age
                |> String.toInt
                |> Result.withDefault 0

        ageError =
            if ageInt <= 0 then
                Just "Must enter a positive number."
            else
                Nothing
    in
        ( { model | ageError = ageError, age = age }, Cmd.none )


bibInput : Model -> String -> ( Model, Cmd Msg )
bibInput model bib =
    let
        bibInt =
            bib
                |> String.toInt
                |> Result.withDefault 0

        bibError =
            if bibInt <= 0 then
                Just "Must enter a positive number."
            else
                Nothing
    in
        ( { model | bibError = bibError, bib = bib }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NameInput name ->
            ( { model | nameError = Nothing, name = name }, Cmd.none )

        LocationInput location ->
            ( { model | locationError = Nothing, location = location }, Cmd.none )

        AgeInput age ->
            ageInput model age

        BibInput bib ->
            bibInput model bib

        Save ->
            ( model, Cmd.none )



-- view


errorPanel : Maybe String -> Html a
errorPanel error =
    case error of
        Nothing ->
            text ""

        Just msg ->
            div [ class "error" ] [ text msg ]


viewForm : Model -> Html Msg
viewForm model =
    Html.form [ class "add-runner", onSubmit Save ]
        [ fieldset []
            [ legend [] [ text "Add/Edit Runner" ]
            , div []
                [ label [] [ text "Name" ]
                , input
                    [ type_ "text"
                    , value model.name
                    , onInput NameInput
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" model.nameError ]
                ]
            , div []
                [ label [] [ text "Location" ]
                , input
                    [ type_ "text"
                    , value model.location
                    , onInput LocationInput
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" model.locationError ]
                ]
            , div []
                [ label [] [ text "Age" ]
                , input
                    [ type_ "text"
                    , value model.age
                    , onInput AgeInput
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" model.ageError ]
                ]
            , div []
                [ label [] [ text "Bib#" ]
                , input
                    [ type_ "text"
                    , value model.bib
                    , onInput BibInput
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" model.bibError ]
                ]
            , div []
                [ label [] []
                , button [ type_ "submit" ] [ text "Save" ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ errorPanel model.error
        , viewForm model
        ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
