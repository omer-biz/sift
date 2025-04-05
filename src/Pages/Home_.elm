module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path exposing (Path)
import Shared
import SvgAssets
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout toLayout


toLayout : Model -> Layouts.Layout msg
toLayout model =
    Layouts.Scaffold { header = viewSearch model }



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Home_"
    , body =
        [ viewBody model
        , viewFAB
        ]
    }


viewBody : Model -> Html msg
viewBody model =
    text "Hello World!?"


viewFAB : Html msg
viewFAB =
   a
        [ class "fixed bottom-20 right-8 bg-aqua-200 text-white-100 p-4 rounded-full shadow-lg hover:bg-aqua-300 transition-colors"
        , Path.href Path.NewNote
        ]
        [ SvgAssets.add "w-6 w-6"
        , span [ class "sr-only" ] [ text "New Note" ]
        ]


viewSearch : Model -> Html msg
viewSearch model =
    Html.text "search"
