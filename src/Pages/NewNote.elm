module Pages.NewNote exposing (Model, Msg, page)

import Components.Editor as Editor
import Components.Title as Title
import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (..)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path
import Shared
import Task
import Time
import Types.Note exposing (Note)
import Types.Tag exposing (Tag)
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
    Layouts.Scaffold
        { header =
            Title.view
                { note = model.editor.note
                , onInput = UpdateTitle
                }
        }



-- INIT


type alias Model =
    { note : Note
    , tagQuery : String
    , tagSugg : List Tag
    , tags : Dict Int Tag
    , tagInput : Bool
    , editor : Editor.Model
    , time : Time.Posix
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


initModel : Model
initModel =
    { note = newNote
    , tagQuery = ""
    , tagSugg = []
    , tags = Dict.empty
    , tagInput = False
    , editor = Editor.init { note = Just newNote }
    , time = Time.millisToPosix 0
    }


init : () -> ( Model, Effect Msg )
init () =
    ( initModel
    , Task.perform InitTime Time.now
        |> Effect.sendCmd
    )



-- UPDATE


type Msg
    = CreateNote Note
    | EditorSent Editor.Msg
    | UpdateTitle String
    | InitTime Time.Posix
    | NoteCreated Int


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        CreateNote note ->
            ( model, Effect.createNote note )

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

        InitTime time ->
            let
                editor =
                    model.editor

                note =
                    editor.note
            in
            ( { model | editor = { editor | note = { note | createdAt = time, updatedAt = time } } }, Effect.none )

        NoteCreated id ->
            ( model, Effect.pushRoutePath <| Path.Note_Id_ { id = String.fromInt id } )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Editor.subscriptions model.editor
            |> Sub.map EditorSent
        , Effect.noteSaved NoteCreated
        ]



-- VIEW


view : Model -> View Msg
view model =
    { title = "New Note"
    , body =
        [ Editor.new
            { model = model.editor
            , toMsg = EditorSent
            , onSubmit = CreateNote
            }
            |> Editor.view
        ]
    }
