module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Set exposing (Set)
import Shared.Model
import Shared.Msg
import Types.Theme as Theme



-- FLAGS


type alias Flags =
    { theme : Maybe String
    , favorites : Set String
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map2 Flags
        (Json.Decode.field "theme" <| Json.Decode.maybe Json.Decode.string)
        (Json.Decode.string
            |> Json.Decode.list
            |> Json.Decode.map Set.fromList
            |> Json.Decode.field "favorites")



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    case flagsResult of
        Ok flags ->
            ( { theme = Theme.fromMaybeString flags.theme
              , favorites = flags.favorites
              }
            , Effect.none
            )

        Err _ ->
            -- TODO: log the error
            ( { theme = Theme.System, favorites = Set.empty }
            , Effect.none
            )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Shared.Msg.NoOp ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Sub.none
