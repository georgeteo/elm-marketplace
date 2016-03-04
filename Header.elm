module Header where

-- Module for the header

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Window
import Search exposing (Query)
import Signal
import CategoryBar

-- Model
type alias Meta =
  { search : Query
  , category : CategoryBar.Model }

init : Meta
init =
  { search = Search.init
  , category = CategoryBar.init }

-- Update
type Action =
  SearchAction Search.Action
  | CategoryAction CategoryBar.Action

update : Action -> Meta -> Meta
update action model =
  case action of
    SearchAction search_action -> { model | search = Search.update search_action model.search }
    CategoryAction category_action -> { model | category = CategoryBar.update category_action model.category }

-- Util
toPixel : number -> String
toPixel x = (toString x) ++ "px"

-- CSS widgets
(=>) = (,)

container_css : List (String, String)
container_css = 
  [ "margin-bottom" => "10px"
  , "background-color" => "#fff"
  , "border-radius" => "0px 0px 7px 7px"
  , "padding" => "0px 20px"
  ]

logo_name_css : (Int, Int) -> List (String, String)
logo_name_css (w, h) =
  [ "height" => toPixel h
  , "width" => toPixel w
  , "float" => "left"
  , "cursor" => "pointer"
  ]

logo_css : Int -> List (String, String)
logo_css w =
  [ "height" => "100%"
  , "background-image" => "url(assets/logo.jpg)"
  , "width" => toPixel w
  , "background-size" => "contain"
  , "float" => "left"
  ]

name_css : (Int, Int) -> List (String, String)
name_css (w, h) =
  ["width" => toPixel w
  , "margin" => "0px"
  , "display" => "table-cell"
  , "vertical-align" => "middle"
  , "height" => toPixel h
  ] 

name_text_css : List (String, String)
name_text_css =
  [ "font-size" => "2em"
  , "margin" => "0px"
  ]

-- HTML div for logo + name

-- Input (logo_width, name_w, height)
div_logo_name : (Int, Int, Int) -> Signal.Address () -> Html
div_logo_name (logo_w, name_w, h) address = 
  div [ style (logo_name_css ((logo_w + name_w), h) ) 
      , onClick address () ]
      [ div_logo logo_w
      , div_name (name_w, h)
      ]

-- HTML div for logo with logo as background image
-- Input: logo_width
div_logo : Int -> Html
div_logo w =
  div [ style (logo_css w) ]
      []

-- HTML div for text in logo
-- Input: (name_width, h)
div_name : (Int, Int) -> Html
div_name (w, h) =
  div [ style (name_css (w, h)) ]
      [h1 [ style name_text_css ]
          [ text "UChicago Marketplace" ]
      ]

type alias Context =
  { search : Signal.Address Action
  , searchtrigger : Signal.Address ()
  , category : Signal.Address Action 
  , home : Signal.Address () }

view : Context -> Meta -> Html
view context model =
  let
    logo_width = 77
    name_width = 200
    height = 100
    logo_and_name_width = logo_width + name_width 
    search_context = Search.Context
                     (Signal.forwardTo context.search SearchAction)
                     context.searchtrigger
  in
    div [ style container_css ]
        [ CategoryBar.view (Signal.forwardTo context.category CategoryAction) model.category
        , div_logo_name (logo_width, name_width, height) context.home
        , Search.view (logo_and_name_width, height) search_context model.search
        ]
