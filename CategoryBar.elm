module CategoryBar where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

-- Model
type Category =
  Apartments
    | Subleases
    | Appliances
    | Bikes
    | Books
    | Cars
    | Electronics
    | Employment
    | Furniture
    | Miscellaneous
    | Services
    | Wanted
    | Free
    | None

type alias Model = Category

init : Model
init = None

allCategories : List Category
allCategories =
  [Apartments, Subleases, Appliances, Bikes, Books, Cars, Electronics, Employment, Furniture, Miscellaneous, Services,
  Wanted, Free]

-- Update
type Action =
    ToggleCategory Category

update : Action -> Model -> Model
update action model =
  case action of
    ToggleCategory category -> if category == model then None
                               else category

--view
view : Signal.Address Action -> Model -> Html
view address model =
  div [ style border_bar_css ]
      (List.map (categoryView address model ) allCategories)

categoryView : Signal.Address Action -> Model -> Category -> Html
categoryView address model category =
  let
    css = if model == category then on_css else off_css
    special_modifier_css = if category == Apartments then left_tab_css
                           else if category == Free then right_tab_css
                           else []
  in
    div [ style (css ++ individual_category_css ++ special_modifier_css)
      , onClick address (ToggleCategory category)]
      [text <| toString category]


-- CSS
(=>) = (,)

on_css : List (String, String)
on_css =
  [ "background-color" => "#800000"
  , "color" => "#fff"]


off_css : List (String, String)
off_css =
  ["background-color" => "#fff"]

individual_category_css : List (String, String)
individual_category_css =
  [ "display" => "inline-block"
  , "padding" => "5px"
  , "min-width" => "7%"]

left_tab_css : List (String, String)
left_tab_css = ["border-top-left-radius" => "5px"]

right_tab_css : List (String, String)
right_tab_css = ["border-top-right-radius" => "5px"]

border_bar_css : List (String, String)
border_bar_css =
  ["text-align" => "center"]
