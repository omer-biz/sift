module Pages.NewNote exposing (Model, Msg, page)

import Components.Editor as Editor
import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onInput)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
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
    Layouts.Scaffold { header = viewTitle model.editor.note }



-- INIT


type alias Model =
    { note : Note
    , tagQuery : String
    , tagSugg : List Tag
    , tags : Dict Int Tag
    , tagInput : Bool
    , editor : Editor.Model
    }


newNote : Note
newNote =
    { title = ""
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
    , editor = Editor.init <| { note = Just newNote }
    }


init : () -> ( Model, Effect Msg )
init () =
    ( initModel
    , Effect.none
    )



-- UPDATE


type Msg
    = CreateNote Note
    | EditorSent Editor.Msg
    | UpdateTitle String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        CreateNote note ->
            let
                _ =
                    Debug.log "note" note
            in
            ( model, Effect.none)

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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Editor.subscriptions model.editor
        |> Sub.map EditorSent



-- VIEW


viewTitle : Note -> Html Msg
viewTitle note =
    div [ class "flex justify-between items-center" ]
        [ div [ class "flex flex-col" ]
            [ input
                [ class "text-xl w-64 font-bold bg-transparent border-0 focus:ring-0 placeholder-gray-500 px-1 ml-1 mt-1 focus:outline-none focus:ring-1 focus:ring-blue-300"
                , placeholder "Note title..."
                , type_ "text"
                , value note.title
                , onInput UpdateTitle
                ]
                []
            , div [ class "text-sm text-gray-500 px-2" ]
                [ text "Created: "
                , span [ class "note-date" ]
                    [ text "now" ]
                , span [ class "mx-2" ]
                    [ text "•" ]
                , text "Last saved: "
                , span [ class "mx-2" ]
                    [ text "now" ]
                ]
            ]
        , div [ class " px-4 flex items-center text-sm text-gray-500" ]
            [ span [ class "word-count" ]
                [ note.content
                    |> String.words
                    |> List.filter (\w -> w /= "")
                    |> List.length
                    |> String.fromInt
                    |> (\count -> text <| count ++ " words")
                ]
            , span [ class "mx-2" ]
                [ text "•" ]
            , span [ class "character-count" ]
                [ note.content
                    |> String.length
                    |> String.fromInt
                    |> (\count -> text <| count ++ " chars")
                ]
            ]
        ]


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
