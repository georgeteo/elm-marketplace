module ImageViewer where

-- Module for image viewer.
-- ImageViewer renders a default "no-image" image if there is no image attached
-- to a listing.
-- If there is greater than one image, than the first image in the list is rendered
-- and there are buttons to cycle through the images.
-- If there is only one image then there will be no options to rotate through the images. 

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)
import Window
import String exposing (..)

-- Model
-- Each Photo is record type to a url of a large and small picture.
-- Photos type is a List Photo
-- Photos will cycle through the images according to the actions below.
type alias Photo = { large : String,
                     small : String }
type alias Photos = List Photo

-- Update
-- There are two actions internal to ImageViewer:
-- Left and Right which cycles through the images. 
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
-- image_view renders a single image. 
image_view : String -> List Html -> Html
image_view p buttons =
  div [ style (image_CSS p) ]
      buttons

-- The clicker renders a Left or Right clicker 
clicker_view : Action -> Address Action -> Html
clicker_view action address =
  case action of
    Left -> div [ style (clicker_CSS "left.png" action)
                , onClick address action
                ]
                []
    Right -> div [ style (clicker_CSS "right.png" action)
                 , onClick address action
                 ]
                 []

-- ImageViewer.view renders the overall Html for the ImageViewer which contains
-- a image_view for the current head of the Photos List with clickers if appropriate. 
view : Address Action -> Photos -> Html
view address photos =
  let
    clickers = [clicker_view Left address, clicker_view Right address]
  in
  case photos of
    [] -> image_view "http://www.oceanofweb.com/wp-content/themes/OOW/images/default-thumb.gif" []
    [p] -> image_view p.small []
    p::ps -> image_view p.small clickers


-- CSS
(=>) = (,)

toPixel : number -> String
toPixel x = (toString x) ++ "px"

image_CSS : String -> List (String, String)
image_CSS p =
  [ "background-image" => ("url(" ++ p ++ ")")
  , "width" => "100%"
  , "height" => "0"
  , "padding-bottom" => "100%"
  , "background-repeat" => "no-repeat"
  , "background-size" => "cover"
  ]

clicker_CSS : String -> Action -> List (String, String)
clicker_CSS img action =
  case action of
    Left -> [ "position" => "relative"
            , "width" => "50px"
             , "opacity" => "100"
            , "float" => "left"
            , "padding-bottom" => "100%"
            , "background-image" => ("url(" ++ img ++ ")")
            , "background-position" => "center"
            , "background-repeat" => "no-repeat"
            , "cursor" => "pointer"
            ]
    Right -> [ "position" => "relative"
             , "width" => "50px"
             , "padding-bottom" => "100%"
             , "opacity" => "100"
             , "float" => "right"
             , "background-image" => ("url(" ++ img ++ ")")
             , "background-position" => "center"
             , "background-repeat" => "no-repeat"
             , "cursor" => "pointer"
             ]

