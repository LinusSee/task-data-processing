module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (a, li, nav, text, ul)
import Html.Attributes exposing (..)
import Url
import Url.Parser as Parser exposing (Parser, s)



-- Main


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { page : Page, key : Nav.Key }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { page = urlToPage url, key = key }, Cmd.none )


type Page
    = Home
    | Statistics
    | NotFound



-- UPDATE


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        ChangedUrl url ->
            ( { model | page = urlToPage url }, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Task Data Visualisation"
    , body =
        [ viewHeader
        , case model.page of
            Home ->
                text "You are on the homepage"

            Statistics ->
                text "Would you look at those statistics"

            NotFound ->
                text "No idea what you are looking for"
        ]
    }


viewHeader : Html.Html Msg
viewHeader =
    let
        links =
            ul []
                [ navLink { url = "/home", label = "Homepage" }
                , navLink { url = "/statistics", label = "Statistics" }
                , navLink { url = "/unknown-url", label = "Unknown page" }
                ]

        navLink : { url : String, label : String } -> Html.Html Msg
        navLink { url, label } =
            li [] [ a [ href url ] [ text label ] ]
    in
    nav [] [ links ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- LOGIC


urlToPage : Url.Url -> Page
urlToPage url =
    Parser.parse routeParser url
        |> Maybe.withDefault NotFound


routeParser : Parser (Page -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Home (s "home")
        , Parser.map Statistics (s "statistics")
        ]
