module Types.Note exposing (Note, decode, encode, encodeNew)

import Iso8601
import Json.Decode as D
import Json.Encode as E
import Time exposing (Posix)
import Types.Tag as Tag exposing (Tag)


type alias Note =
    { id : Int
    , title : String
    , content : String
    , tags : List Tag
    , createdAt : Posix
    , updatedAt : Posix
    }


decode : D.Decoder Note
decode =
    D.map6 Note
        (D.field "id" D.int)
        (D.field "title" D.string)
        (D.field "content" D.string)
        (D.field "tags" (D.list Tag.decode))
        (D.field "createdAt" Iso8601.decoder)
        (D.field "updatedAt" Iso8601.decoder)


encode : Note -> E.Value
encode note =
    E.object
        [ ( "id", E.int note.id )
        , ( "title", E.string note.title )
        , ( "content", E.string note.content )
        , ( "tagIds", E.list E.int <| List.map .id note.tags )
        , ( "createdAt", Iso8601.encode note.createdAt )
        , ( "updatedAt", Iso8601.encode note.updatedAt )
        ]


encodeNew :
    { a | title : String,
          content : String, tags : List { b | id : Int }, createdAt : Posix, updatedAt : Posix }
        -> E.Value
encodeNew note =
    E.object
        [ ( "title", E.string note.title )
        , ( "content", E.string note.content )
        , ( "tagIds", E.list E.int <| List.map .id note.tags )
        , ( "createdAt", Iso8601.encode note.createdAt )
        , ( "updatedAt", Iso8601.encode note.updatedAt )
        ]
