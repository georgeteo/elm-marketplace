module ImageViewer where

-- Module for image viewer

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)
import Window
import String exposing (..)

-- Model
type alias Photo = { large : String,
                     small : String }
type alias Photos = List Photo

-- Update
type Action = Left | Right 

update : Action -> Photos -> Photos
update action photos =
  case photos of
    [] -> []
    p::ps -> 
      case action of
        Left -> ps ++ [p]
        Right -> 
          let
            photos' = List.reverse photos
          in
            case photos' of
              [] -> []
              p'::ps' -> List.reverse (ps' ++ [p']) 

-- View
image_view : (Int, Int) -> String -> Address Action -> Html
image_view (w, h) p address =
  div [ style (image_CSS (w, h) p) ]
      [ clicker_view Left address 
      , clicker_view Right address
      ]

clicker_view : Action -> Address Action -> Html
clicker_view action address =
  case action of
    Left -> div [ style (clicker_CSS action)
                , onClick address action
                ]
                []
    Right -> div [ style (clicker_CSS action)
                 , onClick address action
                 ]
                 []

view : Int -> Address Action -> Photos -> Html
view w address photos =
  let debug = Debug.log "Image Size" w in
  case photos of
    [] -> image_view (w, w) "http://www.oceanofweb.com/wp-content/themes/OOW/images/default-thumb.gif" address
    p::ps -> image_view (w, w) p.large address


-- CSS
(=>) = (,)

toPixel : number -> String
toPixel x = (toString x) ++ "px"

image_CSS : (Int, Int) -> String -> List (String, String)
image_CSS (w, h) p =
  [ "background-image" => ("url(" ++ p ++ ")")
  , "width" => "100%"
  , "height" => "0"
  , "padding-bottom" => "100%"
  , "background-repeat" => "no-repeat"
  , "background-size" => "cover"
  ]

clicker_CSS : Action -> List (String, String)
clicker_CSS action =
  case action of
    Left -> [ "position" => "relative"
            , "width" => "50px"
            , "opacity" => "100"
            , "float" => "left"
            , "padding-bottom" => "100%"
            ]
    Right -> [ "position" => "relative"
             , "width" => "50px"
             , "padding-bottom" => "100%"
             , "opacity" => "100"
             , "float" => "right"
             ]

