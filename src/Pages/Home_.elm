module Pages.Home_ exposing (Model, Msg, page)

import Components.Error as Error
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
import SvgAssets
import Task
import Time
import Types.Note as Note exposing (Note)
import Types.Pin as Pin exposing (Pin)
import Types.Tag as Tag exposing (Tag)
import Utils
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init route.query
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

    -- TODO: have a Card type which will be responsible for loading the the tags
    -- and remove List Tag from the Note type
    , notes : List Note
    , tags : List Tag
    , selectedTags : Set Int
    , pins : Dict String Pin
    , today : Time.Posix
    , hiddenGroup : Set String
    , lastError : Maybe D.Error
    }


init :
    Dict String String
    -> ()
    -> ( Model, Effect Msg )
init query () =
    let
        searchQuery =
            case Dict.get "search" query of
                Just search ->
                    search

                Nothing ->
                    ""

        selectedTags =
            case Dict.get "tags" query of
                Just tagStr ->
                    tagStr
                        |> String.split ","
                        |> List.filterMap
                            (\tag ->
                                tag
                                    |> String.trim
                                    |> String.toInt
                            )

                Nothing ->
                    []
    in
    ( { searchQuery = searchQuery
      , notes = []
      , tags = []
      , selectedTags = Set.fromList selectedTags
      , pins = Dict.empty
      , today = Time.millisToPosix 0
      , hiddenGroup = Set.empty
      , lastError = Nothing
      }
    , Effect.batch
        [ Effect.getNotes { search = searchQuery, tags = selectedTags }
        , Effect.getTags ""
        , Effect.getPins
        , Time.now
            |> Task.perform Today
            |> Effect.sendCmd
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
    | OpenNote Int
    | Today Time.Posix
    | ToggleGroup String
    | ClearError


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClearError ->
            ( { model | lastError = Nothing }, Effect.none )

        SearchQuery value ->
            ( { model | searchQuery = value }
            , Effect.batch
                [ Effect.getNotes { search = value, tags = Set.toList model.selectedTags }
                , Effect.pushToRoute (Set.toList model.selectedTags) value
                ]
            )

        GotNotes (Ok notes) ->
            ( { model | notes = notes }, Effect.none )

        GotNotes (Err err) ->
            ( { model | lastError = Just err }, Effect.none )

        GotPin (Ok pin) ->
            let
                pinKey =
                    pin.searchQuery ++ ":" ++ Utils.tagIdsStr pin.tagIds
            in
            ( { model | pins = Dict.insert pinKey pin model.pins }, Effect.none )

        GotPin (Err err) ->
            ( { model | lastError = Just err }, Effect.none )

        GotTags (Ok tags) ->
            ( { model | tags = tags }, Effect.none )

        GotTags (Err err) ->
            ( { model | lastError = Just err }, Effect.none )

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
            ( { model | lastError = Just err }, Effect.none )

        ToggleTag id ->
            let
                selectedTags =
                    if Set.member id model.selectedTags then
                        Set.remove id model.selectedTags

                    else
                        Set.insert id model.selectedTags

                tagList =
                    Set.toList selectedTags
            in
            ( { model
                | selectedTags = selectedTags
              }
            , Effect.batch
                [ Effect.getNotes { search = model.searchQuery, tags = tagList }
                , Effect.pushToRoute tagList model.searchQuery
                ]
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

        OpenNote id ->
            ( model, Effect.pushRoutePath <| Path.Note_Id_ { id = String.fromInt id } )

        Today today ->
            ( { model | today = today }, Effect.none )

        ToggleGroup group ->
            let
                groups =
                    if Set.member group model.hiddenGroup then
                        Set.remove group model.hiddenGroup

                    else
                        Set.insert group model.hiddenGroup
            in
            ( { model | hiddenGroup = groups }, Effect.none )



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
        , Error.view
            { lastError = model.lastError, onClear = ClearError }
        ]
    }


viewBody : Model -> Html Msg
viewBody model =
    main_ [ class "" ]
        [ viewTags model.selectedTags model.tags
        , viewNotes model
        ]


groupNotesByDate : Time.Posix -> List Note -> List ( String, List Note )
groupNotesByDate today notes =
    let
        labelFor date =
            case Utils.diffDays today date of
                0 ->
                    "Today"

                1 ->
                    "Yesterday"

                _ ->
                    Utils.formatDate Time.utc date

        labelNotes : Note -> List ( String, List Note ) -> List ( String, List Note )
        labelNotes note labeledNotes =
            let
                currentLabel =
                    labelFor note.updatedAt
            in
            case labeledNotes of
                [] ->
                    [ ( currentLabel, [ note ] ) ]

                ( existingLabel, existingNotes ) :: rest ->
                    if existingLabel == currentLabel then
                        ( existingLabel, note :: existingNotes ) :: rest

                    else
                        ( currentLabel, [ note ] ) :: labeledNotes
    in
    List.foldl labelNotes [] notes
        |> List.reverse
        |> List.map (\( label, ns ) -> ( label, List.reverse ns ))


viewNotes : Model -> Html Msg
viewNotes model =
    let
        groups =
            groupNotesByDate model.today model.notes

        renderGroup ( label, ns ) =
            div []
                [ button [ onClick <| ToggleGroup label, class "mt-2 mb-2 flex items-center gap-2" ]
                    [ div [ class "text-[17px] flex items-center text-gray-900 dark:text-gray-400 text-sm min-w-32 gap-x-1" ]
                        [ if Set.member label model.hiddenGroup then
                            SvgAssets.calDownArrow "w-6 h-6 m4-1"

                          else
                            SvgAssets.calLines "w-6 h-6 m4-1"
                        , text label
                        ]
                    ]
                , if Set.member label model.hiddenGroup then
                    text ""

                  else
                    div [ class "space-y-3" ] <| List.map viewNote ns
                ]
    in
    div [ class "mt-2 pt-0 pb-4 space-y-4 mx-4" ] <| List.map renderGroup groups


viewNote : Note -> Html Msg
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
    article
        [ onClick <| OpenNote note.id
        , class "pointer:cursor bg-white-200 dark:bg-black-400 p-4 rounded-lg shadow-sm hover:shadow-md transition-shadow items-start justify-between relative border border-1 border-black-200"
        ]
        [ h3 [ class "text-lg font-semibold text-gray-900 dark:text-gray-100" ]
            [ text note.title ]
        , p [ class "mt-1 text-gray-600 dark:text-gray-300 text-sm" ] [ text note.content ]
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
