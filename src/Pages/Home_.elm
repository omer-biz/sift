module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as D
import Json.Encode as E
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path exposing (Path)
import Set exposing (Set)
import Shared
import SvgAssets
import Time
import Types.Note as Note exposing (Note)
import Types.Tag as Tag exposing (Tag)
import Utils
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init shared.favorites
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
    , favorites : Set String
    }


init : Set String -> () -> ( Model, Effect Msg )
init favorites () =
    ( { searchQuery = ""
      , notes = []
      , tags = []
      , selectedTags = Set.empty
      , favorites = favorites
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
    | ToggleFavorites


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SearchQuery value ->
            ( { model | searchQuery = value }
            , Effect.getNotes { search = value, tags = Set.toList model.selectedTags }
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
            let
                selectedTags =
                    if Set.member id model.selectedTags then
                        Set.remove id model.selectedTags

                    else
                        Set.insert id model.selectedTags
            in
            ( { model
                | selectedTags = selectedTags
              }
            , Effect.getNotes { search = model.searchQuery, tags = Set.toList selectedTags }
            )

        ToggleFavorites ->
            let
                stem =
                    toString model

                favorites =
                    if Set.member stem model.favorites then
                        Set.remove stem model.favorites

                    else if not <| List.isEmpty model.notes then
                        Set.insert stem model.favorites

                    else
                        model.favorites
            in
            ( { model | favorites = favorites }
            , Effect.saveFavorites <| Set.toList favorites
            )


toString : { a | selectedTags : Set Int, searchQuery : String } -> String
toString opts =
    E.object
        [ ( "selectedTags", E.list E.int <| Set.toList opts.selectedTags )
        , ( "searchQuery", E.string opts.searchQuery )
        ]
        |> E.encode 0



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
    { title = "Home"
    , body =
        [ viewBody model
        , viewFAB
        ]
    }


viewBody : Model -> Html Msg
viewBody model =
    main_ [ class "" ]
        [ viewTags model.selectedTags model.tags
        , viewNotes model.notes
        ]


viewNotes : List Note -> Html Msg
viewNotes notes =
    div [ class "mt-2 pt-0 pb-4 space-y-4 mx-4" ] <| List.map viewNote notes


viewNote : Note -> Html msg
viewNote note =
    let
        styleTag color =
            "border-" ++ color ++ "-400 bg-" ++ color ++ "-400 text-white-100"

        viewTag tag =
            span
                [ String.join " "
                    [ "text-xs px-2 py-[3px] rounded-md"
                    , styleTag tag.color
                    ]
                    |> class
                ]
                [ text <| "#" ++ tag.name ]
    in
    article [ class "pointer:cursor bg-white-200 dark:bg-black-400 p-4 rounded-lg shadow-sm hover:shadow-md transition-shadow items-start justify-between relative border border-1 border-black-200" ]
        [ h3 [ class "text-lg font-semibold text-gray-900 dark:text-gray-100" ]
            [ text note.title ]
        , p [ class "mt-1 text-gray-600 dark:text-gray-300 text-sm" ] [ text note.content ]
        , div [ class "mt-2 flex items-center gap-2" ]
            [ div [ class "flex items-center text-gray-500 dark:text-gray-400 text-sm min-w-32 gap-x-1" ]
                [ SvgAssets.cal "w-4 h-4 m4-1"
                , text <| Utils.formatDate Time.utc note.createdAt
                ]
            ]
        , div [ class "mt-2 text-sm flex flex-wrap gap-2" ] <|
            List.map viewTag note.tags
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
    let
        stem =
            toString model

        isOn =
            Set.member stem model.favorites
    in
    div [ class "flex w-full max-w-md ml-4 gap-x-4" ]
        [ input
            [ type_ "search"
            , placeholder "Search notes..."
            , class "flex-grow px-4 py-1 rounded-lg border border-black-300 dark:border-black-700 focus:outline-none focus:ring-1 focus:ring-pink-500 dark:focus:ring-pink-300 bg-white-100 dark:bg-black-500"
            , onInput SearchQuery
            , value model.searchQuery
            ]
            []
        , button [ onClick ToggleFavorites ]
            [ if isOn then
                SvgAssets.fullStar "w-10 h-10"

              else
                SvgAssets.hollowStar "w-10 h-10 dark:text-white-100"
            ]
        ]
