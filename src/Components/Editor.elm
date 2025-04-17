module Components.Editor exposing (Model, Msg(..), init, new, subscriptions, update, view)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, type_, value)
import Html.Events exposing (onBlur, onClick, onFocus, onInput, onSubmit)
import Json.Decode as D
import Types.Tag as Tag exposing (Tag)
import Utils


type Editor msg
    = Settings
        { model : Model
        , toMsg : Msg -> msg
        }


new :
    { model : Model
    , toMsg : Msg -> msg
    }
    -> Editor msg
new props =
    Settings
        { model = props.model
        , toMsg = props.toMsg
        }


type alias Model =
    { content : String
    , tags : List Tag
    , tagSugg : List Tag
    , tagQuery : String
    , tagInputFocus : Bool
    , showModal : Bool
    , selectedColor : String
    }


tagColors : List String
tagColors =
    -- TODO: move this to the store
    [ "violet", "amber", "emerald", "indigo", "pink", "red", "blue", "sky", "green", "purple" ]


init : { a | content : String, tags : List Tag } -> Model
init opts =
    { content = opts.content
    , tags = opts.tags
    , tagQuery = ""
    , tagSugg = []
    , tagInputFocus = False
    , showModal = False
    , selectedColor = "violet"
    }


type Msg
    = UpdateField Field String
    | GotTags (Result D.Error (List Tag))
    | AddTagSugg Tag
    | RemoveTag Tag
    | ToggleTagInput Bool
    | NoOp
    | ToggleModal Bool
    | CreateTag
    | SelectColor String
    | TagCreated (Result D.Error Tag)


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
        case props.msg of
            UpdateField Content value ->
                ( { model | content = value }
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
                ( { model
                    | tagQuery = ""
                    , tags = tag :: model.tags
                  }
                , Effect.none
                )

            RemoveTag tag ->
                ( { model | tags = List.filter (\t -> t.id /= tag.id) model.tags }
                , Effect.none
                )

            ToggleTagInput value ->
                ( { model | tagInputFocus = value }, Effect.none )

            NoOp ->
                ( model, Effect.none )


            ToggleModal value ->
                ( { model | showModal = value }, Effect.none )


            CreateTag ->
                let
                    tag =
                        { name = model.tagQuery, color = model.selectedColor }
                in
                ( model, Effect.createTag tag )

            SelectColor color ->
                let
                    _ =
                        Debug.log "color" color
                in
                ( { model | selectedColor = color }, Effect.none )

            TagCreated (Ok tag) ->
                ( { model | tags = tag :: model.tags }, Effect.none )

            TagCreated (Err err) ->
                let
                    _ =
                        Debug.log "tag creation error" err
                in
                ( model, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Utils.receieve (D.list Tag.decode) GotTags Effect.recTags
        , Utils.receieve Tag.decode TagCreated Effect.tagSaved
        ]


view : Editor msg -> Html msg
view (Settings settings) =
    let
        model =
            settings.model

        viewTagSuggs =
            let
                colorToStyle color =
                    "bg-" ++ color ++ "-400"

                viewSugg tag =
                    span
                        [ onClick <| (settings.toMsg << AddTagSugg) tag
                        , class <| "px-4 border-b border-black-500 py-2 cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-700 dark:text-white flex "
                        ]
                        [ span [ class <| "w-2 mr-2 rounded " ++ colorToStyle tag.color ] [], text tag.name ]
            in
            if model.tagQuery /= "" then
                div [ class "w-full mt-4 overflow-y-auto" ] <|
                    List.map viewSugg model.tagSugg

            else
                text ""

        viewTags : List Tag -> List (Html msg)
        viewTags tags =
            if not <| List.isEmpty tags then
                List.map (\tag -> button [ onClick <| (settings.toMsg << RemoveTag) tag ] [ Tag.view " text-md p-1 px-2 rounded-xl" tag ]) tags

            else
                []

        viewModal =
            if model.showModal then
                div [ onClick (settings.toMsg <| ToggleModal False), class "fixed inset-0 z-50 bg-[#181818]/50 flex items-center justify-center" ]
                    [ div [ Utils.onclk <| settings.toMsg NoOp, class "bg-white-300 dark:bg-black-400 rounded-2xl shadow-xl w-full max-w-md p-6 relative h-96 space-y-4" ]
                        [ div [ class "" ]
                            [ div [ class "flex gap-x-2" ]
                                [ input
                                    [ class "p-2 border border-black-300 dark:border-black-600 rounded-md w-full bg-white-100 dark:bg-black-200 text-black-500 dark:text-white-100 focus:outline-none focus:ring-1 focus:ring-blue-300"
                                    , placeholder "Add a tag and press Enter"
                                    , value model.tagQuery
                                    , type_ "text"
                                    , onInput <| (settings.toMsg << UpdateField TagQuery)
                                    , onFocus <| (settings.toMsg << ToggleTagInput) True
                                    , onBlur <| (settings.toMsg << ToggleTagInput) False
                                    ]
                                    []
                                , select [ onInput <| settings.toMsg << SelectColor, class "p-2 border border-black-300 dark:border-black-600 rounded-md bg-white-100 dark:bg-black-200 text-black-500 dark:text-white-100 focus:outline-none focus:ring-1 focus:ring-blue-300" ] <|
                                    List.map (\options -> option [] [ text options ]) tagColors
                                , button
                                    [ onClick <| settings.toMsg CreateTag
                                    , class "rounded w-32 text-white-100 bg-blue-200"
                                    ]
                                    [ text "create" ]
                                ]
                            , viewTagSuggs
                            ]
                        ]
                    ]

            else
                text ""
    in
    div [ class "w-full bg-white-100 dark:bg-black-500 h-full" ]
        [ form [ onSubmit <| settings.toMsg NoOp, class "md:min-w-[700px] min-h-[60vh] flex flex-col" ]
            [ -- tags
              fieldset []
                [ div [ class "flex flex-wrap gap-2 items-center my-2 px-4" ] <|
                    button
                        [ onClick (settings.toMsg <| ToggleModal True)
                        , class "bg-blue-100 hover:bg-blue-200 rounded-2xl shadow px-2 py-1 text-white-100"
                        ]
                        [ text "+ add tag" ]
                        :: viewTags model.tags
                ]

            -- note body
            , fieldset [ class " h-screen dark:border-gray-700 flex-grow flex flex-col" ]
                [ textarea
                    [ id "note-content-editor"
                    , class "w-full bg-white-200 p-4 flex-grow dark:bg-black-400 dark:text-white-100 h-full focus:outline-none"
                    , placeholder "Write your note here..."
                    , onInput <| (settings.toMsg << UpdateField Content)
                    , value model.content
                    ]
                    []
                ]
            ]
        , viewModal
        ]
