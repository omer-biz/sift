module Types.Tag exposing (Tag, decode)

import Json.Decode as D


type alias Tag =
    { id : Int, name : String, color : String }


decode : D.Decoder Tag
decode =
    D.map3 Tag
        (D.field "id" D.int)
        (D.field "name" D.string)
        (D.field "color" D.string)
