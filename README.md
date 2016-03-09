# Elm Marketplace

This is a FRP rewrite of UChicago Marketplace in Elm.

## Make

Run `./make.sh` to run the build process. 
This will make compile a JS file `main.js`. 

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

## Project structure

Elm-Marketplace follows the standard Elm MVC architecture in nested components
components. 
Each component has an internal state called `Model` and a union type of 
`Action` that operates on the model.
Each component also has a view that takes a `Context`, which is a record type
of addresses that are passed to the view so that UI Signals can be sent to the
appropriate mailboxes, and a `Model` that tells the view the current state.

Consider the following example:

The model in `Index.elm` has 4 nested components: Listings, Header, CategoryBar,
and Meta. 
The `Action` union type in `Index.elm` contains many actions. Let's consider
`ListingsAction`. If a `ListingsAction` Signal is triggered, then the `update`
function in `Index.elm` will enter the `ListingsAction` branch in the case statement.
In the `ListingsAction` branch, we know that this particular Signal corresponds to
an update internal to the `Listings` type, so it updates the the listings entry
of the `Index` model by calling `Listing.update`. 

Similarly in the view, when rendering the `Listings.view`, we pass the
`Listings.Context`, which is a record type of forwarding address for each
action that will be triggered in that component. For example, in the `Listings`
component there are two types of actions that will be triggered: `ThumbanilAction`,
which are actions to reset to the `ThumbnailView` triggered by the "Back" button
in a listing and `ListingsAction`, which are actions that update state internal to
the `Listings` component (e.g., `ImageViewer` or `Fullpage` buttons), which are 
wrapped in a generic `ListingsAction` type, because `Index.elm` won't need to
unwrap the `Action` when triggered.

## Todo

1. Add scroll loading animation
2. "Back" from fullpage to thumbnail remembers place on the screen
4. Add pictures to go api
5. POST forms
6. Login and Auth
