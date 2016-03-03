module Index where

import Html exposing (..)
import Html.Attributes exposing (..)
import Window
import Header
import Listings
import Listing
import Basics exposing (floor)
import Signal exposing (..)
import Images exposing (testImages)
import Effects exposing (Effects)
import HttpGetter
import Images
import ImageViewer
import Task
import String

-- Model

-- TODO: expand Model to account for search and category filters
type alias SearchFilters = String

type alias Model =
  { listings : Listings.Model
  , meta : Header.Meta
  }

init : (Model, Effects Action)
init =
  ({ listings = Listings.init []
   , meta = Header.init }
  , getListings testUrl)

-- Update
type Action =
  ListingsAction Listings.Action
  | HttpAction (Maybe HttpGetter.Blob)
  | HeaderAction Header.Action
  | SearchEnter ()
  | CategoryAction Header.Action
  | Scroll Bool

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    ListingsAction listings_action -> ({ model | listings = Listings.update listings_action model.listings }
                                      , Effects.none)
    HttpAction maybeBlob -> (Maybe.withDefault HttpGetter.init maybeBlob
                              |> blobToListings Images.testImages
                              |> (\new_listings -> { model | listings = appendListings model.listings new_listings })
                            , Effects.none)
    HeaderAction header_action -> ( { model | meta = Header.update header_action model.meta }
                                  , Effects.none ) 
    SearchEnter _ -> let
                       filter_words = String.words model.meta.search
                     in
                       ({ model | listings = Listings.update (Listings.FilterAction filter_words) model.listings }
                        , Effects.none)
    CategoryAction header_action -> let
                                      meta' = Header.update header_action model.meta
                                      listings' = (Listings.update (Listings.CategoryFilter meta'.category) model.listings)
                                    in
                                      ( {model | meta = meta', listings = listings' }, Effects.none)
    Scroll b -> if (b == True) && (model.listings.view == Listings.ThumbnailView) 
                then (model, getListings testUrl)
                else (model, Effects.none)

appendListings : Listings.Model -> List Listing.Model -> Listings.Model
appendListings old_listings new_listings =
  {old_listings | listings = List.append old_listings.listings new_listings }

-- View
(=>) = (,)

view : Address Action -> Model -> Html
view address model =
  let
    header_context = Header.Context (forwardTo address HeaderAction)
                                    (forwardTo address SearchEnter)
                                    (forwardTo address CategoryAction)
  in
  div [ style [ "background-color" => "#f5f5f5"
              , "font-family" => "sans-serif"]]
      [ Header.view header_context
                    model.meta
      , Listings.view (forwardTo address ListingsAction)
                      model.listings
      ]

-- Effects

getListings : String -> Effects Action
getListings url =
  HttpGetter.getListings url
   |> Task.map HttpAction
   |> Effects.task

-- Test
blobToListings : List (ImageViewer.Photos) -> HttpGetter.Blob -> List Listing.Model
blobToListings photosList blob =
  let blobListings = blob.listings in
  List.map2 Listing.init photosList blobListings 

testUrl = "http://go-marketplace.appspot.com/listings"
