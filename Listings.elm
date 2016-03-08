module Listings where

-- Module for the set of listings. 

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

-- Model of Listings type has two fields:
-- view is of View type and indicates which type of view is being rendered.
-- listings is a List of individual Listing. 
type alias Model =
  { view : View
  , listings : List Listing.Model
  }

init : List Listing.Model -> Model
init listingsList = {view = ThumbnailView, listings = listingsList }

-- Update
-- Three types of Action:
-- ThumbnailAction FilterWords Category will render the ThumbnailView with
-- FilterWords as the search filter terms and Category as the category filter.
-- FullpageAction will render the Listing in a FullpageView with all other Listings
-- turned to Hidden.
-- ListingAction are wrapper actions to pass the update to an individual listing.
-- ListingAction currently corresponds to a ImageViewer updates. 
type Action =
  ThumbnailAction (List String) CategoryBar.Category
    | FullpageAction Listing.UUID
    | ListingAction Listing.UUID Listing.Action

update : Action -> Model -> Model
update action model =
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

-- Helper function that returns a Bool if a Listing matches the filterWords. 
listingMatchQuery : FilterWords -> Listing.Model -> Bool
listingMatchQuery filter_words listing =
  if (filter_words == []) || (filter_words == [""]) then True
  else if List.foldl (\word tf -> (List.member word listing.query) && tf) True filter_words
       then True
       else False

-- Helepr function for checking whether a Listing matches the Category filter
listingMatchCategories : CategoryBar.Category -> Listing.Model -> Bool
listingMatchCategories category listing =
  if category == CategoryBar.None then True
  else if List.member (toString category |> toLower) listing.categories then True
       else False 

-- Wrapper filter function that filters based on both FilterWords and Category
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

-- View is rendered based on the current view type (ThumbnailView or FullPageView).
-- View is also rendered based on col_limits, which is responsive based on the 
-- viewport width. 
view : (Int, Int) -> Context -> Model -> Html
view (col_limit, col_percent) context model =
  let
    (container_css, listings_content) =
      case model.view of
        ThumbnailView -> 
          let 
            filtered_listings = List.filter(\l -> l.view == Listing.Thumbnail) model.listings 
            number_of_listings = List.length filtered_listings
            num_cols = if number_of_listings < col_limit
                                then [("width", (toString (number_of_listings * col_percent)) ++ "%")]
                                else []
          in
            ([ style (List.append listings_container_css num_cols )
              , id "thumbnail-container"]
              , List.foldl (makeTableRows (col_limit, col_percent) context) [[]] filtered_listings
                 |> List.reverse
                 |> List.map row_div
            )
        FullpageView -> ( [ style fullpage_container_css
                          , id "fullpage-container"]
                        , List.map (view_listing 100 context) model.listings
                        )
  in
    div container_css listings_content

-- Helper function for rending a single listing
view_listing : Int -> Context -> Listing.Model -> Html
view_listing col_percent context listing =
  let 
    listing_context = Listing.Context 
             (forwardTo context.listingsAction (ListingAction listing.key))
             context.thumbnailAction
             (forwardTo context.listingsAction (always (FullpageAction listing.key)))
  in
    Listing.view col_percent listing_context listing

  -- CSS
toPixel : number -> String
toPixel x = (toString x) ++ "px"

(=>) = (,)
listings_container_css : List (String, String)
listings_container_css =
  [ "display" => "table"
  , "border-collapse" => "separate"
  , "border-spacing" => "10px 11px"
  , "margin" => "0 10%"
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

makeTableRows : (Int, Int) -> Context -> Listing.Model -> List (List Html) -> List (List Html)
makeTableRows (col_limit, col_percent) context listing acc =
  let
    new_listing_html = view_listing col_percent context listing
    (acc_head, accs) = case acc of
                        [] -> Debug.crash "Oh no! Acc was not initialized correctly in foldr"
                        x::xs -> (x, xs)
    new_head = if List.length acc_head == col_limit then [[new_listing_html], acc_head]
                else [new_listing_html :: acc_head]
  in
    List.append new_head accs

fullpage_container_css : List (String, String)
fullpage_container_css = 
  [ "margin" => "0 10%"
  ]
