module CategoryBar where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Listings

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

type alias Model = (Category, Category)

init : Model
init = (None, None)

allCategories : List Category
allCategories =
  [ Apartments
  , Subleases
  , Appliances
  , Bikes
  , Books
  , Cars
  , Electronics
  , Employment
  , Furniture
  , Miscellaneous
  , Services
  , Wanted
  , Free
  ]

-- Update
type Action =
    ToggleCategory Category
      | MouseEnter Category
      | MouseLeave Category

update : Action -> Model -> Model
update action (on, hover) =
  case action of
    ToggleCategory category -> if category == on then (None, hover)
                               else (category, hover)
    MouseEnter category -> (on, category)
    MouseLeave category -> (on, None)

-- View
type alias Context =
  { category_click : Signal.Address Action
  , category_hover : Signal.Address (Action, ListingsAction) 
  }


view : Context -> Model -> Html
view context model =
  div [ style border_bar_css ]
      (List.map (categoryView context model ) allCategories)

categoryView : Context -> Model -> Category -> Html
categoryView context (on, hover) category =
  let
    css = if (on == category) || (hover == category)  then on_css else off_css
    special_modifier_css = if category == Apartments then left_tab_css
                           else if category == Free then right_tab_css
                           else []
  in
    div [ style (css ++ individual_category_css ++ special_modifier_css)
      , onClick context.category_click (ToggleCategory category, Listings.CategoryFilter category)
      , onMouseEnter context.context_hover (MouseEnter category) 
      , onMouseLeave context.context_hover (MouseLeave category) ]
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
  , "min-width" => "calc(7.5% - 10px)"
  ]

left_tab_css : List (String, String)
left_tab_css = ["border-top-left-radius" => "5px"]

right_tab_css : List (String, String)
right_tab_css = ["border-top-right-radius" => "5px"]

border_bar_css : List (String, String)
border_bar_css =
  ["text-align" => "center"]
