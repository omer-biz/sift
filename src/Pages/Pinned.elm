module Pages.Pinned exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick, stopPropagationOn)
import Json.Decode as D
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path exposing (Path)
import Shared
import Shared.Msg
import SvgAssets
import Types.Pin as Pin exposing (Pin)
import Types.Tag as Tag
import Utils
import View exposing (View)
import Components.Error as Error


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout toLayout


toLayout : Model -> Layouts.Layout Msg
toLayout model =
    Layouts.Scaffold { header = viewHeader model }



-- INIT


type alias Model =
    { pins : List Pin
    , lastError : Maybe D.Error
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { pins = [], lastError = Nothing }
    , Effect.getPins
    )



-- UPDATE


type Msg
    = GotPins (Result D.Error (List Pin))
    | Delete Pin
    | FilterNotes Pin
    | NoOp
    | ClearError


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )

        GotPins (Ok pins) ->
            ( { model | pins = pins }
            , Effect.none
            )

        GotPins (Err err) ->
            ( { model | lastError = Just err }, Effect.none )

        Delete pin ->
            ( { model
                | pins =
                    List.filter (\p -> p.id /= pin.id) model.pins
              }
            , Effect.removePin pin.id
            )

        FilterNotes pin ->
            ( model
            , Effect.pushToRoute
                (List.map .id pin.tags)
                pin.searchQuery
            )

        ClearError ->
            ( { model | lastError = Nothing }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Utils.receieve (D.list Pin.decode) GotPins Effect.recPins



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pinned Searches"
    , body =
        [ viewPins model.pins
        , Error.view { lastError = model.lastError, onClear = ClearError }
        ]
    }


viewPins : List Pin -> Html Msg
viewPins pins =
    let
        viewFavorite pin =
            article
                [ class "pointer:cursor bg-white-200 dark:bg-black-400 p-4 rounded-lg shadow-sm hover:shadow-md transition-shadow items-start justify-between relative border border-1 border-black-200 flex items-center"
                , onClick <| FilterNotes pin
                ]
                [ div []
                    [ h2 [] [ span [ class "font-bold underline" ] [ text <| "'" ++ pin.searchQuery ++ "'" ] ]
                    , div [ class "mt-2 text-sm flex flex-wrap gap-2" ] <|
                        List.map (Tag.view "") pin.tags
                    ]
                , span [ class "flex items-center text-xl gap-x-2" ]
                    [ text <| String.fromInt pin.noteCount
                    , button
                        [ onclk <| Delete pin
                        ]
                        [ SvgAssets.delete "w-6 h-6" ]
                    ]
                ]
    in
    div [ class "mt-2 pt-0 pb-4 space-y-4 mx-4" ] <|
        List.map viewFavorite pins


onclk : msg -> Attribute msg
onclk msg =
    stopPropagationOn "click" <| D.map (\a -> ( a, True )) (D.succeed msg)


viewHeader : Model -> Html Msg
viewHeader _ =
    h1 [ class "ml-4 text-2xl font-semibold" ] [ text "Pinned Searches" ]
