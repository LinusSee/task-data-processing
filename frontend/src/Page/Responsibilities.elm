module Page.Responsibilities exposing (..)

import Browser.Navigation as Nav
import Chart as C
import Chart.Attributes as CA
import Date
import Dict exposing (Dict)
import Html exposing (Html, button, div, input, option, select, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder, field, float, string)
import Task
import Time exposing (Month(..))
import Url.Builder as UrlBuilder



-- Model


type alias Model =
    { selectedDate : String
    , selectedGroup : String
    , groupsForSelection : List String
    , history : HistoryModel
    , responsibilityGroupCount : List LabeledCount
    }


type alias LabeledCount =
    { key : String
    , label : String
    , count : Float
    }


type alias HistoryModel =
    { pastDays : String
    , selectedGroups : List String
    , historySelection : ResponsibilityHistorySelection
    }


type ResponsibilityHistorySelection
    = NoGroupSelected
    | GroupSelected (Dict String String) ResponsibilityHistoryData


type ResponsibilityHistoryData
    = OneGroupData (List OneGroupDataRecord)
    | TwoGroupsData (List TwoGroupsDataRecord)
    | ThreeGroupsData (List ThreeGroupsDataRecord)
    | FourGroupsData (List FourGroupsDataRecord)
    | FiveGroupsData (List FiveGroupsDataRecord)


type alias OneGroupDataRecord =
    { date : Float, groupOne : Float }


type alias TwoGroupsDataRecord =
    { date : Float, groupOne : Float, groupTwo : Float }


type alias ThreeGroupsDataRecord =
    { date : Float, groupOne : Float, groupTwo : Float, groupThree : Float }


type alias FourGroupsDataRecord =
    { date : Float, groupOne : Float, groupTwo : Float, groupThree : Float, groupFour : Float }


type alias FiveGroupsDataRecord =
    { date : Float, groupOne : Float, groupTwo : Float, groupThree : Float, groupFour : Float, groupFive : Float }



-- INIT


init : Nav.Key -> ( Model, Cmd Msg )
init _ =
    ( { selectedDate = ""
      , selectedGroup = ""
      , groupsForSelection = []
      , history =
            { pastDays = "14"
            , selectedGroups = []
            , historySelection = NoGroupSelected
            }
      , responsibilityGroupCount = []
      }
    , Task.perform GotInitialDate Date.today
    )



-- UPDATE


type Msg
    = GotInitialDate Date.Date
    | ChangeDate String
    | ChangeGroupSelection String
    | ChangePastDays String
    | ConfirmGroupSelection
    | GotResponsibilityGroupCount (Result Http.Error (List LabeledCount))
    | GotGroupCountHistory (Result Http.Error ( Dict String String, ResponsibilityHistoryData ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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

        ChangePastDays newPastDays ->
            let
                history =
                    model.history
            in
            ( { model
                | history = { history | pastDays = newPastDays }
              }
            , getHistoryData newPastDays history.selectedGroups
            )

        ChangeGroupSelection newGroup ->
            ( { model | selectedGroup = newGroup }, Cmd.none )

        ConfirmGroupSelection ->
            if List.length model.history.selectedGroups <= 5 then
                let
                    history =
                        model.history

                    newSelectedGroups =
                        model.selectedGroup :: history.selectedGroups
                in
                ( { model
                    | selectedGroup = ""
                    , history = { history | selectedGroups = newSelectedGroups }
                  }
                , getHistoryData history.pastDays newSelectedGroups
                )

            else
                ( model, Cmd.none )

        GotResponsibilityGroupCount result ->
            case result of
                Err _ ->
                    ( { model | responsibilityGroupCount = [] }, Cmd.none )

                Ok counts ->
                    let
                        groupKeys =
                            List.map .key counts
                    in
                    ( { model | responsibilityGroupCount = counts, groupsForSelection = groupKeys }, Cmd.none )

        GotGroupCountHistory response ->
            case response of
                Err errorMsg ->
                    Debug.log (Debug.toString errorMsg)
                        ( { model
                            | history =
                                { pastDays = model.history.pastDays
                                , selectedGroups = model.history.selectedGroups
                                , historySelection = NoGroupSelected
                                }
                          }
                        , Cmd.none
                        )

                Ok ( labels, historyData ) ->
                    ( { model
                        | history =
                            { pastDays = model.history.pastDays
                            , selectedGroups = model.history.selectedGroups
                            , historySelection = GroupSelected labels historyData
                            }
                      }
                    , Cmd.none
                    )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewHistorySelect model.history.pastDays model.selectedGroup model.groupsForSelection
        , text (Debug.toString model.history.selectedGroups)
        , viewHistory model.history.historySelection
        , viewDateInput model.selectedDate
        , viewResponsibilitiesCountTable model.responsibilityGroupCount
        ]


viewHistory : ResponsibilityHistorySelection -> Html Msg
viewHistory data =
    case data of
        NoGroupSelected ->
            text "No groups selected yet"

        GroupSelected labels groupData ->
            div [] [ viewHistoryChart labels groupData ]


viewHistorySelect : String -> String -> List String -> Html Msg
viewHistorySelect pastDays currentlySelectedGroup groupsForSelection =
    let
        options =
            option [ value "" ] [ text "-" ]
                :: List.map (\group -> option [ value group ] [ text group ]) groupsForSelection
    in
    div []
        [ select [ onInput ChangeGroupSelection, value currentlySelectedGroup ]
            options
        , button [ type_ "button", onClick ConfirmGroupSelection ] [ text "Ok" ]
        , viewPastDaysInput pastDays
        , text currentlySelectedGroup
        ]


viewHistoryChart : Dict String String -> ResponsibilityHistoryData -> Html Msg
viewHistoryChart labels data =
    case data of
        OneGroupData oneGroupData ->
            viewHistoryLineChart <| oneGroupSeries labels oneGroupData

        TwoGroupsData twoGroupData ->
            viewHistoryLineChart <| twoGroupsSeries labels twoGroupData

        ThreeGroupsData threeGroupData ->
            viewHistoryLineChart <| threeGroupsSeries labels threeGroupData

        FourGroupsData fourGroupData ->
            viewHistoryLineChart <| fourGroupsSeries labels fourGroupData

        FiveGroupsData fiveGroupData ->
            viewHistoryLineChart <| fiveGroupsSeries labels fiveGroupData


viewHistoryLineChart : C.Element a Msg -> Html Msg
viewHistoryLineChart lineSeries =
    div [ class "line-chart" ]
        [ C.chart
            [ CA.height 300
            , CA.width 600
            ]
            [ C.xLabels [ CA.withGrid, CA.format timestampToDateString ]
            , C.yLabels [ CA.withGrid ]
            , lineSeries
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


oneGroupSeries : Dict String String -> List OneGroupDataRecord -> C.Element OneGroupDataRecord Msg
oneGroupSeries labels groupData =
    C.series .date
        [ C.interpolated .groupOne [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group1" labels |> Maybe.withDefault "Group1")
        ]
        groupData


twoGroupsSeries : Dict String String -> List TwoGroupsDataRecord -> C.Element TwoGroupsDataRecord Msg
twoGroupsSeries labels groupData =
    C.series .date
        [ C.interpolated .groupOne [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group1" labels |> Maybe.withDefault "Group1")
        , C.interpolated .groupTwo [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group2" labels |> Maybe.withDefault "Group2")
        ]
        groupData


threeGroupsSeries : Dict String String -> List ThreeGroupsDataRecord -> C.Element ThreeGroupsDataRecord Msg
threeGroupsSeries labels groupData =
    C.series .date
        [ C.interpolated .groupOne [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group1" labels |> Maybe.withDefault "Group1")
        , C.interpolated .groupTwo [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group2" labels |> Maybe.withDefault "Group2")
        , C.interpolated .groupThree [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group3" labels |> Maybe.withDefault "Group3")
        ]
        groupData


fourGroupsSeries : Dict String String -> List FourGroupsDataRecord -> C.Element FourGroupsDataRecord Msg
fourGroupsSeries labels groupData =
    C.series .date
        [ C.interpolated .groupOne [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group1" labels |> Maybe.withDefault "Group1")
        , C.interpolated .groupTwo [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group2" labels |> Maybe.withDefault "Group2")
        , C.interpolated .groupThree [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group3" labels |> Maybe.withDefault "Group3")
        , C.interpolated .groupFour [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group4" labels |> Maybe.withDefault "Group4")
        ]
        groupData


fiveGroupsSeries : Dict String String -> List FiveGroupsDataRecord -> C.Element FiveGroupsDataRecord Msg
fiveGroupsSeries labels groupData =
    C.series .date
        [ C.interpolated .groupOne [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group1" labels |> Maybe.withDefault "Group1")
        , C.interpolated .groupTwo [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group2" labels |> Maybe.withDefault "Group2")
        , C.interpolated .groupThree [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group3" labels |> Maybe.withDefault "Group3")
        , C.interpolated .groupFour [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group4" labels |> Maybe.withDefault "Group4")
        , C.interpolated .groupFive [ CA.monotone ] [ CA.circle ]
            |> C.named (Dict.get "group5" labels |> Maybe.withDefault "Group5")
        ]
        groupData


viewPastDaysInput : String -> Html Msg
viewPastDaysInput pastDays =
    input [ type_ "text", onInput ChangePastDays, value pastDays ] []


viewDateInput : String -> Html Msg
viewDateInput dateString =
    input [ type_ "date", onInput ChangeDate, value dateString ] []


viewResponsibilitiesCountTable : List LabeledCount -> Html Msg
viewResponsibilitiesCountTable labeledCounts =
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



-- LOGIC


getHistoryData : String -> List String -> Cmd Msg
getHistoryData pastDays selectedGroups =
    Http.get
        { url =
            UrlBuilder.crossOrigin "http://localhost:5000/responsibility-groups"
                [ "history" ]
                [ UrlBuilder.string "past-days" pastDays, UrlBuilder.string "group-keys" (String.join "," selectedGroups) ]
        , expect = Http.expectJson GotGroupCountHistory (responsibilityGroupCountHistoryDecoder (List.length selectedGroups))
        }



-- DECODER


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


responsibilityGroupCountHistoryDecoder : Int -> Decoder ( Dict String String, ResponsibilityHistoryData )
responsibilityGroupCountHistoryDecoder selectedGroupCount =
    let
        historyDecoder =
            case selectedGroupCount of
                1 ->
                    field "groupCountHistory" oneGroupHistoryDecoder

                2 ->
                    field "groupCountHistory" twoGroupsHistoryDecoder

                3 ->
                    field "groupCountHistory" threeGroupsHistoryDecoder

                4 ->
                    field "groupCountHistory" fourGroupsHistoryDecoder

                _ ->
                    field "groupCountHistory" fiveGroupsHistoryDecoder
    in
    Decode.map2 Tuple.pair
        (field "groupLabels" (Decode.dict string))
        historyDecoder


oneGroupHistoryDecoder : Decoder ResponsibilityHistoryData
oneGroupHistoryDecoder =
    Decode.map2 OneGroupDataRecord
        (field "countDate" float)
        (field "group1" float)
        |> Decode.list
        |> Decode.map OneGroupData


twoGroupsHistoryDecoder : Decoder ResponsibilityHistoryData
twoGroupsHistoryDecoder =
    Decode.map3 TwoGroupsDataRecord
        (field "countDate" float)
        (field "group1" float)
        (field "group2" float)
        |> Decode.list
        |> Decode.map TwoGroupsData


threeGroupsHistoryDecoder : Decoder ResponsibilityHistoryData
threeGroupsHistoryDecoder =
    Decode.map4 ThreeGroupsDataRecord
        (field "countDate" float)
        (field "group1" float)
        (field "group2" float)
        (field "group3" float)
        |> Decode.list
        |> Decode.map ThreeGroupsData


fourGroupsHistoryDecoder : Decoder ResponsibilityHistoryData
fourGroupsHistoryDecoder =
    Decode.map5 FourGroupsDataRecord
        (field "countDate" float)
        (field "group1" float)
        (field "group2" float)
        (field "group3" float)
        (field "group4" float)
        |> Decode.list
        |> Decode.map FourGroupsData


fiveGroupsHistoryDecoder : Decoder ResponsibilityHistoryData
fiveGroupsHistoryDecoder =
    Decode.map6 FiveGroupsDataRecord
        (field "countDate" float)
        (field "group1" float)
        (field "group2" float)
        (field "group3" float)
        (field "group4" float)
        (field "group5" float)
        |> Decode.list
        |> Decode.map FiveGroupsData
