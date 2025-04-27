module Api exposing (..)

import Http
import Json.Decode as D
import Json.Encode as E


createUser :
    { a
        | email : String
        , password : String
        , onResponse :
            Result Http.Error { token : String }
            -> msg
    }
    -> Cmd msg
createUser opts =
    Http.post
        { url = "http://localhost:3000/api/auth/register"
        , body =
            Http.jsonBody <|
                E.object
                    [ ( "email", E.string opts.email )
                    , ( "password", E.string opts.password )
                    ]
        , expect = Http.expectJson opts.onResponse decodeToken
        }


decodeToken : D.Decoder { token : String }
decodeToken =
    D.map (\token -> { token = token })
        (D.field "token" D.string)
