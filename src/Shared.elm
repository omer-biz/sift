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
import Route.Path as Path
import Shared.Model
import Shared.Msg
import Types.Theme as Theme



-- FLAGS


type alias Flags =
    { theme : Maybe String
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "theme" <| Json.Decode.maybe Json.Decode.string)



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    let
        theme =
            case flagsResult of
                Ok flags ->
                    Theme.fromMaybeString flags.theme

                Err _ ->
                    Theme.System
    in
    ( { theme = theme, pinFilter = Nothing }, Effect.none )



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

        Shared.Msg.SelectPin pinFilter ->
            ( { model | pinFilter = Just pinFilter }
            , Effect.pushRoutePath Path.Home_
            )

        Shared.Msg.ResetFilter ->
            ( { model | pinFilter = Nothing }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Sub.none
