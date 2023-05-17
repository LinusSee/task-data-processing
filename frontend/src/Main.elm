module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, li, nav, text, ul)
import Html.Attributes exposing (..)
import Page.Responsibilities as Responsibilities
import Page.Tasks as Tasks
import Time exposing (Month(..))
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
init _ url key =
    updateUrl url { page = NotFoundPage, key = key }


type Page
    = ResponsibilitiesPage Responsibilities.Model
    | TasksPage Tasks.Model
    | NotFoundPage


type Route
    = Responsibilities
    | Tasks
    | NotFound



-- UPDATE


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url.Url
    | GotResponsibilitiesMsg Responsibilities.Msg
    | GotTasksMsg Tasks.Msg


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
            updateUrl url model

        GotResponsibilitiesMsg responsibilitiesMsg ->
            case model.page of
                ResponsibilitiesPage responsibilitiesModel ->
                    toResponsibilitiesPage model (Responsibilities.update responsibilitiesMsg responsibilitiesModel)

                _ ->
                    ( model, Cmd.none )

        GotTasksMsg tasksMsg ->
            case model.page of
                TasksPage tasksModel ->
                    toTasksPage model (Tasks.update tasksMsg tasksModel)

                _ ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Task Data Visualisation"
    , body =
        [ viewHeader
        , viewPage model.page
        ]
    }


viewPage : Page -> Html Msg
viewPage page =
    case page of
        ResponsibilitiesPage model ->
            Responsibilities.view model
                |> Html.map GotResponsibilitiesMsg

        _ ->
            text "Other pages"


viewHeader : Html.Html Msg
viewHeader =
    let
        links =
            ul []
                [ navLink { url = "/responsibilities", label = "Responsibilities" }
                , navLink { url = "/tasks", label = "Tasks" }
                , navLink { url = "/unknown-url", label = "Unknown page" }
                ]

        navLink : { url : String, label : String } -> Html.Html Msg
        navLink { url, label } =
            li [] [ a [ href url ] [ text label ] ]
    in
    nav [] [ links ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- LOGIC


updateUrl : Url.Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case Parser.parse routeParser url of
        Just Responsibilities ->
            toResponsibilitiesPage model (Responsibilities.init model.key)

        Just Tasks ->
            toTasksPage model (Tasks.init model.key)

        _ ->
            ( { model | page = NotFoundPage }, Cmd.none )


routeParser : Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Responsibilities (s "responsibilities")
        , Parser.map Tasks (s "tasks")
        ]


toResponsibilitiesPage : Model -> ( Responsibilities.Model, Cmd Responsibilities.Msg ) -> ( Model, Cmd Msg )
toResponsibilitiesPage model ( responsibilitiesModel, responsibilitiesMsg ) =
    ( { model | page = ResponsibilitiesPage responsibilitiesModel }
    , Cmd.map GotResponsibilitiesMsg responsibilitiesMsg
    )


toTasksPage : Model -> ( Tasks.Model, Cmd Tasks.Msg ) -> ( Model, Cmd Msg )
toTasksPage model ( tasksModel, tasksMsg ) =
    ( { model | page = TasksPage tasksModel }
    , Cmd.map GotTasksMsg tasksMsg
    )
