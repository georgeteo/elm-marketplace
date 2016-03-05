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

#### Critical

1. Index page wonky when search happens -- DONE
2. Category bar highlight will return to thumbnail view -- DONE
3. Add icons for left and right images if necessary -- DONE
4. Search empty returns to homepage -- DONE
5. Click logo returns to homepage -- DONE
6. Mouse pointer icon from I to < on logo -- DONE
7. Unify filtering of category and search -- DONE
8. Load more from server in category view. -- DONE 

#### Non-critical

1. Search -- DONE
2. Category -- DONE
4. Clean up CSS for fullpage -- DONE
4. Add scroll loading animation
5. Http + infinite scroll -- DONE
6. "Back" from fullpage to thumbnail remembers place on the screen

#### Stretch Goals

3. Masonary 
6. Add pictures to go api
6. POST forms
7. Login and Auth
