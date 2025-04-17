module Pages.NewNote exposing (Model, Msg, page)

import Components.Editor as Editor
import Components.Title as Title
import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
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
            div [ class "flex w-full" ]
                [ Title.view
                    { title = model.title
                    , onInput = UpdateTitle
                    , createdAt = Nothing
                    }
                , div [ class "flex items-center gap-x-3" ]
                    [ button
                        [ onClick CreateNote
                        , class "text-white-100 bg-green-300 rounded-xl px-3 py-1 text-xl"
                        ]
                        [ text "create" ]
                    ]
                ]
        }



-- INIT


type alias Model =
    { title : String
    , editor : Editor.Model
    , time : Time.Posix
    }


initModel : Model
initModel =
    { title = ""
    , editor = Editor.init { content = "", tags = [] }
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
    = CreateNote
    | EditorSent Editor.Msg
    | UpdateTitle String
    | InitTime Time.Posix
    | NoteCreated Int


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        CreateNote ->
            ( model
            , Effect.createNote
                { title = model.title, tags = model.editor.tags, content = model.editor.content }
            )

        EditorSent innerMsg ->
            Editor.update
                { msg = innerMsg
                , model = model.editor
                , toModel = \editor -> { model | editor = editor }
                , toMsg = EditorSent
                }

        UpdateTitle title ->
            ( { model | title = title }, Effect.none )

        InitTime time ->
            ( { model | time = time }, Effect.none )

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
            }
            |> Editor.view
        ]
    }
