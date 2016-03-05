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
  , windowDim : (Int, Int)
  }

metaInit : Meta
metaInit =
  { searchFilter = []
  , categoryFilter = CategoryBar.None
  , windowDim = (0,0)
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
  , Effects.batch
      [ getListings testUrl
      , windowInit
      ]
  )
  
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
    | Resize (Int, Int)
    | NoOp

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
    CategoryEnter category -> 
      let
        header' = Header.update (Header.CategoryEnter category) model.header
        metaModel = model.meta
        meta' = { metaModel | categoryFilter = (fst header'.category)}
        listings' = Listings.update (Listings.ThumbnailAction
                    meta'.searchFilter meta'.categoryFilter) model.listings
      in
        ({model | header = header', listings = listings', meta = meta'}, Effects.none)
    Reset _ -> 
      let
        metaModel = model.meta
        meta' = {metaModel | categoryFilter = CategoryBar.None , searchFilter = []}
        listings' = Listings.update (Listings.ThumbnailAction
                      meta'.searchFilter meta'.categoryFilter) model.listings
        header' = Header.update Header.Reset model.header
      in
        ({model | meta = meta', listings = listings', header = header'}, Effects.none)
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
    

appendListings : Listings.Model -> List Listing.Model -> Listings.Model
appendListings old_listings new_listings =
  {old_listings | listings = List.append old_listings.listings new_listings }

-- View
(=>) = (,)

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
                                    (forwardTo address CategoryEnter)
                                    (forwardTo address Reset)
    listings_context = Listings.Context (forwardTo address ListingsAction)
                                        (forwardTo address ThumbnailAction)
  in
    div [ style [ "background-color" => "#f5f5f5"
                , "font-family" => "sans-serif"]
        , id "index-root"]
      [ Header.view (col_limit, col_percent) header_context model.header
      , Listings.view (col_limit, col_percent) listings_context model.listings
      ]

-- Effects

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
blobToListings : List (ImageViewer.Photos) -> HttpGetter.Blob -> List Listing.Model
blobToListings photosList blob =
  let blobListings = blob.listings in
  List.map2 Listing.init photosList blobListings 

testUrl = "http://go-marketplace.appspot.com/listings"
