module Components.Editor exposing (Model, Msg(..), init, new, subscriptions, update, view)

import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onBlur, onClick, onFocus, onInput, onSubmit)
import Json.Decode as D
import Time
import Types.Note exposing (Note)
import Types.Tag as Tag exposing (Tag)
import Utils


type Editor msg
    = Settings
        { model : Model
        , toMsg : Msg -> msg
        , onSubmit : Note -> msg
        }


new :
    { model : Model, toMsg : Msg -> msg, onSubmit : Note -> msg }
    -> Editor msg
new props =
    Settings
        { model = props.model
        , toMsg = props.toMsg
        , onSubmit = props.onSubmit
        }


newNote : Note
newNote =
    { id = 0
    , title = ""
    , content = ""
    , tags = []
    , createdAt = Time.millisToPosix 0
    , updatedAt = Time.millisToPosix 0
    }


type alias Model =
    { note : Note
    , tagQuery : String
    , tagSugg : List Tag
    , tags : Dict Int Tag
    , tagInputFocus : Bool
    }


init : { a | note : Maybe Note } -> Model
init opts =
    let
        note =
            Maybe.withDefault newNote opts.note
    in
    { note = note
    , tagQuery = ""
    , tagSugg = []
    , tags = Dict.fromList <| (List.map (\tag -> ( tag.id, tag ))) note.tags
    , tagInputFocus = False
    }


type Msg
    = UpdateField Field String
    | GotTags (Result D.Error (List Tag))
    | AddTagSugg Tag
    | RemoveTag Tag
    | ToggleTagInput Bool
    | Cancel
    | NoOp


type Field
    = Content
    | TagQuery


update :
    { model : Model
    , toModel : Model -> model
    , msg : Msg
    , toMsg : Msg -> msg
    }
    -> ( model, Effect msg )
update props =
    let
        model =
            props.model

        toParentModel ( innerModel, effect ) =
            ( props.toModel innerModel, effect )
    in
    toParentModel <|
        let
            note =
                model.note
        in
        case props.msg of
            UpdateField Content value ->
                ( { model
                    | note =
                        { note | content = value }
                  }
                , Effect.none
                )

            UpdateField TagQuery value ->
                if String.trim value == "" then
                    ( { model | tagQuery = value, tagSugg = [] }, Effect.none )

                else
                    ( { model | tagQuery = value }, Effect.getTags value )

            GotTags (Ok tags) ->
                ( { model | tagSugg = tags }, Effect.none )

            GotTags (Err err) ->
                let
                    _ =
                        Debug.log "decode tags error: " err
                in
                ( model, Effect.none )

            AddTagSugg tag ->
                let
                    dictTags =
                        Dict.insert tag.id tag model.tags
                in
                ( { model
                    | tagQuery = ""
                    , tags = dictTags
                    , note =
                        { note
                            | tags =
                                dictTags
                                    |> Dict.toList
                                    |> List.map Tuple.second
                        }
                  }
                , Effect.none
                )

            RemoveTag tag ->
                ( { model | tags = Dict.remove tag.id model.tags }, Effect.none )

            ToggleTagInput value ->
                ( { model | tagInputFocus = value }, Effect.none )

            Cancel ->
                ( model, Effect.back )

            NoOp ->
                ( model, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Utils.receieve (D.list Tag.decode) GotTags Effect.recTags


view : Editor msg -> Html msg
view (Settings settings) =
    let
        model =
            settings.model

        note =
            model.note

        viewTagSuggs =
            let
                colorToStyle color =
                    "bg-" ++ color ++ "-400"

                viewSugg tag =
                    li
                        [ onClick <| (settings.toMsg << AddTagSugg) tag
                        , class <| "px-4 py-2 cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-700 dark:text-white flex "
                        ]
                        [ span [ class <| "w-2 mr-2 rounded " ++ colorToStyle tag.color ] [], text tag.name ]
            in
            if model.tagQuery /= "" then
                ul [ class "absolute w-full bg-white-200 dark:bg-black-600 border dark:border-black-700 rounded-lg mt-1 shadow-lg " ] <|
                    List.map viewSugg model.tagSugg

            else
                text ""

        viewTags tags =
            if not <| Dict.isEmpty tags then
                let
                    listTags =
                        tags
                            |> Dict.toList
                            |> List.map Tuple.second
                in
                div [ class "flex flex-wrap gap-2 mt-2" ] <|
                    List.map (\tag -> span [ onClick <| (settings.toMsg << RemoveTag) tag ] [ Tag.view tag ]) listTags

            else
                text ""
    in
    div [ class "my-4 w-full bg-white-100 dark:bg-black-500 rounded-xl shadow-sm" ]
        [ form [ onSubmit <| settings.toMsg NoOp, class "grid md:min-w-[700px] gap-3 min-h-[60vh]" ]
            [ -- note body
              fieldset [ class "edit-mode px-4 pt-4 border-r dark:border-gray-700" ]
                [ textarea
                    [ class "w-full h-64 p-2 border border-black-300 dark:border-black-400 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-300 dark:bg-black-300 dark:text-white-100"
                    , placeholder "Write your note here..."
                    , onInput <| (settings.toMsg << UpdateField Content)
                    , value note.content
                    ]
                    []
                ]

            -- tag query field
            , fieldset [ class "px-4" ]
                [ h2 [ class "text-lg font-semibold" ]
                    [ text "Tags" ]
                , viewTags model.tags
                , div [ class "relative w-full" ]
                    [ input
                        [ class "mt-4 p-2 border border-black-300 dark:border-black-600 rounded-md w-full bg-white-100 dark:bg-black-300 text-black-500 dark:text-white-100 focus:outline-none focus:ring-1 focus:ring-blue-300"
                        , placeholder "Add a tag and press Enter"
                        , value model.tagQuery
                        , type_ "text"
                        , onInput <| (settings.toMsg << UpdateField TagQuery)
                        , onFocus <| (settings.toMsg << ToggleTagInput) True
                        , onBlur <| (settings.toMsg << ToggleTagInput) False
                        ]
                        []
                    , viewTagSuggs
                    ]
                ]
            , fieldset [ class "px-4 text-right space-x-4" ]
                [ button [ onClick <| settings.toMsg Cancel, class "bg-red-100 hover:bg-red-200 rounded shadow px-2 py-1 text-white-100" ] [ text "Cancle" ]
                , button [ onClick <| settings.onSubmit model.note, class "bg-blue-100 hover:bg-blue-200 rounded shadow px-2 py-1 text-white-100" ] [ text "Save" ]
                ]
            ]
        ]
