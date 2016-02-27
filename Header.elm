module Header where

-- Module for the header

import Html exposing (..)
import Html.Attributes exposing (..)
import Window
import Search

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
  ]

logo_name_css : (Int, Int) -> List (String, String)
logo_name_css (w, h) =
  [ "height" => toPixel h
  , "width" => toPixel w
  , "float" => "left"
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
div_logo_name : (Int, Int, Int) -> Html
div_logo_name (logo_w, name_w, h) = 
  div [ style (logo_name_css ((logo_w + name_w), h) ) ]
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

view : (Int, Int) -> Html
view (w, h) =
  let
    logo_width = 77
    name_width = 200
    logo_and_name_width = logo_width + name_width 
  in
    div [ style container_css ]
        [ div_logo_name (logo_width, name_width, h)
        , Search.view (logo_and_name_width, h)
        ]

main : Signal Html
main = Signal.map view Window.dimensions 
