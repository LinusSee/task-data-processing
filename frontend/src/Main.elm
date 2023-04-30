module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Chart as C
import Chart.Attributes as CA
import Html exposing (Html, a, div, li, nav, text, ul)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, field, float, string)
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
    { page : Page, responsibilityGroupCount : List LabeledCount, key : Nav.Key }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { page = urlToPage url, responsibilityGroupCount = [], key = key }
    , Http.get
        { url = "http://localhost:5000/responsibility-groups/count"
        , expect = Http.expectJson GotResponsibilityGroupCount responsibilityGroupCountDecoder
        }
    )


type Page
    = Home
    | Statistics
    | NotFound



-- UPDATE


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url.Url
    | GotResponsibilityGroupCount (Result Http.Error (List LabeledCount))


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

        GotResponsibilityGroupCount response ->
            case response of
                Err errorMsg ->
                    ( { model | responsibilityGroupCount = [] }, Cmd.none )

                Ok counts ->
                    ( { model | responsibilityGroupCount = counts }, Cmd.none )



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
        , viewCharts model
        ]
    }


barSampleData : List { label : String, count : Float }
barSampleData =
    -- [ { start = 1, end = 3, y = 5 }, { start = 4, end = 6, y = 7 }, { start = 7, end = 9, y = 9 } ]
    [ { label = "Gruppe 1", count = 39 }
    , { label = "Gruppe 2", count = 244 }
    , { label = "Gruppe 4", count = 3109 }
    ]


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


viewCharts : Model -> Html.Html Msg
viewCharts model =
    div [ class "charts-container" ]
        [ viewLabeledBarChart model.responsibilityGroupCount
        , viewLineChart [ { x = 0, y = 1, z = 2 }, { x = 5, y = 4, z = 6 } ]
        , viewLabeledBarChart barSampleData
        ]


viewLineChart : List { x : Float, y : Float, z : Float } -> Html.Html Msg
viewLineChart data =
    div [ class "line-chart" ]
        [ C.chart
            [ CA.height 300
            , CA.width 300
            ]
            [ C.xLabels []
            , C.yLabels [ CA.withGrid ]
            , C.series .x
                [ C.interpolated .y [ CA.monotone ] [ CA.circle ]
                , C.interpolated .z [ CA.monotone ] [ CA.circle ]
                ]
                data
            ]
        ]


viewLabeledBarChart : List { label : String, count : Float } -> Html.Html Msg
viewLabeledBarChart data =
    div [ class "bar-chart" ]
        [ C.chart
            [ CA.height 300
            , CA.width 300
            ]
            [ C.yLabels [ CA.withGrid ]
            , C.binLabels .label [ CA.moveDown 24 ]
            , C.bars
                []
                [ C.bar .count [] ]
                data
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- LOGIC


type alias LabeledCount =
    { label : String
    , count : Float
    }


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


responsibilityGroupCountDecoder : Decoder (List LabeledCount)
responsibilityGroupCountDecoder =
    field "countPerGroupName" labeledCountsDecoder


labeledCountsDecoder : Decoder (List LabeledCount)
labeledCountsDecoder =
    Decode.list labeledCountDecoder


labeledCountDecoder : Decoder LabeledCount
labeledCountDecoder =
    Decode.map2 LabeledCount
        (field "label" string)
        (field "count" float)
