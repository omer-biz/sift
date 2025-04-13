module Pages.Note.Id_ exposing (Model, Msg, page)

import Components.Editor as Editor
import Components.Title as Title
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as D
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import SvgAssets
import Time exposing (Posix)
import Types.Note as Note exposing (Note)
import Utils
import View exposing (View)


page : Shared.Model -> Route { id : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init route.params.id
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout toLayout


toLayout : Model -> Layouts.Layout Msg
toLayout model =
    Layouts.Scaffold
        { header =
            div [ class "flex w-full" ]
                [ Title.view
                    { note = model.editor.note
                    , onInput = UpdateTitle
                    }
                , div [ class "flex items-center gap-x-3" ]
                    [ viewSaveState model.saveState
                    , button [ onClick ToggleContextMenu ]
                        [ SvgAssets.threeDot "w-7 h-7" ]
                    ]
                , viewOptions model
                ]
        }



-- INIT


type alias Model =
    { note : NoteState
    , editor : Editor.Model
    , time : Posix
    , saveState : SaveState
    , showOptions : Bool
    }


type NoteState
    = Loading
    | Found Note
    | NotFound


newNote : Note
newNote =
    { id = 0
    , title = ""
    , content = ""
    , tags = []
    , createdAt = Time.millisToPosix 0
    , updatedAt = Time.millisToPosix 0
    }


init : String -> () -> ( Model, Effect Msg )
init noteId () =
    ( { note = Loading
      , editor = Editor.init <| { note = Just newNote }
      , time = Time.millisToPosix 0
      , saveState = Init
      , showOptions = False
      }
    , Effect.getNote noteId
    )



-- UPDATE


type Msg
    = GotNote (Result D.Error Note)
    | EditorSent Editor.Msg
    | SaveNote Note
    | UpdateTitle String
    | GotTime Time.Posix
    | ToggleContextMenu
    | NoteSaved
    | ContextMenu Option


type Option
    =
     Delete
    | Archive


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ToggleContextMenu ->
            ( { model | showOptions = not model.showOptions }, Effect.none )

        GotNote (Ok note) ->
            ( { model
                | note = Found note
                , editor = Editor.init { note = Just note }
              }
            , Effect.none
            )

        GotNote (Err err) ->
            let
                _ =
                    Debug.log "note error " err
            in
            ( { model | note = NotFound }, Effect.none )

        SaveNote note ->
            let
                timedNote =
                    { note | updatedAt = model.time }
            in
            ( { model | saveState = Saving, showOptions = False }, Effect.saveNote timedNote )

        EditorSent innerMsg ->
            Editor.update
                { msg = innerMsg
                , model = model.editor
                , toModel = \editor -> { model | editor = editor }
                , toMsg = EditorSent
                }

        UpdateTitle title ->
            let
                editor =
                    model.editor

                note =
                    editor.note
            in
            ( { model | editor = { editor | note = { note | title = title } } }, Effect.none )

        GotTime time ->
            ( { model | time = time }, Effect.none )

        NoteSaved ->
            -- TODO: check if the note saving is successfull
            ( { model | saveState = Saved }, Effect.none )

        ContextMenu opt ->
            ( { model | showOptions = False }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Utils.receieve Note.decode GotNote Effect.recNote
        , Time.every 1000 GotTime
        , Editor.subscriptions model.editor
            |> Sub.map EditorSent
        , Effect.noteSaved <| \_ -> NoteSaved
        ]



-- VIEW


view : Model -> View Msg
view model =
    case model.note of
        NotFound ->
            { title = "note not found"
            , body = [ text "not with that id is not found" ]
            }

        Found note ->
            { title = note.title
            , body =
                [ Editor.new
                    { model = model.editor
                    , toMsg = EditorSent
                    , onSubmit = SaveNote
                    }
                    |> Editor.view
                ]
            }

        Loading ->
            { title = "loading..."
            , body = [ text "Loading..." ]
            }


type SaveState
    = Init
    | Saving
    | Saved
    | Error


viewSaveState : SaveState -> Html msg
viewSaveState state =
    case state of
        Init ->
            text ""

        Saving ->
            span
                [ class "text-sm text-yellow-400 animate-pulse" ]
                [ text "Saving..." ]

        Saved ->
            span
                [ class "text-sm text-green-400 inline-flex items-center gap-1 transition-opacity duration-500 opacity-100" ]
                [ checkIcon, text "Saved" ]

        Error ->
            span
                [ class "text-sm text-red-400" ]
                [ text "Error saving" ]


checkIcon : Html msg
checkIcon =
    span
        [ class "text-green-400 text-base" ]
        [ text "✅" ]


viewOptions : Model -> Html Msg
viewOptions model =
    div
        [ class <|
            if model.showOptions then
                "absolute  divide-y dark:divide-black-400 top-14 right-8 flex flex-col dark:bg-black-300 rounded"

            else
                "hidden"
        ]
        [ button
            [ onClick <| SaveNote model.editor.note, class "px-4 py-2" ]
            [ text "Save" ]
        , button
            [ onClick <| ContextMenu Delete, class "px-4 py-2" ]
            [ text "Delete" ]
        , button
            [ onClick <| ContextMenu Archive, class "px-4 py-2 disabled" ]
            [ text "Archive" ]
        ]
