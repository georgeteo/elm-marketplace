module Listings where

import Html exposing (..)
import Html.Attributes exposing (..)
import Listing
import Window
import List exposing (map, map2)
import Basics exposing (floor)
import Signal exposing (..)
import Listing
import CategoryBar
import String exposing (toLower)


-- Model 
type View = 
  ThumbnailView
    | FullpageView

type alias FilterWords = List String

type alias Model =
  { view : View
  , searchfilter : FilterWords
  , listings : List Listing.Model
  }

-- For the purposes for testing, init has been initalized with a sample listings.
-- Currently, HTTP.get is not working so I am unable to get the json from the server.
-- This is a temporary measure in o"rder to continue work.

init : List Listing.Model -> Model
init listingsList = {view = ThumbnailView, searchfilter = [], listings = listingsList }

-- Update
type Action =
  ThumbnailAction
    | FullpageAction Listing.UUID
    | ListingAction Listing.UUID Listing.Action
    | FilterAction FilterWords
    | CategoryFilter  CategoryBar.Model

update : Action -> Model -> Model
update action model =
  case action of
    ThumbnailAction -> { model | view = ThumbnailView
                       , listings = List.map (\listing -> {listing | view = Listing.Thumbnail }) model.listings
                       }
    FullpageAction uuid -> { model | view = FullpageView
                                   , listings = List.map (\listing -> if listing.key == uuid
                                                                      then {listing | view = Listing.Fullpage}
                                                                      else {listing | view = Listing.Hidden}
                                                         ) model.listings
                           }
    ListingAction uuid listing_action -> { model | listings = List.map
                                                              (\listing -> if listing.key == uuid
                                                                           then Listing.update listing_action listing
                                                                           else listing
                                                              ) model.listings
                                         }
    FilterAction filter_words -> { model | view = ThumbnailView
                                         , listings = List.map (\listing -> if listingMatchQuery filter_words listing
                                                                            then {listing | view = Listing.Thumbnail}
                                                                            else {listing | view = Listing.Hidden}
                                                               ) model.listings
                                 }
    CategoryFilter category -> {model | view = ThumbnailView
                                      , listings = List.map (\listing -> if listingMatchCategories category listing
                                                                        then {listing | view = Listing.Thumbnail}
                                                                        else {listing | view = Listing.Hidden}
                                                               ) model.listings
                                   }

listingMatchQuery : FilterWords -> Listing.Model -> Bool
listingMatchQuery filter_words listing =
  if filter_words == [] then True
  else if List.foldl (\word tf -> (List.member word listing.query) && tf) True filter_words
       then True
       else False

listingMatchCategories : CategoryBar.Model -> Listing.Model -> Bool
listingMatchCategories (category, _) listing =
  if category == CategoryBar.None then True
  else if List.member (toString category |> toLower) listing.categories then True
       else False 


-- View
view : (Int, Int) -> Address Action -> Model -> Html
view (sidebar, content) address model =
  let
    content_w = case model.view of
                  ThumbnailView -> floor ((toFloat(content) - (8*6)) / 4)
                  FullpageView -> content
  in
    div [ style (listings_container_css sidebar) ]
        (List.map (view_listing content_w address) model.listings)

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
