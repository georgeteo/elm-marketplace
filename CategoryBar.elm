module CategoryBar where

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
                      , Height 50 Px
                      ]
  }

allCategories : List Category
allCategories =
  [Apartments, Subleases, Appliances, Bikes, Books, Cars, Electronics, Employment, Furniture, Miscellaneous, Services,
  Wanted, Free]

-- Update
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
          , Height (UI.to 500) Px
          ]
        |> onMenu model
    Hide ->
      UI.animate
        |> UI.props
          [ Left (UI.to -100) Px
          , Opacity (UI.to 0)
          , Height (UI.to 50) Px
          ]
        |> onMenu model
    Animate action ->
      onMenu model action

onMenu =
  UI.forwardTo
    Animate
    .style
    (\w style -> {w | style = style })

--view
type alias Context =
  { categoryInput : Signal.Address Action
  , categoryEnter : Signal.Address Category
  , animation : Signal.Address Action
  }

view : Int -> Context -> Model -> Html
view col_limit context model =
  let debug = Debug.log "Col Limit in CategoryBar View" col_limit in
  if col_limit < 4 then verticalTrigger context model
  else horizontalView context model
  
      
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

verticalTrigger : Context -> Model -> Html
verticalTrigger context model =
  div [ onMouseEnter context.animation Show
      , onMouseLeave context.animation Hide
      , style trigger_css
      , id "vertical-trigger"
      ]
      [verticalView context model]
 
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
              , "width" => "50px"
              , "height" => "50px"
              , "border" => "1px dashed #AAA"
              ]

vertical_view_css : List (String, String)
vertical_view_css = [ "position"=> "absolute"
                    , "top" => "-2px" -- TODO: What is this doing here?
                    , "margin-left" => "-2px" -- TODO: What is this doing here?
                    , "height" => "100%"
                    , "padding" => "10px 20px"
                    , "background-color" => "#f5f5f5"
                    , "border" => "1px solid #f5f5f5"
                    ]

vertical_category_css : List (String, String)
vertical_category_css =
  [ "display" => "block"
  , "padding" => "5px"
  , "cursor" => "pointer"
  , "float" => "left"
  ]
