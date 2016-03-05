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

init : List Listing.Model -> Model
init listingsList = {view = ThumbnailView, searchfilter = [], listings = listingsList }

-- Update
type Action =
  ThumbnailAction (List String) CategoryBar.Category
    | FullpageAction Listing.UUID
    | ListingAction Listing.UUID Listing.Action

update : Action -> Model -> Model
update action model =
  let a = Debug.log "Action: " action in
  case action of
    ThumbnailAction searchFilter categoryFilter -> 
      { model | view = ThumbnailView
              , listings = List.map (filterListings searchFilter categoryFilter) model.listings
      }
    FullpageAction uuid -> 
      { model | view = FullpageView
              , listings = List.map (\listing -> if listing.key == uuid
                           then {listing | view = Listing.Fullpage}
                           else {listing | view = Listing.Hidden}
                          ) model.listings
      } 
    ListingAction uuid listing_action -> 
      { model | listings = List.map (\listing -> if listing.key == uuid
                                      then Listing.update listing_action listing
                                      else listing
                                    ) model.listings
      }

listingMatchQuery : FilterWords -> Listing.Model -> Bool
listingMatchQuery filter_words listing =
  if (filter_words == []) || (filter_words == [""]) then True
  else if List.foldl (\word tf -> (List.member word listing.query) && tf) True filter_words
       then True
       else False

listingMatchCategories : CategoryBar.Category -> Listing.Model -> Bool
listingMatchCategories category listing =
  if category == CategoryBar.None then True
  else if List.member (toString category |> toLower) listing.categories then True
       else False 

filterListings : FilterWords -> CategoryBar.Category -> Listing.Model -> Listing.Model
filterListings filter_words category listing =
  if (listingMatchQuery filter_words listing) && (listingMatchCategories category listing)
  then {listing | view = Listing.Thumbnail}
  else {listing | view = Listing.Hidden}

-- View
type alias Context =
  { listingsAction : Address Action 
  , thumbnailAction : Address ()
  }

view : Context -> Model -> Html
view context model =
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
              , List.foldr (makeTableRows context) [[]] filtered_listings
                 |> List.map row_div
            )
        FullpageView -> ( [ style fullpage_container_css
                          , id "fullpage-container"]
                        , List.map (view_listing context) model.listings
                        )
  in
    div container_css listings_content

view_listing : Context -> Listing.Model -> Html
view_listing context listing =
  let 
    listing_context = Listing.Context 
             (forwardTo context.listingsAction (ListingAction listing.key))
             context.thumbnailAction
             (forwardTo context.listingsAction (always (FullpageAction listing.key)))
  in
    Listing.view listing_context listing

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

makeTableRows : Context -> Listing.Model -> List (List Html) -> List (List Html)
makeTableRows context listing acc =
  let
    new_listing_html = view_listing context listing
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
