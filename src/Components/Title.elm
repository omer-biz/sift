module Components.Title exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import SvgAssets
import Time
import Types.Note exposing (Note)
import Utils


view : { a | note : Note, onInput : String -> msg } -> Html msg
view opts =
    let
        note =
            opts.note
    in
    div [ class "flex justify-between items-center w-full" ]
        [ div [ class "flex flex-col" ]
            [ input
                [ class "text-xl w-64 font-bold bg-transparent border-0 focus:ring-0 placeholder-gray-500 px-1 ml-1 mt-1 focus:outline-none focus:ring-1 focus:ring-blue-300"
                , placeholder "Note title..."
                , type_ "text"
                , value note.title
                , onInput opts.onInput
                ]
                []
            , div [ class "text-sm text-gray-500 px-2" ]
                [ text "Created: "
                , span [ class "note-date" ]
                    [ text <| Utils.formatDate Time.utc opts.note.createdAt ]
                ]
            ]
        ]
