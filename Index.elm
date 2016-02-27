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

-- Model

-- TODO: expand Model to account for search and category filters
type alias Model =
  { listings : Listings.Model }

init : (Model, Effects Action)
init =
  ({ listings = Listings.init [] }
  , getListings testUrl)

-- Update
type Action =
  ListingsAction Listings.Action
  | HttpAction (Maybe HttpGetter.Blob)
-- TODO: Add other action types for Search and Category filters here. 

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    ListingsAction listings_action -> ({ listings = Listings.update listings_action model.listings }
                                      , Effects.none)
    HttpAction maybeBlob -> (Maybe.withDefault HttpGetter.init maybeBlob
                              |> blobToListings Images.testImages
                              |> (\a -> { listings = a })
                            , Effects.none)

-- View
(=>) = (,)

view : (Int, Int) -> Address Action -> Model -> Html
view (w,h) address model =
  let
    listings = model.listings
    sidebars = 0.05 * toFloat w
    sidebar = sidebars / 2
    content = toFloat w - sidebars
  in
  div [ style [ "background-color" => "#f5f5f5"
              , "font-family" => "sans-serif"]]
      [ Header.view (w,100)
      , Listings.view (floor sidebar, floor content)
                      (forwardTo address ListingsAction)
                      listings
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
