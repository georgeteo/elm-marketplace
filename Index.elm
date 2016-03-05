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
import Html.Animation as UI
import Html.Animation.Properties exposing (..)
import Html.Events exposing (..)

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
  , category : CategoryBar.Model
  , meta : Meta
  , style : UI.Animation
  }

init : (Model, Effects Action)
init =
  ({ listings = Listings.init []
   , header = Header.init
   , category = CategoryBar.init
   , meta = metaInit
   , style = UI.init [ Left -350.0 Px
                     , Opacity 0.0
                     ]
   }
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
    | CategoryHover CategoryBar.Action
    | CategoryEnter CategoryBar.Category -- Category query with a category
    | Reset () -- Reset action to all listings and no filter settings
    | Resize (Int, Int)
    | NoOp
    | Show
    | Hide
    | Animate UI.Action

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
      ( {model | category = CategoryBar.update category_action model.category}
      , Effects.none)
    CategoryEnter category ->
      let
        category' = CategoryBar.update (CategoryBar.ToggleCategory category) model.category
        metaModel = model.meta
        meta' = { metaModel | categoryFilter = (fst category')}
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
        category' = CategoryBar.update CategoryBar.Reset model.category
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
    Show ->
      UI.animate
        |> UI.props
          [ Left (UI.to 0) Px
          , Opacity (UI.to 1)
          ]
        |> onMenu model
    Hide ->
      UI.animate
        |> UI.props
          [ Left (UI.to -350) Px
          , Opacity (UI.to 0)
          ]
        |> onMenu model
    Animate action ->
      onMenu model action


appendListings : Listings.Model -> List Listing.Model -> Listings.Model 
appendListings old_listings new_listings =
  {old_listings | listings = List.append old_listings.listings new_listings }

onMenu =
  UI.forwardTo
    Animate
    .style
    (\w style -> {w | style = style })

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
                                    (forwardTo address Reset)
    listings_context = Listings.Context (forwardTo address ListingsAction)
                                        (forwardTo address ThumbnailAction) 
    category_context = CategoryBar.Context (forwardTo address CategoryHover)
                                           (forwardTo address CategoryEnter)
    triggerStyle = [ ("position", "absolute")
                    , ("left", "0px")
                    , ("top", "0px")
                    , ("width", "350px")
                    , ("height", "50%")
                    --, ("background-color", "#AAA")
                    , ("border", "2px dashed #AAA")
                    ]
  in
    div [ style [ "background-color" => "#f5f5f5"
                , "font-family" => "sans-serif"]
        , id "index-root"]
      [ CategoryBar.view category_context model.category
      ,  Header.view (col_limit, col_percent) header_context model.header
      , div [ onMouseEnter address Show
            , onMouseLeave address Hide
            , style triggerStyle
            ]
            [ h1 [ style [("padding","25px")]]
                 [ text "Hover here to see menu!"]
            , viewMenu address model
            ]
      , Listings.view (col_limit, col_percent) listings_context model.listings
      ]
viewMenu : Address Action -> Model -> Html
viewMenu address model =
  let
    menuStyle = [ ("position", "absolute")
                , ("top", "-2px")
                , ("margin-left", "-2px")
                , ("padding", "25px")
                , ("width", "300px")
                , ("height", "100%")
                , ("background-color", "rgb(58,40,69)")
                , ("color", "white")
                , ("border", "2px solid rgb(58,40,69)")
                ]
  in
    div [ style (menuStyle ++ (UI.render model.style)) ]
        [ h1 [] [ text "Hidden Menu"]
            , ul []
            [li [] [text "Some things"]
            , li [] [text "in a list"]
            ]
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
