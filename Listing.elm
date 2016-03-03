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
import String

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
                   , view : View
                   , query : List String }

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
  , view = Thumbnail
  , query = (String.words listing.body) ++ (String.words listing.title)}

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
(=>) = (,)

view : Context -> Model -> Html
view context listing =
  let 
      (div_css, button) = 
        case listing.view of
          Thumbnail -> (thumbnail_css listing, thumbnail_button_view context)
          Fullpage -> (fullpage_css listing, fullpage_button_view context)
          Hidden -> (hidden_css, thumbnail_button_view context)
  in
    div [  div_css.container ]
        [ div [ div_css.inner_container
              ]
              [ button
              , div [ div_css.photos ]
                    [ ImageViewer.view (Signal.forwardTo context.actions ImageActions) listing.photos ]
              , h2 [ div_css.title ] 
                   [ text listing.title ]
              , div [ div_css.price ] 
                    [ toString listing.price |> cons '$' |> text ]
              , div [ div_css.categories ]
                    (categoryList listing.categories)
              , div [ div_css.body ]
                    [ text listing.body ]
              ]
        ]

thumbnail_button_view : Context -> Html
thumbnail_button_view context =
  div [ style thumbnail_button 
      , onClick context.fullpage () ]
      []

fullpage_button_view : Context -> Html
fullpage_button_view context =
  button [ style fullpage_button 
      , onClick context.thumbnail () ]
      [ text "Back" ]

-- CSS

-- Records for CSS for each view type
type alias Listing_CSS = 
  { container : Attribute
  , title : Attribute
  , price : Attribute
  , photos : Attribute
  , categories : Attribute
  , body : Attribute
  , button : Attribute
  , inner_container : Attribute
  }


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
thumbnail_css : Model -> Listing_CSS
thumbnail_css listing =
  { container = style thumbnail_container
  , inner_container = style thumbnail_inner_container
  , button = style thumbnail_button
  , title = style thumbnail_title_css
  , price = style thumbnail_price_css
  , photos = style thumbnail_img_css
  , categories = style thumbnail_categories_css
  , body = style hidden_div
  }

thumbnail_container : List (String, String)
thumbnail_container =
  [ "display" => "table-cell"
  , "width" => "25%"
  , "padding" => "5px"
  ]

thumbnail_inner_container : List (String, String)
thumbnail_inner_container =
  ["position" => "relative"
  , "border" => "1px solid #ddd"
  , "overflow" => "auto"
  , "height" => "100%"
  , "background-color" => "#fff"
  , "border-radius" => "5px 5px 0px 0px"
  ]

thumbnail_button : List (String, String)
thumbnail_button =
  [ "position" => "absolute"
  , "height" => "100%"
  , "width" => "100%"
  ]

thumbnail_categories_css : List (String, String)
thumbnail_categories_css =
  [ "overflow" => "auto"
  , "margin-left" => "10px"
  , "margin-bottom" => "10px"
  , "word-break" => "break-word" 
  , "text-align" => "left"
  ]

thumbnail_img_css : List (String, String) 
thumbnail_img_css =
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

-- Fullpage CSS
fullpage_css : Model -> Listing_CSS
fullpage_css listing =
  { container = style fullpage_container
  , inner_container = style fullpage_inner_container
  , title = style fullpage_title_css
  , price = style fullpage_price_css
  , photos = style fullpage_img_css
  , categories = style fullpage_categories_css
  , body = style fullpage_body_css 
  , button = style fullpage_button
  }

fullpage_container : List (String, String)
fullpage_container =
  [ "padding" => "20px 40px"
  , "margin" => "0 auto"
  ]

fullpage_inner_container : List (String, String)
fullpage_inner_container =
  [ "width" => "100%"
  , "height" => "100%"
  ]

fullpage_title_css : List (String, String)
fullpage_title_css =
  [ "text-align" => "center"
  , "font-size" => "30px"
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
  , "font-size" => "20px"
  ]

fullpage_img_css : List (String, String)
fullpage_img_css =
  [ "width" => "500px" -- LOOK HERE
  , "height" => "500px" -- LOOK HERE
  , "margin" => "auto"
  , "border" => "1px solid #ddd"
  ]

fullpage_categories_css : List (String, String)
fullpage_categories_css =
  [ "margin-left" => "20px"
  , "font-size" => "20px"
  ]

fullpage_body_css : List (String, String)
fullpage_body_css =
  [ "margin" => "20px 20px"
  ]

fullpage_button : List (String, String)
fullpage_button =
  [ "height" => "100%"
  , "border" => "none"
  , "color" => "white"
  , "padding" => "10px 20px"
  , "text-align" => "center"
  , "font-size" => "16px"
  , "background-color" => "#800000"
  , "border-radius" => "5px"
  ]

-- Hidden CSS
hidden_css : Listing_CSS
hidden_css =
  { container = style hidden_div
  , inner_container = style hidden_div
  , button = style hidden_div
  , title = style hidden_div
  , price = style hidden_div
  , photos = style hidden_div
  , categories = style hidden_div
  , body = style hidden_div
  }


-- Categories -> List of li of category names
oneCategory : Category -> Html
oneCategory category =
  span [ style category_tag_css ]
       [ text category ]

categoryList : Categories -> List Html
categoryList categories =
  List.map (oneCategory) categories
