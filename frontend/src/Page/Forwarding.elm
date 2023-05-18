module Page.Forwarding exposing (..)

import Browser.Navigation as Nav
import Date exposing (Date)
import Html exposing (Html, div, h2, input, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Http
import Json.Decode as Decode exposing (Decoder, field, float, string)
import Task
import Url.Builder as UrlBuilder



-- MODEL


type alias Model =
    { selectedDate : String
    , forwardingGroupCounts : List ForwardingGroupCount
    }


type alias ForwardingGroupCount =
    { key : String
    , label : String
    , inboundCount : Float
    , outboundCount : Float
    }



-- INIT


init : Nav.Key -> ( Model, Cmd Msg )
init _ =
    ( { selectedDate = ""
      , forwardingGroupCounts = []
      }
    , Task.perform GotInitialDate Date.today
    )



-- UPDATE


type Msg
    = GotInitialDate Date
    | ChangeDate String
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

        ChangeDate newDate ->
            ( { model | selectedDate = newDate }, getAllForwardingCounts newDate )

        GotForwardingCounts result ->
            case result of
                Err _ ->
                    ( { model | forwardingGroupCounts = [] }, Cmd.none )

                Ok groupCounts ->
                    ( { model | forwardingGroupCounts = groupCounts }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Forwarding" ]
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



-- LOGIC


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
