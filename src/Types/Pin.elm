module Types.Pin exposing (Pin, decode, encode, Form)

import Json.Decode as D
import Json.Encode as E
import Types.Tag as Tag exposing (Tag)


type alias Pin =
    { id : Int
    , tagIds : List Int
    , tags : List Tag
    , searchQuery : String
    , noteCount : Int
    }


type alias Form =
    { tagIds : List Int
    , searchQuery : String
    , noteCount : Int
    }


decode : D.Decoder Pin
decode =
    D.map5 Pin
        (D.field "id" D.int)
        (D.field "tagIds" <| D.list D.int)
        (D.field "tags" <| D.list Tag.decode)
        (D.field "searchQuery" D.string)
        (D.field "noteCount" D.int)


encode : { a | tagIds : List Int, searchQuery : String, noteCount : Int } -> E.Value
encode pin =
    E.object
        [ ( "tagIds", E.list E.int pin.tagIds )
        , ( "searchQuery", E.string pin.searchQuery )
        , ( "noteCount", E.int pin.noteCount )
        ]
