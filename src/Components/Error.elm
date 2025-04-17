module Components.Error exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as D


view : { a | lastError : Maybe D.Error, onClear : msg } -> Html msg
view opts =
    case opts.lastError of
        Just error ->
            div
                [ class "fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 " ]
                [ div
                    [ class "bg-white p-6 rounded-lg shadow-lg max-w-md w-full mx-4 border border-black-400" ]
                    [ p [ class "text-red-600 mb-4" ] [ text <| D.errorToString error ]
                    , button
                        [ class "mt-2 px-4 py-2 bg-blue-100 hover:bg-blue-200 text-white-100 rounded"
                        , onClick opts.onClear
                        ]
                        [ text "Close" ]
                    ]
                ]

        Nothing ->
            text ""
