module Main where

-- Main module for the application. 
-- Uses StartApp to set up the boilerplate for a standard MVC app.

import StartApp exposing (start)
import Index
import Task exposing (Task)
import Effects exposing (Never)
import Signal

app =
  start 
    { init = Index.init -- Initializes model
    , update = Index.update -- Defines update function
    , view = Index.view -- Function to render the view
    , inputs = [infiniteScroll, Index.firstResize, Index.resizes] -- Inputs from ports
    }

-- Runs the app in function main. 
main = app.html

-- Sends all of the tasks triggered by Effects to a port
port task : Signal (Task Never ())
port task = app.tasks

-- Incoming port to recieve incoming Signals for the infinite scroll.
port lastItemVisible : Signal Bool
infiniteScroll : Signal Index.Action
infiniteScroll = Signal.map Index.Scroll lastItemVisible    

