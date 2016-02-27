module Listings where

import Html exposing (..)
import Html.Attributes exposing (..)
import Listing
import Window
import List exposing (map, map2)
import Basics exposing (floor)
import Signal exposing (..)
import Listing


-- Model 
type View = 
  ThumbnailView
    | FullpageView

type alias FilterWords = List String

type alias Model = (View, FilterWords, List Listing.Model)

-- For the purposes for testing, init has been initalized with a sample listings.
-- Currently, HTTP.get is not working so I am unable to get the json from the server.
-- This is a temporary measure in o"rder to continue work.

init : List Listing.Model -> Model
init listingsList = (ThumbnailView, [], listingsList)

-- Update
type Action =
  ThumbnailAction
    | FullpageAction Listing.UUID
    | ListingAction Listing.UUID Listing.Action
    | FilterAction FilterWords

update : Action -> Model -> Model
update action (view, filter, listings) =
  case action of
    ThumbnailAction -> (ThumbnailView, filter, List.map (\listing -> {listing | view = Listing.Thumbnail }) listings)
    FullpageAction uuid -> (FullpageView, filter, List.map (\listing ->
                                                     if listing.key == uuid
                                                     then {listing | view = Listing.Fullpage}
                                                     else {listing | view = Listing.Hidden})
                                          listings)
    ListingAction uuid listing_action -> (view, filter, List.map (\listing -> if listing.key == uuid
                                                                      then Listing.update listing_action listing
                                                                      else listing)
                                                         listings)
    FilterAction filter_words -> (ThumbnailView, filter_words,
                                    List.map (\listing -> if listingMatchQuery filter_words listing
                                                          then {listing | view = Listing.Thumbnail}
                                                          else {listing | view = Listing.Hidden}) 
                                    listings)

listingMatchQuery : FilterWords -> Listing.Model -> Bool
listingMatchQuery filter_words listing =
  if filter_words == [] then True
  else if List.foldl (\word tf -> (List.member word listing.query) && tf) True filter_words
       then True
       else False

-- View
view : (Int, Int) -> Address Action -> Model -> Html
view (sidebar, content) address (view, filter_words, listings) =
  let
    content_w = case view of
                ThumbnailView -> floor ((toFloat(content) - (8*6)) / 4)
                FullpageView -> content
  in
    div [ style (listings_container_css sidebar) ]
        (List.map (view_listing content_w address) listings)

view_listing : Int -> Address Action -> Listing.Model -> Html
view_listing content_w address listing =
  let 
    context = Listing.Context 
             (forwardTo address (ListingAction listing.key))
             (forwardTo address (always (ThumbnailAction)))
             (forwardTo address (always (FullpageAction listing.key)))
  in
    Listing.view content_w context listing

  -- CSS
toPixel : number -> String
toPixel x = (toString x) ++ "px"

(=>) = (,)
listings_container_css : Int -> List (String, String)
listings_container_css sidebar_w =
  [ "margin-left" => toPixel sidebar_w
  , "margin-right" => toPixel sidebar_w
  , "font" => "400 Roboto, sans-serif"
  , "background-color" => "#f5f5f5"
  , "text-align" => "center"
  ]
