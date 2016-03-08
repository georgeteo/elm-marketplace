module CategoryBar where

-- Module for category bar.
-- Category bar will be horizontal allowed.
-- Else it will collapse into a vertical sidebar. 

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Animation as UI
import Html.Animation.Properties exposing (..)
import Html.Events exposing (..)
import Effects exposing (..)

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

-- CategoryBar model contains 3 objects:
-- on is the category that has been clicked. 
-- hover contains the category indicates a category that the mouse hovers over.
-- style is a style for the vertical category bar that slides out when the browser screen is small.
type alias Model =
  { on : Category
  , hover : Category
  , style : UI.Animation
  }

init : Model
init =
  { on = None
    , hover = None
    , style = UI.init [ Left -100 Px
                      , Opacity 0.0
                      ]
  }

-- List of all categories that will be rendered in the view
allCategories : List Category
allCategories =
  [Apartments
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
-- Union type of actions for the category bar:
-- ToggleCategory that the action that occurs when a category is clicked. 
-- Depending on context, ToggleCategory either turns on or off a category.
-- MouseEneter/MouseLeave are actions for mouse entering or leaving a category
-- for the hover record in the model.
-- Reset will reset the categories to the inital state with no category triggered.
-- If the mouse is hovering over a cateogry when reset is triggered, the hover
-- highlight will not be turned off. 
-- Show, Hide, Animate are Actions for the the slideout sidebar animation. 
type Action =
    ToggleCategory Category
      | MouseEnter Category
      | MouseLeave Category
      | Reset
      | Show
      | Hide
      | Animate UI.Action

update : Action -> Model -> (Model , Effects Action)
update action model =
  case action of
    ToggleCategory category ->
      let
        model' = if category == model.on then {model | on = None}
                    else {model | on = category }
      in
        (model', Effects.none)
    MouseEnter category -> ({model | hover = category }, Effects.none)
    MouseLeave category -> ({model | hover = None}, Effects.none)
    Reset -> ({model | on = None }, Effects.none)
    Show ->
      UI.animate
        |> UI.props
          [ Left (UI.to 0) Px
          , Opacity (UI.to 1)
          ]
        |> onMenu model
    Hide ->
      UI.animate
        |> UI.props
          [ Left (UI.to -100) Px
          , Opacity (UI.to 0)
          ]
        |> onMenu model
    Animate action ->
      onMenu model action

-- Helper function for animation.
onMenu =
  UI.forwardTo
    Animate
    .style
    (\w style -> {w | style = style })

--view
-- Set of addresses to trigger actions from the view. 
-- There are 3 types of UI effects:
-- categoryInput is the Signal when the mouse hovers over a category
-- cateogryEnter is the Signal for when a category is clicked. 
--               This also changes the rendered listings. 
-- Animation is the Signal for triggering the animation sidebar which is only
-- activated when the width of the browser viewport is small. 
type alias Context =
  { categoryInput : Signal.Address Action
  , categoryEnter : Signal.Address Category
  , animation : Signal.Address Action
  }

-- view generates the HTML for the category bar.
-- If viewport width is small, it will render a hidden vertical category bar
-- that slides out.
-- else a regular horizontal category bar is rendered. 
view : Int -> Context -> Model -> Html
view col_limit context model =
  let debug = Debug.log "Col Limit in CategoryBar View" col_limit in
  if col_limit < 4 then verticalTrigger context model
  else horizontalView context model


-- Set of views to render the horizontal category bar
horizontalView : Context -> Model -> Html
horizontalView context model =
  div [ style border_bar_css ]
      (List.map (horizontalCategory context model) allCategories)

horizontalCategory : Context -> Model -> Category -> Html
horizontalCategory context model category =
  let
    css = if (model.on == category) || (model.hover == category)  then on_css else off_css
    special_modifier_css = if category == Apartments then left_tab_css
                           else if category == Free then right_tab_css
                           else []
  in
    div [ style (css ++ horizontal_category_css ++ special_modifier_css)
        , onClick context.categoryEnter category
        , onMouseEnter context.categoryInput (MouseEnter category)
        , onMouseLeave context.categoryInput (MouseLeave category) ]
        [text <| toString category]

-- Set of views to render vertical category bar. 
verticalTrigger : Context -> Model -> Html
verticalTrigger context model =
  let
    on_category = if model.on == None then "Category" else toString model.on
  in
    div [ onMouseEnter context.animation Show
        , onMouseLeave context.animation Hide
        , style trigger_css
        , id "vertical-trigger"
        ]
        [ h4 [style vertical_text_css ] [text on_category]
        , verticalView context model]

verticalView : Context -> Model -> Html
verticalView context model =
  div [ style (vertical_view_css ++ (UI.render model.style))
      , id "vertical-view"]
      (List.map (verticalCategory context model) allCategories)

verticalCategory : Context -> Model -> Category -> Html
verticalCategory context model category =
  let
    css = if (model.on == category) || (model.hover == category)  then on_css else off_css
  in
    div [style (css ++ vertical_category_css)
        , onClick context.categoryEnter category
        , onMouseEnter context.categoryInput (MouseEnter category)
        , onMouseLeave context.categoryInput (MouseLeave category) ]
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

horizontal_category_css : List (String, String)
horizontal_category_css =
  [ "display" => "inline-block"
  , "padding" => "5px"
  , "min-width" => "calc(7.5% - 10px)"
  , "cursor" => "pointer"
  ]

left_tab_css : List (String, String)
left_tab_css = ["border-top-left-radius" => "5px"]

right_tab_css : List (String, String)
right_tab_css = ["border-top-right-radius" => "5px"]

border_bar_css : List (String, String)
border_bar_css =
  ["text-align" => "center"]

trigger_css : List (String, String)
trigger_css = [ "position" => "absolute"
              , "left" => "0px"
              , "top"=> "0px"
              , "width" => "25px"
              , "height" => "100%"
              , "border" => "1px solid #f5f5f5"
              , "background-color" => "white"
              ]

vertical_view_css : List (String, String)
vertical_view_css = [ "position"=> "absolute"
                    , "top" => "-2px"
                    , "margin-left" => "-2px"
                    , "padding" => "5px 20px"
                    , "background-color" => "#fff"
                    , "border" => "1px solid #f5f5f5"
                    , "text-align" => "center"
                    , "z-index" => "9"
                    ]

vertical_category_css : List (String, String)
vertical_category_css =
  [ "display" => "block"
  , "padding" => "5px 5px 5px 0px"
  , "cursor" => "pointer"
  , "float" => "left"
  , "width" => "100%"
  , "font-size" => "large"
  ]

vertical_text_css : List (String, String)
vertical_text_css =
  [ "width" => "1px"
  , "font-size" => "1em"
  , "padding" => "0px 4px"
  , "word-wrap" => "break-word"
  , "margin-top" => "10px"
  ]
