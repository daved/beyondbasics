module Main exposing (..)

import Html exposing (..)
import Json.Decode exposing (..)


json : String
json =
    """
{
    "type": "success",
    "value": {
        "id": 490,
        "joke": "Chuck Norris doesn't need to use AJAX because pages are too afraid to postback anyways.",
        "categories": ["nerdy"]
    }
}
    """


decoder : Decoder String
decoder =
    at [ "value", "joke" ] string


jokeRes : Result String String
jokeRes =
    decodeString decoder json


main : Html msg
main =
    case jokeRes of
        Ok joke ->
            text joke

        Err err ->
            text err
