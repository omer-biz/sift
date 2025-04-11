module Pages.Home_ exposing (Model, Msg, page)

import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as D
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path
import Set exposing (Set)
import Shared
import Shared.Msg
import SvgAssets
import Time
import Types.Note as Note exposing (Note)
import Types.Pin as Pin exposing (Pin)
import Types.Tag as Tag exposing (Tag)
import Utils
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init shared.pinFilter
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
    , pins : Dict String Pin
    }


init :
    Maybe { selectedTags : List Int, searchQuery : String }
    -> ()
    -> ( Model, Effect Msg )
init pinFilter () =
    let
        ( searchQuery, selectedTags ) =
            case pinFilter of
                Just filter ->
                    ( filter.searchQuery, filter.selectedTags )

                Nothing ->
                    ( "", [] )
    in
    ( { searchQuery = searchQuery
      , notes = []
      , tags = []
      , selectedTags = Set.fromList selectedTags
      , pins = Dict.empty
      }
    , Effect.batch
        [ Effect.getNotes { search = searchQuery, tags = selectedTags }
        , Effect.getTags ""
        , Effect.getPins
        , Effect.sendSharedMsg Shared.Msg.ResetFilter
        ]
    )



-- UPDATE


type Msg
    = SearchQuery String
    | GotNotes (Result D.Error (List Note))
    | GotTags (Result D.Error (List Tag))
    | GotPins (Result D.Error (List Pin))
    | GotPin (Result D.Error Pin)
    | ToggleTag Int
    | TogglePins


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

        GotPin (Ok pin) ->
            let
                pinKey =
                    pin.searchQuery ++ ":" ++ Utils.tagIdsStr pin.tagIds
            in
            ( { model | pins = Dict.insert pinKey pin model.pins }, Effect.none )

        GotPin (Err err) ->
            let
                _ =
                    Debug.log "decode pin error: " err
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

        GotPins (Ok pins) ->
            let
                dictPins =
                    pins
                        |> List.map
                            (\pin ->
                                ( pin.searchQuery ++ ":" ++ Utils.tagIdsStr pin.tagIds
                                , pin
                                )
                            )
                        |> Dict.fromList
            in
            ( { model | pins = dictPins }, Effect.none )

        GotPins (Err err) ->
            let
                _ =
                    Debug.log "decode pins error: " err
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

        TogglePins ->
            let
                selectedTags =
                    Set.toList model.selectedTags

                query =
                    model.searchQuery ++ ":" ++ Utils.tagIdsStr selectedTags
            in
            case Dict.get query model.pins of
                Just pin ->
                    ( { model | pins = Dict.remove query model.pins }, Effect.removePin pin.id )

                Nothing ->
                    ( model
                    , Effect.createPin
                        { tagIds = selectedTags
                        , searchQuery = model.searchQuery
                        , noteCount = List.length model.notes
                        }
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Utils.receieve (D.list Note.decode) GotNotes Effect.recNotes
        , Utils.receieve (D.list Tag.decode) GotTags Effect.recTags
        , Utils.receieve (D.list Pin.decode) GotPins Effect.recPins
        , Utils.receieve Pin.decode GotPin Effect.recPin
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
            model.searchQuery ++ ":" ++ Utils.tagIdsStr (Set.toList model.selectedTags)

        isOn =
            Dict.member stem model.pins
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
        , button [ onClick TogglePins ]
            [ if isOn then
                SvgAssets.pinFilled "w-10 h-10"

              else
                SvgAssets.pinhollow "w-10 h-10 dark:text-white-100"
            ]
        ]
