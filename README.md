# Elm Marketplace

This is a FRP rewrite of UChicago Marketplace in Elm.

## Make

Once Elm is installed, we can run the dev server by running `elm-reactor` 
and the entry point of the application is `main.elm`. 

To build for production, run `elm-make main.elm`. 

## Required Packages

The following elm community packages (as listed in `elm-package.json`) are required:

```
elm-lang/core
evancz/elm-effects
evancz/elm-html
evancz/elm-http
evancz/start-app
evancz/virtual-dom
```

## Todo

1. Search
2. Category
3. Masonary
4. Clean up CSS for fullpage
5. Http + infinite scroll
6. Add pictures to go api
6. POST forms
7. Login and Auth
