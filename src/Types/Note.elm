module Types.Note exposing (Note, decode)

import Iso8601
import Json.Decode as D
import Time exposing (Posix)
import Types.Tag as Tag exposing (Tag)


type alias Note =
    { title : String
    , content : String
    , tags : List Tag
    , createdAt : Posix
    , updatedAt : Posix
    }


decode : D.Decoder Note
decode =
    D.map5 Note
        (D.field "title" D.string)
        (D.field "content" D.string)
        (D.field "tags" (D.list Tag.decode))
        (D.field "created_at" Iso8601.decoder)
        (D.field "updated_at" Iso8601.decoder)
