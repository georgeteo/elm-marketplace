module Main where

import StartApp exposing (start)
import Index
import Task exposing (Task)
import Effects exposing (Never)
import Signal

app =
  start 
    { init = Index.init
    , update = Index.update
    , view = Index.view
    , inputs = [infiniteScroll]
    }

main = app.html

port task : Signal (Task Never ())
port task = app.tasks

port lastItemVisible : Signal Bool
infiniteScroll : Signal Index.Action
infiniteScroll = Signal.map Index.Scroll lastItemVisible    

