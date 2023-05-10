module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Chart as C
import Chart.Attributes as CA
import Date
import Html exposing (Html, a, div, h2, input, li, nav, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Http
import Json.Decode as Decode exposing (Decoder, field, float, string)
import Task
import Url
import Url.Builder as UrlBuilder
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
    { page : Page, selectedDate : String, responsibilityGroupCount : List LabeledCount, key : Nav.Key }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { page = urlToPage url, selectedDate = "", responsibilityGroupCount = [], key = key }
    , Task.perform GotInitialDate Date.today
    )


type Page
    = Home
    | Statistics
    | NotFound



-- UPDATE


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url.Url
    | GotInitialDate Date.Date
    | ChangeDate String
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

        GotInitialDate date ->
            let
                newDateString =
                    Date.toIsoString date
            in
            ( { model | selectedDate = newDateString }
            , Http.get
                { url = UrlBuilder.crossOrigin "http://localhost:5000/responsibility-groups" [ "count" ] [ UrlBuilder.string "filter-date" newDateString ]
                , expect = Http.expectJson GotResponsibilityGroupCount responsibilityGroupCountDecoder
                }
            )

        ChangeDate newDateString ->
            ( { model | selectedDate = newDateString }
            , Http.get
                { url = UrlBuilder.crossOrigin "http://localhost:5000/responsibility-groups" [ "count" ] [ UrlBuilder.string "filter-date" newDateString ]
                , expect = Http.expectJson GotResponsibilityGroupCount responsibilityGroupCountDecoder
                }
            )

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
    div []
        [ viewResponsibilities model
        , div []
            [ h2 []
                [ text "Test charts" ]
            , div [ class "charts-container" ]
                [ viewLineChart [ { x = 0, y = 1, z = 2 }, { x = 5, y = 4, z = 6 } ]
                ]
            ]
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


viewResponsibilities : Model -> Html.Html Msg
viewResponsibilities model =
    div []
        [ h2 []
            [ text "Responsibilities" ]
        , viewDateInput model.selectedDate
        , viewResponsibilitiesTable model.responsibilityGroupCount
        , div
            [ class "charts-container" ]
            [ viewLabeledBarChart model.responsibilityGroupCount ]
        ]


viewLabeledBarChart : List LabeledCount -> Html Msg
viewLabeledBarChart data =
    div [ class "bar-chart" ]
        [ C.chart
            [ CA.height 300
            , CA.width 1600
            ]
            [ C.yLabels [ CA.withGrid ]
            , C.binLabels .label [ CA.moveDown 24 ]
            , C.bars
                []
                [ C.bar .count [] ]
                data
            , C.barLabels [ CA.moveUp 8 ]
            ]
        ]


viewDateInput : String -> Html Msg
viewDateInput dateString =
    input [ type_ "date", onInput ChangeDate, value dateString ] []


viewResponsibilitiesTable : List LabeledCount -> Html Msg
viewResponsibilitiesTable labeledCounts =
    let
        createRow labeledCount =
            tr [ class "labeled-count-table__data-row" ]
                [ td [ class "labeled-count-table__cell", class "labeled-count-table__data-cell" ]
                    [ text labeledCount.key ]
                , td [ class "labeled-count-table__cell", class "labeled-count-table__data-cell" ]
                    [ text labeledCount.label ]
                , td [ class "labeled-count-table__cell", class "labeled-count-table__data-cell", class "labeled-count-table__cell--number" ]
                    [ text <| String.fromFloat labeledCount.count ]
                ]
    in
    table [ class "labeled-count-table" ]
        [ thead [ class "labeled-count-table__header" ]
            [ tr [ class "labeled-count-table__header-row" ]
                [ th [ class "labeled-count-table__cell", class "labeled-count-table__header-cell" ] [ text "Key" ]
                , th [ class "labeled-count-table__cell", class "labeled-count-table__header-cell" ] [ text "Label" ]
                , th [ class "labeled-count-table__cell", class "labeled-count-table__header-cell" ] [ text "Count" ]
                ]
            ]
        , tbody [ class "labeled-count-table__header" ]
            (List.map createRow labeledCounts)
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- LOGIC


type alias LabeledCount =
    { key : String
    , label : String
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
    Decode.map3 LabeledCount
        (field "key" string)
        (field "label" string)
        (field "count" float)
