module Pages.Note.Id_ exposing (Model, Msg, page)

import Components.Editor as Editor
import Components.Title as Title
import Effect exposing (Effect)
import Html exposing (..)
import Json.Decode as D
import Layouts
import Page exposing (Page)
import Platform exposing (Task)
import Route exposing (Route)
import Shared
import Task exposing (Task)
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
            Title.view
                { note = model.editor.note
                , onInput = UpdateTitle
                }
        }



-- INIT


type alias Model =
    { note : NoteState
    , editor : Editor.Model
    , time : Posix
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


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
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

                _ =
                    Debug.log "note" note
            in
            ( model, Effect.saveNote timedNote )

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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Utils.receieve Note.decode GotNote Effect.recNote
        , Time.every 1000 GotTime
        ,
    Editor.subscriptions model.editor
        |> Sub.map EditorSent
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
