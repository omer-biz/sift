module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as D
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path exposing (Path)
import Set exposing (Set)
import Shared
import SvgAssets
import Types.Note as Note exposing (Note)
import Types.Tag as Tag exposing (Tag)
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


toLayout : Model -> Layouts.Layout Msg
toLayout model =
    Layouts.Scaffold { header = viewSearch model }



-- INIT


type alias Model =
    { searchQuery : String
    , notes : List Note
    , tags : List Tag
    , selectedTags : Set Int
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { searchQuery = ""
      , notes = []
      , tags = []
      , selectedTags = Set.empty
      }
    , Effect.batch
        [ Effect.getNotes { search = "", tags = [] }
        , Effect.getTags
        ]
    )



-- UPDATE


type Msg
    = SearchQuery String
    | GotNotes (Result D.Error (List Note))
    | GotTags (Result D.Error (List Tag))
    | ToggleTag Int


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SearchQuery value ->
            ( { model | searchQuery = value }
            , Effect.none
            )

        GotNotes (Ok notes) ->
            ( { model | notes = notes }, Effect.none )

        GotNotes (Err err) ->
            let
                _ =
                    Debug.log "decode notes error: " err
            in
            ( model, Effect.none )

        GotTags (Ok tags) ->
            ( { model | tags = tags }, Effect.none )

        GotTags (Err err) ->
            let
                _ =
                    Debug.log "decode tags error: " err
            in
            ( model, Effect.none )

        ToggleTag id ->
            ( { model
                | selectedTags =
                    if Set.member id model.selectedTags then
                        Set.remove id model.selectedTags

                    else
                        Set.insert id model.selectedTags
              }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Effect.receiveNotes (\value -> D.decodeValue (D.list Note.decode) value |> GotNotes)
        , Effect.receiveTags (\value -> D.decodeValue (D.list Tag.decode) value |> GotTags)
        ]



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Home_"
    , body =
        [ viewBody model
        , viewFAB
        ]
    }


viewBody : Model -> Html Msg
viewBody model =
    main_ [ class "" ]
        [ viewTags model.selectedTags model.tags
        ]


viewTags : Set Int -> List Tag -> Html Msg
viewTags selected tags =
    let
        borderColor color =
            "border-" ++ color ++ "-400"

        dynStyle tag =
            if Set.member tag.id selected then
                "bg-" ++ tag.color ++ "-400 text-white-100"

            else
                "text-" ++ tag.color ++ "-400"

        viewTag tag =
            button
                [ String.join " "
                    [ "px-2 py-[2px] border border-2 rounded-xl"
                    , borderColor tag.color
                    , dynStyle tag
                    ]
                    |> class
                , onClick <| ToggleTag tag.id
                ]
                [ text <| "#" ++ tag.name ]
    in
    tags
        |> List.map viewTag
        |> div [ class "mx-2 py-4 flex gap-x-3 overflow-x-auto" ]


viewFAB : Html msg
viewFAB =
    a
        [ class "fixed bottom-20 right-8 bg-aqua-200 text-white-100 p-4 rounded-full shadow-lg hover:bg-aqua-300 transition-colors"
        , Path.href Path.NewNote
        ]
        [ SvgAssets.add "w-6 w-6"
        , span [ class "sr-only" ] [ text "New Note" ]
        ]


viewSearch : Model -> Html Msg
viewSearch model =
    div [ class "flex-1 max-w-2xl mx-4" ]
        [ input
            [ type_ "search"
            , placeholder "Search notes..."
            , class "w-full px-4 py-1 rounded-lg border border-black-300 dark:border-black-700 focus:outline-none focus:ring-1 focus:ring-pink-500 dark:focus:ring-pink-300 bg-white-100 dark:bg-black-500"
            , onInput SearchQuery
            , value model.searchQuery
            ]
            []
        ]
