# Elm Frontend

## Running the frontend
1. To build the application run `elm make src/Main.elm --output=app.min.js`
2. Run `http-server-spa . index.html 80` to serve the `index.html` file

The fact that it has **.min** in its name is a lie, it is not actually minified, but it allows us to use the same `index.html` as we would when building for production.

## Setting up VS-Code
- Install extension elm-ls-vscode and following its instructions for elm-format

## Things to try
1. `--debug` flag for timetravel