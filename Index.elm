module Index where

-- Module for Index.
-- This is the main module for the app.
-- Contains 4 components: Meta, Listings, Header, and Category.
-- Meta contains the meta information relavent to the whole application.
-- In particular, meta contains the searchFilter words, the active categoryFilter,
-- and the window dimensions.
-- These values are the "source of truth" to decide which listings to render.
-- Listings is of Listings type and contains all of the listings.
-- Header is of Header type and contains the header component
-- Category is the component for the CatgoryBar. 

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
import Html.Animation as UI
import Html.Animation.Properties exposing (..)
import Html.Events exposing (..)

-- Model

-- Meta contains the meta information relavent to the whole application.
-- In particular, meta contains the searchFilter words, the active categoryFilter,
-- and the window dimensions.
-- These values are the "source of truth" to decide which listings to render.
type alias Meta =
  { searchFilter : List String
  , categoryFilter : CategoryBar.Category
  , windowDim : (Int, Int)
  }

metaInit : Meta
metaInit =
  { searchFilter = []
  , categoryFilter = CategoryBar.None
  , windowDim = (0,0)
  }

-- This is the overall model for the application. 
-- It contains model objects for 4 components: listings, header (which contains
-- a model of the search object), category (for the categoryBar) and meta (as
-- explained above).
type alias Model =
  { listings : Listings.Model
  , header : Header.Model
  , category : CategoryBar.Model
  , meta : Meta
  }

init : (Model, Effects Action)
init =
  ({ listings = Listings.init []
   , header = Header.init
   , category = CategoryBar.init
   , meta = metaInit
   }
   , Effects.batch
      [ getListings testUrl
      , windowInit
      ]
  )

-- Update
-- Set of Actions for the overall application. 
-- Explanations for each action below.
type Action =
  HttpAction (Maybe HttpGetter.Blob) -- GET HTTP response
    | Scroll Bool -- Scroll information for JS port
    | ListingsAction (Listings.Action) -- Internal Listings Actions: view and image viewer changes
    | HeaderAction Header.Action -- Internal Header Actions: search input or category hover
    | ThumbnailAction () -- Rendering view based on filters
    | SearchEnter (List String) -- Search query with list of query words
    | CategoryHover CategoryBar.Action
    | CategoryEnter CategoryBar.Category -- Category query with a category
    | Reset () -- Reset action to all listings and no filter settings
    | Resize (Int, Int) -- Window resize action
    | NoOp
    | Animation CategoryBar.Action -- Animation object for the vertical categoryBar.

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
        metaModel = model.meta
        meta' =  { metaModel | searchFilter = filter_words }
        listings' = Listings.update (Listings.ThumbnailAction meta'.searchFilter
                                    meta'.categoryFilter) model.listings
      in
      ({model | listings = listings', meta = meta'}, Effects.none )
    CategoryHover category_action ->
      let
        (category', effects') = CategoryBar.update category_action model.category
      in
      ( {model | category = category'}, Effects.none )
    CategoryEnter category ->
      let
        (category', effects') = CategoryBar.update (CategoryBar.ToggleCategory category) model.category
        metaModel = model.meta
        meta' = { metaModel | categoryFilter = category'.on}
        listings' = Listings.update (Listings.ThumbnailAction
                    meta'.searchFilter meta'.categoryFilter) model.listings
      in
        ({model | category=category', listings = listings', meta = meta'}, Effects.none)
    Reset _ ->
      let
        metaModel = model.meta
        meta' = {metaModel | categoryFilter = CategoryBar.None , searchFilter = []}
        listings' = Listings.update (Listings.ThumbnailAction
                      meta'.searchFilter meta'.categoryFilter) model.listings
        header' = Header.update Header.Reset model.header
        (category', effects') = CategoryBar.update CategoryBar.Reset model.category
      in
        ( {model | meta = meta', listings = listings', header = header', category = category'}
        , Effects.none)
    ThumbnailAction _ -> -- Move up later
      ( { model | listings = Listings.update (Listings.ThumbnailAction
                  model.meta.searchFilter model.meta.categoryFilter) model.listings }
      , Effects.none )
    Resize dim ->
      let
        metaModel = model.meta
        meta' = Debug.log "New dimensions" {metaModel | windowDim = dim}
      in
        ( {model | meta = meta'}, Effects.none )
    NoOp -> (model, Effects.none)
    Animation animation ->
      let
        (category', effects') = CategoryBar.update animation model.category
      in
        ({model | category = category'}, Effects.map Animation effects')


-- Helper functions to add new listings (from an HTTP GET request) to the back
-- of the listings object. 
appendListings : Listings.Model -> List Listing.Model -> Listings.Model 
appendListings old_listings new_listings =
  {old_listings | listings = List.append old_listings.listings new_listings }

-- View
(=>) = (,)

-- Renders the overall view.
-- The view consists of 3 independently rendered components: 
-- CategoryBar, Header, Listings. 
view : Address Action -> Model -> Html
view address model =
  let
    w = fst model.meta.windowDim
    one_col_limit = 640
    two_col_limit = 940
    three_col_limit = 1250
    (col_limit, col_percent) = if w < one_col_limit then (1, 100)
                               else if w < two_col_limit then (2, 50)
                               else if w < three_col_limit then (3, 33)
                               else (4, 25)
    header_context = Header.Context (forwardTo address HeaderAction)
                                    (forwardTo address SearchEnter)
                                    (forwardTo address Reset)
    listings_context = Listings.Context (forwardTo address ListingsAction)
                                        (forwardTo address ThumbnailAction) 
    category_context = CategoryBar.Context (forwardTo address CategoryHover)
                                           (forwardTo address CategoryEnter)
                                           (forwardTo address Animation)
  in
    div [ style [ "background-color" => "#f5f5f5"
                , "font-family" => "sans-serif"]
        , id "index-root"]
      [ CategoryBar.view col_limit category_context model.category
      ,  Header.view (col_limit, col_percent) header_context model.header
      , Listings.view (col_limit, col_percent) listings_context model.listings
      ]

-- Effects
-- Section for managing Effects. 
-- There are two effects here: 
-- getListing for making HTTP GET requests Signal
-- windowInit which initializes the Window Signal
-- There is an additional Effect for the UI animation in the CategoryBar.
-- Effects are triggered as a side effect in update. 
getListings : String -> Effects Action
getListings url =
  HttpGetter.getListings url
   |> Task.map HttpAction
   |> Effects.task

resizes : Signal Action
resizes = Signal.map Resize Window.dimensions

startMailbox : Signal.Mailbox ()
startMailbox = Signal.mailbox ()

firstResize : Signal Action
firstResize = Signal.sampleOn startMailbox.signal resizes

windowInit : Effects Action
windowInit =
  Signal.send startMailbox.address ()
    |> Task.map (always NoOp)
    |> Effects.task

-- Test
-- Code that merges incoming HTTP GET Blobs from with the test images. 
blobToListings : List (ImageViewer.Photos) -> HttpGetter.Blob -> List Listing.Model
blobToListings photosList blob =
  let blobListings = blob.listings in
  List.map2 Listing.init photosList blobListings

testUrl = "http://go-marketplace.appspot.com/listings"
