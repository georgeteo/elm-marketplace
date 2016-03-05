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
import CategoryBar

-- Model

type alias SearchFilters = String

type alias Meta =
  { searchFilter : List String
  , categoryFilter : CategoryBar.Category
  }

metaInit : Meta
metaInit =
  { searchFilter = []
  , categoryFilter = CategoryBar.None
  }

type alias Model =
  { listings : Listings.Model
  , header : Header.Model
  , meta : Meta
  }

init : (Model, Effects Action)
init =
  ({ listings = Listings.init []
   , header = Header.init 
   , meta = metaInit }
  , getListings testUrl)

-- Update
type Action =
  HttpAction (Maybe HttpGetter.Blob) -- GET HTTP response
    | Scroll Bool -- Scroll information for JS port
    | ListingsAction (Listings.Action) -- Internal Listings Actions: view and image viewer changes
    | HeaderAction Header.Action -- Internal Header Actions: search input or category hover
    | ThumbnailAction () -- Rendering view based on filters
    | SearchEnter (List String) -- Search query with list of query words
    | CategoryEnter CategoryBar.Category -- Category query with a category
    | Reset () -- Reset action to all listings and no filter settings

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    HttpAction maybeBlob -> 
      (Maybe.withDefault HttpGetter.init maybeBlob
        |> blobToListings Images.testImages
        |> (\new_listings -> { model | listings = appendListings model.listings new_listings })
      , Effects.none)
    Scroll b -> 
      if (b == True) && (model.listings.view == Listings.ThumbnailView) 
      then (model, getListings testUrl)
      else (model, Effects.none)
    ListingsAction listings_action -> 
      ({ model | listings = Listings.update listings_action model.listings }
      , Effects.none)
    HeaderAction header_action -> 
      ( { model | header = Header.update header_action model.header }
      , Effects.none ) 
    SearchEnter filter_words ->
      let 
        meta' =  {searchFilter = filter_words, categoryFilter = model.meta.categoryFilter }
        listings' = Listings.update (Listings.ThumbnailAction meta'.searchFilter 
                                    meta'.categoryFilter) model.listings
      in
      ({model | listings = listings', meta = meta'}, Effects.none )
    CategoryEnter category -> 
      let
        header' = Header.update (Header.CategoryEnter category) model.header
        meta' = { searchFilter = model.meta.searchFilter, categoryFilter = (fst header'.category)}
        listings' = Listings.update (Listings.ThumbnailAction
                    meta'.searchFilter meta'.categoryFilter) model.listings
      in
        ({model | header = header', listings = listings', meta = meta'}, Effects.none)
    Reset _ -> 
      let
        meta' = {categoryFilter = CategoryBar.None
                            , searchFilter = []}
        listings' = Listings.update (Listings.ThumbnailAction
                      meta'.searchFilter meta'.categoryFilter) model.listings
        header' = Header.update Header.Reset model.header
      in
        ({model | meta = meta', listings = listings', header = header'}, Effects.none)
    ThumbnailAction _ -> -- Move up later
      ( { model | listings = Listings.update (Listings.ThumbnailAction
                  model.meta.searchFilter model.meta.categoryFilter) model.listings }
      , Effects.none )
    

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
                                    (forwardTo address CategoryEnter)
                                    (forwardTo address Reset)
    listings_context = Listings.Context (forwardTo address ListingsAction)
                                        (forwardTo address ThumbnailAction)
  in
    div [ style [ "background-color" => "#f5f5f5"
                , "font-family" => "sans-serif"]
        , id "index-root"]
      [ Header.view header_context model.header
      , Listings.view listings_context model.listings
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
