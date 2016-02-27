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

-- getMailbox : Sigal.Mailbox (Task Http.Error ())
-- getMailbox =
--   Signal.mailbox makeGetRequest
-- 
-- 
-- makeGetRequest : Task Http.Error ()
-- makeGetRequest = 
--   Http.get blobDecoder testUrl `Task.andThen` sendToListingsMailbox
-- 
-- port fetchListing : Signal (Task Http.Error ())
-- port fetchListing =
--   Debug.log "Trigger" getMailbox.signal
-- 
-- sendToListingsMailbox : Blob -> Task Http.Error ()
-- sendToListingsMailbox l =
--   Signal.send listingsMailbox.address l
-- 
-- listingsMailbox : Signal.Mailbox Blob
-- listingsMailbox =
--   Signal.mailbox { listings = [] }
-- 
-- view : Blob -> Html
-- view l =
--   let listingsList = l.listings in
--   div []
--       [ div []
--             [text (toString (List.length listingsList))]
--       , div []
--             [text (toString listingsList)]
--       ]
-- 
-- main : Signal Html
-- main = Signal.map view listingsMailbox.signal

-- port demo : Signal (Task Http.Error ())
-- port demo =
--   Debug.log "Trigger" getMailbox.signal 

-- sendToHatMailbox : Stuff -> Task Http.Error ()
-- sendToHatMailbox l =
--   Signal.send hatMailbox.address l
-- 
-- hatMailbox : Signal.Mailbox Stuff
-- hatMailbox =
--   Signal.mailbox { stuff = ["Init"]}
-- 
-- view : Stuff -> Html
-- view json_stuff =
--   let
--     ls = json_stuff.stuff
--     content = 
--       case ls of
--         [] -> text "Empty list sent to view"
--         l'::ls' -> text l'
--   in 
--     div []
--         [ button [onClick getMailbox.address makeGetRequest]
--                  [ text "Refresh page" ]
--         , div []
--               [ content ]
--         ]
-- 
-- main : Signal Html
-- main = Signal.map view hatMailbox.signal



-- port fetchListing : Task Http.Error ()
-- port fetchListing =
--   --Http.getString testUrl <| ((Debug.log "rawString") `Task.andThen` (\_ -> listingToMailbox initListing))
--   Http.get decode_listing_json testUrl `Task.andThen` listingToMailbox 
-- 
-- listingToMailbox : Listing -> Task Http.Error ()
-- listingToMailbox listing =
--   Signal.send listingMailbox.address listing
-- 
-- listingMailbox : Signal.Mailbox Listing
-- listingMailbox =
--   Signal.mailbox initListing
-- 
-- view : Listing -> Html
-- view listing = text listing.body
-- 
-- main : Signal Html
-- main = Signal.map (view << Debug.log "sig") listingMailbox.signal
