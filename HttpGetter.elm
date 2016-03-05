module HttpGetter where

import Json.Decode exposing ((:=))
import Http exposing (Error) 
import Task exposing (Task)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal
import Effects

-- MODEL: Json Object that GET requerst returns
type alias Blob = { listings : List (Listing) }

type alias Listing = { key : String
                     , title : String
                     , body : String
                     , price : Float
                     , categories : List String
                     , approved : Bool
                     , sold : Bool
                     , lastUpdated : String }


init : Blob
init = { listings = [] }

-- Decoder
listingDecoder : Json.Decode.Decoder Listing
listingDecoder =
  Json.Decode.object8 Listing
    ("key" := Json.Decode.string)
    ("title" := Json.Decode.string)
    ("body" := Json.Decode.string)
    ("price" := Json.Decode.float)
    ("categories" := (Json.Decode.list Json.Decode.string))
    ("approved" := Json.Decode.bool)
    ("sold" := Json.Decode.bool)
    ("lastUpdate" := Json.Decode.string)

blobDecoder : Json.Decode.Decoder Blob
blobDecoder =
  Json.Decode.object1 Blob
    ("listings" := (Json.Decode.list listingDecoder))

-- Effects
getListings : String -> Task never (Maybe Blob)
getListings url =
  Http.get blobDecoder url
   |> Task.toMaybe

