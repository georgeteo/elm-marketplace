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
-- TODO: Add other action types for Search and Category filters here. 

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    ListingsAction listings_action -> ({ model | listings = Listings.update listings_action model.listings }
                                      , Effects.none)
    HttpAction maybeBlob -> (Maybe.withDefault HttpGetter.init maybeBlob
                              |> blobToListings Images.testImages
                              |> (\a -> { model | listings = a })
                            , Effects.none)
    HeaderAction header_action -> ( { model | meta = Header.update header_action model.meta }
                                  , Effects.none ) 
    SearchEnter _ -> let
                       filter_words = String.words model.meta.search
                     in
                       ({ model | listings = Listings.update (Listings.FilterAction filter_words) model.listings }
                        , Effects.none)

-- View
(=>) = (,)

view : (Int, Int) -> Address Action -> Model -> Html
view (w,h) address model =
  let
    sidebars = 0.05 * toFloat w
    sidebar = sidebars / 2
    content = toFloat w - sidebars
    header_context = Header.Context (forwardTo address HeaderAction)
                                    (forwardTo address SearchEnter)
  in
  div [ style [ "background-color" => "#f5f5f5"
              , "font-family" => "sans-serif"]]
      [ Header.view (w,100)
                    header_context
                    model.meta
      , Listings.view (floor sidebar, floor content)
                      (forwardTo address ListingsAction)
                      model.listings
      ]

-- Effects
getListings : String -> Effects Action
getListings url =
  HttpGetter.getListings url
   |> Task.map HttpAction
   |> Effects.task

-- Test
blobToListings : List (ImageViewer.Photos) -> HttpGetter.Blob -> Listings.Model
blobToListings photosList blob =
  let blobListings = blob.listings in
  List.map2 Listing.init photosList blobListings |> Listings.init

testUrl = "http://go-marketplace.appspot.com/listings"
