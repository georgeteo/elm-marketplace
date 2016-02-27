module Search where 

import Html exposing (..)
import Html.Attributes exposing (..)
import Window

-- Util
toPixel : number -> String
toPixel x = (toString x) ++ "px"

-- CSS
(=>) = (,)

search_div_css : (Int, Int) -> List (String, String)
search_div_css (w, h) =
  [ "margin-left" => toPixel w
  , "line-height" => toPixel h
  ]

input_css : List (String, String)
input_css =
   [ "width" => "calc(100% - 24px)"
    , "padding" => "10px"
    , "font-size" => "2em"
    , "text-align" => "center"
    ]

-- View

view : (Int, Int) -> Html
view (w, h) =
  div [ style (search_div_css (w, h)) ]
      [ input [ placeholder "Search"
              -- , value model.topic
              -- , onEnter address Create
              -- , on "input" targetValue (Signal.message address << Topic)
              , style input_css
              ]
              []
      ]
    
main : Signal Html
main = Signal.map view Window.dimensions 

