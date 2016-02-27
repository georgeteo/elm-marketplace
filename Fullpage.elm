module Fullpage where

import Html exposing (..)
import Html.Attributes exposing (..)
import Listing

testlisting : Listing.Model
testlisting = { body = "Brand new, never used, never opened."
              , categories = [ { url = "https://marketplace.uchicago.edu/api/v1/listings.json?q=category%3Abooks",
                                 name = "books" }
                             , { url = "https://marketplace.uchicago.edu/api/v1/listings.json?q=category%3Abooks",
                                 name = "miscellaneous" } 
                             , { url = "https://marketplace.uchicago.edu/api/v1/listings.json?q=category%3Abooks",
                                 name = "miscellaneous2" } 
                             , { url = "https://marketplace.uchicago.edu/api/v1/listings.json?q=category%3Abooks",
                                 name = "miscellaneous3" } 
                             ]
              , html_url = "https://marketplace.uchicago.edu/4d416c78-3909-4d30-9b13-87da45b84932"
              , json_url = "https://marketplace.uchicago.edu/api/v1/4d416c78-3909-4d30-9b13-87da45b84932.json"
              , photos = [ { large = "https://storage.googleapis.com/hosted-caravel.appspot.com/1454537964-461f6490-ff9f-4edc-8a0f-424b9d6bd7d5-large"
                           , small = "https://storage.googleapis.com/hosted-caravel.appspot.com/1454537964-461f6490-ff9f-4edc-8a0f-424b9d6bd7d5-small" }
                         , { large = "https://storage.googleapis.com/hosted-caravel.appspot.com/1454537965-314e4dd5-d818-442e-a097-802c66888dc8-large"
                           , small = "https://storage.googleapis.com/hosted-caravel.appspot.com/1454537965-314e4dd5-d818-442e-a097-802c66888dc8-small" }]
              , postingTime = 1454537966
              , price = 75.0
              , title = "Calculus Fourth Edition - Michael Spivak for sale" }

