module Listing where

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import List exposing (map)
import Window
import String exposing (..)
import ImageViewer exposing (Photo, Photos)
import Signal exposing (..)
import StartApp.Simple as SA
import Html.Events exposing (..)
import HttpGetter

-- Model
type alias UUID = String
type alias Category = String
type alias Categories = List Category
type alias Price = Float
type View =
  Thumbnail
    | Fullpage
    | Hidden
type alias Model = { key : UUID
                   , title : String
                   , body : String
                   , price : Price
                   , categories : Categories
                   , approved : Bool
                   , sold : Bool
                   , lastUpdated : String
                   , photos : Photos
                   , view : View }

init : Photos -> HttpGetter.Listing -> Model
init p listing =
  { key = listing.key
  , title = listing.title
  , body = listing.body
  , price = listing.price
  , categories = listing.categories
  , approved = listing.approved
  , sold = listing.sold
  , lastUpdated = listing.lastUpdated
  , photos = p
  , view = Thumbnail }

-- Update
type Action =
  ImageActions ImageViewer.Action

update : Action -> Model -> Model
update action listing =
  case action of
    ImageActions image_action -> { listing | photos = ImageViewer.update image_action listing.photos }

-- View
type alias Context =
  { actions : Address Action
  , thumbnail : Address ()
  , fullpage : Address () 
  }

view : Int -> Context -> Model -> Html
view w context listing =
  let 
      div_css = case listing.view of
                  Thumbnail -> thumbnail_css w listing
                  Fullpage -> fullpage_css w listing
                  Hidden -> hidden_css
  in
    div 
      [ div_css.container ]
      [ div [ onClick context.fullpage ()
            , div_css.container_clicker 
            ]
            []
      , div [ onClick context.thumbnail () 
            , div_css.back
            ] 
            [text "Back"]
      , div [ div_css.photos ]
            [ ImageViewer.view (w//2) (Signal.forwardTo context.actions ImageActions) listing.photos ]
      , h2 [ div_css.title ] 
           [ text listing.title ]
      , div [ div_css.price ] 
            [ toString listing.price |> cons '$' |> text ]
      , div [ div_css.categories ]
            (categoryList listing.categories)
      , div [ div_css.body ]
            [ text listing.body ]
      ]

-- CSS
(=>) = (,)

toPixel : number -> String
toPixel x = (toString x) ++ "px"

category_tag_css : List (String, String)
category_tag_css =
  [ "border-radius" => "8px"
  , "background-color" => "#777"
  , "font-size" => "100%"
  , "color" => "#fff"
  , "line-height" => "1.3"
  , "text-align" => "center"
  , "display" => "inline-block"
  , "padding" => "5px 5px"
  , "margin" => "2px 4px"
  ]

hidden_div : List (String, String)
hidden_div =
  ["display" => "none" ]

-- Thumbnail CSS
thumbnail_categories_css : List (String, String)
thumbnail_categories_css =
  [ "overflow" => "auto"
  , "margin-left" => "10px"
  , "margin-bottom" => "10px"
  , "word-break" => "break-word" 
  , "text-align" => "left"
  ]

thumbnail_div_css : Int -> List (String, String)
thumbnail_div_css w =
    [ "display" => "inline-block"
    , "height" => "100%"
    , "width" => toPixel w
    , "border" => "1px solid #ddd"
    , "border-radius" => "5px"
    , "margin-bottom" => "10px"
    , "margin-left" => "5px"
    , "margin-right" => "5px"
    , "vertical-align" => "top"
    , "background-color" => "#fff"
    , "position" => "relative"
    ]

thumbnail_img_css : Int -> Photos -> List (String, String) 
thumbnail_img_css w photos =
  [ 
   "width" => "100%"
  , "border-radius" => "5px 5px 0px 0px"
  ]

thumbnail_title_css : List (String, String)
thumbnail_title_css =
  [ "text-align" => "center"
  , "margin" => "10px" 
  , "font-weight" => "400"
  ]

thumbnail_price_css : List (String, String)
thumbnail_price_css =
  [ "display" => "inline"
  , "color" => "green"
  , "float" => "right"
  , "margin-top" => "7px"
  , "margin-bottom" => "10px"
  , "margin-right" => "10px"
  , "margin-left" => "10px"
  , "font-weight" => "400"
  ]

thumbnailImg : Photos -> String
thumbnailImg photos =
  case photos of
    [] -> "url(http://www.oceanofweb.com/wp-content/themes/OOW/images/default-thumb.gif)"
    p::photoss -> "url(" ++ (p.small) ++ ")"

thumbnail_clicker_css : Int -> List (String, String)
thumbnail_clicker_css w =
  [ "position" => "absolute"
  ,  "width" => "100%"
  , "height" => "100%"
  , "opacity" => "0"
  ]

-- Fullpage CSS
fullpage_div_css : Int -> List (String, String)
fullpage_div_css w =
  [ "width" => toPixel w 
  , "padding" => "20px"
  , "border" => "1px solid"
  ]

fullpage_title_css : List (String, String)
fullpage_title_css =
  [ "text-align" => "center"
  ]

fullpage_price_css : List (String, String)
fullpage_price_css = 
  [ "display" => "inline"
  , "color" => "green"
  , "float" => "right"
  , "margin-bottom" => "10px"
  , "margin-right" => "20px"
  , "margin-left" => "10px"
  , "font-weight" => "700"
  ]

fullpage_img_css : Int -> Photos -> List (String, String)
fullpage_img_css w photos =
  [ "border" => "2px solid"
  , "width" => toPixel (w//2)
  , "height" => toPixel (w//2)
  , "margin" => "auto"
  ]

fullpage_categories_css : List (String, String)
fullpage_categories_css =
  [ "margin-left" => "20px"
  ]

fullpage_body_css : List (String, String)
fullpage_body_css =
  [ "margin" => "20px 20px"

  ]

fullpage_back_css : List (String, String)
fullpage_back_css =
  [ "height" => "10px"
  , "width" => "100%"
  , "border" => "1px dotted"
  ]


-- Records for CSS for each view type
type alias Listing_CSS = 
  { container : Attribute
  , title : Attribute
  , price : Attribute
  , photos : Attribute
  , categories : Attribute
  , body : Attribute
  , back : Attribute
  , container_clicker : Attribute
  }

thumbnail_css : Int -> Model -> Listing_CSS
thumbnail_css w listing =
  { container = style (thumbnail_div_css w)
  , title = style thumbnail_title_css
  , price = style thumbnail_price_css
  , photos = style (thumbnail_img_css w listing.photos)
  , categories = style thumbnail_categories_css
  , body = style hidden_div 
  , back = style hidden_div
  , container_clicker = style (thumbnail_clicker_css w)
  }

fullpage_css : Int -> Model -> Listing_CSS
fullpage_css w listing =
  { container = style (fullpage_div_css w)
  , title = style fullpage_title_css
  , price = style fullpage_price_css
  , photos = style (fullpage_img_css w listing.photos)
  , categories = style fullpage_categories_css
  , body = style fullpage_body_css 
  , back = style fullpage_back_css
  , container_clicker = style hidden_div
  }

hidden_css : Listing_CSS
hidden_css =
  { container = style hidden_div
  , title = style hidden_div
  , price = style hidden_div
  , photos = style hidden_div
  , categories = style hidden_div
  , body = style hidden_div
  , back = style hidden_div
  , container_clicker = style hidden_div
  }


-- Categories -> List of li of category names
oneCategory : Category -> Html
oneCategory category =
  span [ style category_tag_css ]
       [ text category ]

categoryList : Categories -> List Html
categoryList categories =
  List.map (oneCategory) categories
