module Pages.Note.Id_ exposing (Model, Msg, page)

import Browser.Dom as Dom
import Components.Editor as Editor
import Components.Error as Error
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
import Task
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
                [ case model.noteState of
                    Found note ->
                        Title.view
                            { title = model.title
                            , createdAt = Just note.createdAt
                            , onInput = UpdateTitle
                            }

                    _ ->
                        p [] [ text "Not Found" ]
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
    { noteState : NoteState
    , time : Posix
    , saveState : SaveState
    , showOptions : Bool
    , lastError : Maybe D.Error

    -- note content
    , title : String
    , editor : Editor.Model
    }


type NoteState
    = Loading
    | Found Note
    | NotFound


init : String -> () -> ( Model, Effect Msg )
init noteId () =
    ( { noteState = Loading
      , title = ""
      , editor = Editor.init { content = "", tags = [] }
      , time = Time.millisToPosix 0
      , saveState = Init
      , showOptions = False
      , lastError = Nothing
      }
    , Effect.batch
        [ Effect.getNote noteId
        , "note-content-editor"
            |> Dom.focus
            |> Task.attempt (\_ -> NoOp)
            |> Effect.sendCmd
        ]
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
    | DeleteNote Int
    | NoOp
    | ClearError


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )

        ToggleContextMenu ->
            ( { model | showOptions = not model.showOptions }, Effect.none )

        GotNote (Ok note) ->
            ( { model
                | noteState = Found note
                , title = note.title
                , editor = Editor.init note
              }
            , Effect.none
            )

        GotNote (Err err) ->
            ( { model | lastError = Just err }, Effect.none )

        SaveNote note ->
            let
                timedNote =
                    { note
                        | updatedAt = model.time
                        , tags = model.editor.tags
                        , title = model.title
                        , content = model.editor.content
                    }
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
            ( { model | title = title }
            , Effect.none
            )

        GotTime time ->
            ( { model | time = time }, Effect.none )

        NoteSaved ->
            -- TODO: check if the note saving is successfull
            ( { model | saveState = Saved }, Effect.none )

        DeleteNote id ->
            -- TODO: confirm deletion
            ( { model | showOptions = False }
            , Effect.batch
                [ Effect.deleteNote id
                , Effect.back
                ]
            )

        ClearError ->
            ( { model | lastError = Nothing }, Effect.none )



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
    case model.noteState of
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
                    }
                    |> Editor.view
                , Error.view { lastError = model.lastError, onClear = ClearError }
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
    case model.noteState of
        Found note ->
            div
                [ class <|
                    if model.showOptions then
                        "absolute z-50 divide-y dark:divide-black-400 top-14 right-8 flex flex-col dark:bg-black-300 rounded"

                    else
                        "hidden"
                ]
                [ button
                    [ onClick <| SaveNote note, class "px-4 py-2" ]
                    [ text "Save" ]
                , button
                    [ onClick <| DeleteNote note.id, class "px-4 py-2" ]
                    [ text "Delete" ]
                ]

        _ ->
            text ""
