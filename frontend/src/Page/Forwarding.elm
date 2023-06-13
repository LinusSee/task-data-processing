module Page.Forwarding exposing (..)

import Browser.Navigation as Nav
import Chart as C
import Chart.Attributes as CA
import Date exposing (Date)
import Html exposing (Html, div, h2, input, option, select, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Http
import Json.Decode as Decode exposing (Decoder, field, float, string)
import Task
import Time
import Url.Builder as UrlBuilder



-- MODEL


type alias Model =
    { selectedDate : String
    , selectedGroup : String
    , pastDays : String
    , groupsForSelection : List String
    , forwardingGroupCounts : List ForwardingGroupCount
    , forwardingGroupCountHistory : Maybe ForwardingGroupCountHistory
    }


type alias ForwardingGroupCount =
    { key : String
    , label : String
    , inboundCount : Float
    , outboundCount : Float
    }


type alias ForwardingGroupCountHistory =
    { key : String
    , counts : List CountsForTimestamp
    }


type alias CountsForTimestamp =
    { timestamp : Float
    , inbound : Float
    , outbound : Float
    }



-- INIT


init : Nav.Key -> ( Model, Cmd Msg )
init _ =
    ( { selectedDate = ""
      , selectedGroup = ""
      , pastDays = "14"
      , groupsForSelection = []
      , forwardingGroupCountHistory = Nothing
      , forwardingGroupCounts = []
      }
    , Task.perform GotInitialDate Date.today
    )



-- UPDATE


type Msg
    = GotInitialDate Date
    | ChangeSelectedGroup String
    | ChangePastDays String
    | ChangeDate String
    | GotForwardingCountHistory (Result Http.Error ForwardingGroupCountHistory)
    | GotForwardingCounts (Result Http.Error (List ForwardingGroupCount))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotInitialDate initialDate ->
            let
                newDate =
                    Date.toIsoString initialDate
            in
            ( { model | selectedDate = newDate }, getAllForwardingCounts newDate )

        ChangeSelectedGroup newGroup ->
            ( { model | selectedGroup = newGroup }, getGroupCountHistory model.pastDays newGroup )

        ChangePastDays newPastDays ->
            ( { model | pastDays = newPastDays }, getGroupCountHistory newPastDays model.selectedGroup )

        ChangeDate newDate ->
            ( { model | selectedDate = newDate }, getAllForwardingCounts newDate )

        GotForwardingCountHistory result ->
            case result of
                Err _ ->
                    ( { model | forwardingGroupCountHistory = Nothing }, Cmd.none )

                Ok groupHistory ->
                    ( { model | forwardingGroupCountHistory = Just groupHistory }, Cmd.none )

        GotForwardingCounts result ->
            case result of
                Err _ ->
                    ( { model | forwardingGroupCounts = [] }, Cmd.none )

                Ok groupCounts ->
                    let
                        groupKeys =
                            List.map .key groupCounts
                    in
                    ( { model | forwardingGroupCounts = groupCounts, groupsForSelection = groupKeys }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Forwarding" ]
        , viewHistoryGroupInput model
        , case model.forwardingGroupCountHistory of
            Just history ->
                viewForwardingCountsHistoryChart history

            Nothing ->
                text "No group selected"
        , viewDateInput model.selectedDate
        , viewForwardingCountsTable model.forwardingGroupCounts
        ]


viewDateInput : String -> Html Msg
viewDateInput dateString =
    input [ type_ "date", onInput ChangeDate, value dateString ] []


viewForwardingCountsTable : List ForwardingGroupCount -> Html Msg
viewForwardingCountsTable counts =
    let
        createRow count =
            tr [ class "labeled-count-table__data-row" ]
                [ td [ class "labeled-count-table__cell", class "labeled-count-table__data-cell" ]
                    [ text count.key ]
                , td [ class "labeled-count-table__cell", class "labeled-count-table__data-cell", class "labeled-count-table__cell--number" ]
                    [ text <| String.fromFloat count.inboundCount ]
                , td [ class "labeled-count-table__cell", class "labeled-count-table__data-cell", class "labeled-count-table__cell--number" ]
                    [ text <| String.fromFloat count.outboundCount ]
                ]
    in
    table [ class "labeled-count-table" ]
        [ thead [ class "labeled-count-table__header" ]
            [ tr [ class "labeled-count-table__header-row" ]
                [ th [ class "labeled-count-table__cell", class "labeled-count-table__header-cell" ] [ text "Key" ]
                , th [ class "labeled-count-table__cell", class "labeled-count-table__header-cell" ] [ text "Inbound" ]
                , th [ class "labeled-count-table__cell", class "labeled-count-table__header-cell" ] [ text "Outbound" ]
                ]
            ]
        , tbody [ class "labeled-count-table__header" ]
            (List.map createRow counts)
        ]


viewHistoryGroupInput : Model -> Html Msg
viewHistoryGroupInput model =
    let
        options =
            List.map (\group -> option [ value group ] [ text group ]) model.groupsForSelection
    in
    div []
        [ select [ onInput ChangeSelectedGroup, value model.selectedGroup ]
            options
        , viewPastDaysInput model.pastDays
        ]


viewPastDaysInput : String -> Html Msg
viewPastDaysInput pastDays =
    input [ type_ "number", onInput ChangePastDays, value pastDays ] []


viewForwardingCountsHistoryChart : ForwardingGroupCountHistory -> Html Msg
viewForwardingCountsHistoryChart { key, counts } =
    div [ class "line-chart" ]
        [ text key
        , C.chart
            [ CA.height 300
            , CA.width 600
            ]
            [ C.xLabels [ CA.withGrid, CA.format timestampToDateString ]
            , C.yLabels [ CA.withGrid ]
            , C.series .timestamp
                [ C.interpolated .inbound [ CA.monotone ] []
                    |> C.named "Eingehend"
                , C.interpolated .outbound [ CA.monotone ] []
                    |> C.named "Ausgehend"
                ]
                counts
            , C.legendsAt .max
                .max
                [ CA.column
                , CA.moveRight 15
                , CA.spacing 5
                ]
                [ CA.width 20 ]
            ]
        ]


timestampToDateString : Float -> String
timestampToDateString timestamp =
    round (1000 * timestamp)
        |> Time.millisToPosix
        |> Date.fromPosix Time.utc
        |> Date.toIsoString



-- LOGIC


getGroupCountHistory : String -> String -> Cmd Msg
getGroupCountHistory pastDays groupKey =
    Http.get
        { url =
            UrlBuilder.crossOrigin "http://localhost:5000/forwarding"
                [ groupKey, "history" ]
                [ UrlBuilder.string "past-days" pastDays ]
        , expect = Http.expectJson GotForwardingCountHistory forwardingGroupCountHistoryDecoder
        }


getAllForwardingCounts : String -> Cmd Msg
getAllForwardingCounts selectedDate =
    Http.get
        { url =
            UrlBuilder.crossOrigin "http://localhost:5000/forwarding"
                [ "count-by-group" ]
                [ UrlBuilder.string "filter-date" selectedDate ]
        , expect = Http.expectJson GotForwardingCounts forwardingGroupCountsDecoder
        }



-- DECODER


forwardingGroupCountsDecoder : Decoder (List ForwardingGroupCount)
forwardingGroupCountsDecoder =
    field "countPerGroupName" (Decode.list forwardingGroupCountDecoder)


forwardingGroupCountDecoder : Decoder ForwardingGroupCount
forwardingGroupCountDecoder =
    Decode.map4 ForwardingGroupCount
        (field "key" string)
        (field "label" string)
        (field "inboundCount" float)
        (field "outboundCount" float)


forwardingGroupCountHistoryDecoder : Decoder ForwardingGroupCountHistory
forwardingGroupCountHistoryDecoder =
    Decode.map2 ForwardingGroupCountHistory
        (field "groupLabel" string)
        (field "countHistory" countsForTimestampListDecoder)


countsForTimestampListDecoder : Decoder (List CountsForTimestamp)
countsForTimestampListDecoder =
    Decode.list countsForTimestampDecoder


countsForTimestampDecoder : Decoder CountsForTimestamp
countsForTimestampDecoder =
    Decode.map3 CountsForTimestamp
        (field "countDate" float)
        (field "inbound" float)
        (field "outbound" float)
