module Page.Tasks exposing (..)

import Browser.Navigation as Nav
import Html exposing (Html, div, h2, text)



-- MODEL


type alias Model =
    { infoText : String }



-- INIT


init : Nav.Key -> ( Model, Cmd Msg )
init _ =
    ( { infoText = "Hello Tasks!" }, Cmd.none )



-- UPDATE


type Msg
    = Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Nothing ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Tasks" ]
        , text model.infoText
        ]
