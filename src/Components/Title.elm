module Components.Title exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onInput)
import Time
import Utils


view : { a | title : String, onInput : String -> msg, createdAt : Maybe Time.Posix } -> Html msg
view opts =
    div [ class "flex justify-between items-center w-full" ]
        [ div [ class "flex flex-col" ]
            [ input
                [ class "text-xl w-64 font-bold bg-transparent border-0 focus:ring-0 placeholder-gray-500 px-1 ml-1 mt-1 focus:outline-none focus:ring-1 focus:ring-blue-300"
                , placeholder "Note title..."
                , type_ "text"
                , value opts.title
                , onInput opts.onInput
                ]
                []
            , case opts.createdAt of
                Just createdAt ->
                    div [ class "text-sm text-gray-500 px-2" ]
                        [ text "Created: "
                        , span [ class "note-date" ]
                            [ text <| Utils.formatDate Time.utc createdAt ]
                        ]

                _ ->
                    text ""
            ]
        ]
