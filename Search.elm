module Search where 

-- Module for the Search Bar. 

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Window
import Signal
import String
import List
import Json.Decode as Json

-- Model
-- State is saved as a query string
type alias Query = String

init : Query
init = ""

-- Update
-- Two types of Actions: 
-- Search which corresponds to an input change.
-- Note: SearchEnter events (corresponding to a search query and not just 
-- input change will not trigger this action). 
-- Reset will reset the search query to blank. 
type Action =
  Search Query
    | Reset

update : Action -> Query -> Query
update action query =
  case action of
    Search terms -> terms
    Reset -> ""

-- View
type alias Context =
  { input : Signal.Address Action
  , enter : Signal.Address (List String)}

-- view renders the Search bar
-- Renders a search bar.
-- Distinct signals are sent for SearchInput and SearchEnter.
view : (Int, Int) -> Int -> Context -> Query -> Html
view (logo_w, h) col_limit context query =
  let
    position = if col_limit <= 2 then []
                else ["margin-left" => toPixel logo_w]
  in
    div [ style ((search_div_css  h) `List.append` position) ]
        [ input [ placeholder "Search"
              , value query
              , onEnter context.enter (String.words query)
              , Html.Events.on "input" targetValue (Signal.message context.input << Search)
              , style input_css
              ]
              []
      ]

onEnter : Signal.Address a -> a -> Attribute
onEnter address value =
  on "keydown"
       (Json.customDecoder keyCode is13)
         (\_ -> Signal.message address value)


is13 : Int -> Result String ()
is13 code =
  if code == 13 then
    Ok ()
  else
    Err "not the right key code"

-- Util
toPixel : number -> String
toPixel x = (toString x) ++ "px"

-- CSS
(=>) = (,)

search_div_css : Int -> List (String, String)
search_div_css h =
  [ "line-height" => toPixel h
  ]

input_css : List (String, String)
input_css =
   [ "width" => "calc(100% - 24px)"
    , "padding" => "10px"
    , "font-size" => "2em"
    , "text-align" => "center"
    ]

