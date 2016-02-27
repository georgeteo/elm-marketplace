import Http
import Markdown
import Html exposing (Html)
import Task exposing (Task, andThen)

main : Signal Html
main = Signal.map Markdown.toHtml readme.signal

readme : Signal.Mailbox String
readme = 
  Signal.mailbox ""

report : String -> Task x ()
report markdown =
  Signal.send readme.address markdown

port fetchReadme : Task Http.Error ()
port fetchReadme = 
  Http.getString readmeUrl `andThen` report

readmeUrl : String
readmeUrl = 
  -- "https://raw.githubusercontent.com/elm-lang/core/master/README.md"
  "http://elm-marketplace.appspot.com/one_listing"
