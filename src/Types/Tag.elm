module Types.Tag exposing (Tag, decode, view)

import Html
import Html.Attributes as Attr
import Json.Decode as D


type alias Tag =
    { id : Int, name : String, color : String }


decode : D.Decoder Tag
decode =
    D.map3 Tag
        (D.field "id" D.int)
        (D.field "name" D.string)
        (D.field "color" D.string)


view : Tag -> Html.Html msg
view tag =
    let
        styleTag =
            "border-" ++ tag.color ++ "-400 bg-" ++ tag.color ++ "-400 text-white-100"
    in
    Html.span
        [ String.join " "
            [ "text-xs px-2 py-[3px] rounded-md"
            , styleTag
            ]
            |> Attr.class
        ]
        [ Html.text <| "#" ++ tag.name ]
