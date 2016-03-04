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
    | ViewAction View

update : Action -> Model -> Model
update action model =
  let a = Debug.log "Action: " action in
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
                                         , listings = if filter_words == [""] then List.map (\l -> {l | view = Listing.Thumbnail}) model.listings
                                                      else List.map (\listing -> if listingMatchQuery filter_words listing
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
    ViewAction new_view -> {model | view = new_view 
                                  , listings = List.map (\l -> {l | view = Listing.Thumbnail}) model.listings
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
view : Address Action -> Model -> Html
view address model =
  let
    debug = Debug.log "View type" model.view 
    (container_css, listings_content) =
      case model.view of
        ThumbnailView -> 
          let 
            filtered_listings = List.filter(\l -> l.view == Listing.Thumbnail) model.listings 
            number_of_listings = List.length filtered_listings
            one_listing_hack = if number_of_listings < 4
                                then [("width", (toString (number_of_listings * 25)) ++ "%")]
                                else []
          in
            ([ style (List.append listings_container_css one_listing_hack )
              , id "thumbnail-container"]
              , List.foldr (makeTableRows address) [[]] filtered_listings
                 |> List.map row_div
            )
        FullpageView -> ( [ style fullpage_container_css
                          , id "fullpage-container"]
                        , List.map (view_listing address) model.listings
                        )
  in
    div container_css listings_content

view_listing : Address Action -> Listing.Model -> Html
view_listing address listing =
  let 
    context = Listing.Context 
             (forwardTo address (ListingAction listing.key))
             (forwardTo address (always (ThumbnailAction)))
             (forwardTo address (always (FullpageAction listing.key)))
  in
    Listing.view context listing

  -- CSS
toPixel : number -> String
toPixel x = (toString x) ++ "px"

(=>) = (,)
listings_container_css : List (String, String)
listings_container_css =
  [ "display" => "table"
  , "border-collapse" => "separate"
  , "border-spacing" => "5px 5px"
  , "margin" => "0 5%"
  , "background-color" => "#f5f5f5"
  , "text-align" => "center"
  ]

listings_row_css : List (String, String)
listings_row_css =
  [ "display" => "table-row" 
  ]

row_div : List Html -> Html
row_div cols =
  div [ style listings_row_css ]
      cols

makeTableRows : Address Action -> Listing.Model -> List (List Html) -> List (List Html)
makeTableRows address listing acc =
  let
    new_listing_html = view_listing address listing
    (acc_head, accs) = case acc of
                        [] -> Debug.crash "Oh no! Acc was not initialized correctly in foldr"
                        x::xs -> (x, xs)
    new_head = if List.length acc_head == 4 then [[new_listing_html], acc_head]
                else [new_listing_html :: acc_head]
  in
    List.append new_head accs

fullpage_container_css : List (String, String)
fullpage_container_css = 
  [ "margin" => "0 10%"
  ]
