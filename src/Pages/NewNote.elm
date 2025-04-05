module Pages.NewNote exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onInput)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Task
import Time exposing (Posix)
import Types.Note as Note exposing (Note)
import Types.Tag as Tag exposing (Tag)
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
    Layouts.Scaffold { header = viewTitle model }



-- INIT


type alias Model =
    { note : Note
    , tagQuery : String
    , tagSugg : List Tag
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
    }


init : () -> ( Model, Effect Msg )
init () =
    ( initModel
    , Time.now
        |> Task.perform TimeNow
        |> Effect.sendCmd
    )



-- UPDATE


type Msg
    = UpdateField Field String
    | TimeNow Posix


type Field
    = Content
    | Title
    | TagQuery


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    let
        note =
            model.note
    in
    case msg of
        UpdateField Title value ->
            ( { model
                | note =
                    { note | title = value }
              }
            , Effect.none
            )

        UpdateField Content value ->
            ( { model
                | note =
                    { note | content = value }
              }
            , Effect.none
            )

        UpdateField TagQuery value ->
            ( { model
                | tagQuery = value
              }
            , Effect.none
            )

        TimeNow posix ->
            ( { model
                | note =
                    { note | createdAt = posix, updatedAt = posix }
              }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewTitle : Model -> Html Msg
viewTitle model =
    div [ class "flex justify-between items-center" ]
        [ div [ class "flex flex-col" ]
            [ input
                [ class "text-xl w-64 font-bold bg-transparent border-0 focus:ring-0 placeholder-gray-500 px-1 ml-1 mt-1 focus:outline-none focus:ring-1 focus:ring-blue-300"
                , placeholder "Note title..."
                , type_ "text"
                , value model.note.title
                , onInput <| UpdateField Title
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
                [ model.note.content
                    |> String.words
                    |> List.filter (\w -> w /= "")
                    |> List.length
                    |> String.fromInt
                    |> (\count -> text <| count ++ " words")
                ]
            , span [ class "mx-2" ]
                [ text "•" ]
            , span [ class "character-count" ]
                [ model.note.content
                    |> String.length
                    |> String.fromInt
                    |> (\count -> text <| count ++ " chars")
                ]
            ]
        ]


view : Model -> View Msg
view model =
    { title = "New Note"
    , body = [ viewEditor model ]
    }


viewEditor : Model -> Html Msg
viewEditor model =
    let
        note =
            model.note
    in
    div [ class "my-4 w-full bg-white-100 dark:bg-black-500 rounded-xl shadow-sm" ]
        [ form [ class "grid md:min-w-[700px] gap-3 min-h-[60vh]" ]
            [ -- note body
              fieldset [ class "edit-mode px-4 pt-4 border-r dark:border-gray-700" ]
                [ textarea
                    [ class "w-full h-64 p-2 border border-black-300 dark:border-black-400 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-300 dark:bg-black-300 dark:text-white-100"
                    , placeholder "Write your note here..."
                    , onInput <| UpdateField Content
                    , value note.content
                    ]
                    []
                ]

            -- tag query field
            , fieldset [ class "px-4" ]
                [ h2 [ class "text-lg font-semibold" ]
                    [ text "Tags" ]
                , div [ class "relative w-full" ]
                    [ input
                        [ class "mt-4 p-2 border border-black-300 dark:border-black-600 rounded-md w-full bg-white-100 dark:bg-black-300 text-black-500 dark:text-white-100 focus:outline-none focus:ring-1 focus:ring-blue-300"
                        , placeholder "Add a tag and press Enter"
                        , value model.tagQuery
                        , type_ "text"
                        , onInput <| UpdateField TagQuery
                        ]
                        []
                    ]
                ]
            , fieldset [ class "px-4 text-right space-x-4" ]
                [ button [ class "bg-red-100 hover:bg-red-200 rounded shadow px-2 py-1 text-white-100" ] [ text "Cancle" ]
                , button [ class "bg-blue-100 hover:bg-blue-200 rounded shadow px-2 py-1 text-white-100" ] [ text "Save" ]
                ]
            ]
        ]
