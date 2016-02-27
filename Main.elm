module Main where

import StartApp exposing (start)
import Index
import Task exposing (Task)
import Effects exposing (Never)

app =
  start 
    { init = Index.init
    , update = Index.update
    , view = Index.view (1260, 780)
    , inputs = []
    }

main = app.html

port task : Signal (Task Never ())
port task = app.tasks
