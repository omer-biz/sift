port module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute
    , pushRoutePath, replaceRoutePath
    , loadExternalUrl, back
    , map, toCmd
    , createNote, createPin, createTag, deleteNote, getNote, getNotes, getPins, getTags, noteSaved, pushToRoute, recNote, recNotes, recPin, recPins, recTags, removePin, saveNote, savePins, sendSharedMsg, switchTheme, tagSaved
    )

{-|

@docs Effect

@docs none, batch
@docs sendCmd, sendMsg

@docs pushRoute, replaceRoute
@docs pushRoutePath, replaceRoutePath
@docs loadExternalUrl, back

@docs map, toCmd

-}

import Browser.Navigation
import Dict exposing (Dict)
import Json.Encode as E
import Route
import Route.Path
import Shared.Model
import Shared.Msg
import Task
import Types.Note as Note
import Types.Pin as Pin exposing (Pin)
import Types.Tag as Tag
import Url exposing (Url)
import Utils


type Effect msg
    = -- BASICS
      None
    | Batch (List (Effect msg))
    | SendCmd (Cmd msg)
      -- ROUTING
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
    | Back
      -- SHARED
    | SendSharedMsg Shared.Msg.Msg
    | SendMessageToJavaScript
        { tag : String
        , data : E.Value
        }



-- BASICS


{-| Don't send any effect.
-}
none : Effect msg
none =
    None


{-| Send multiple effects at once.
-}
batch : List (Effect msg) -> Effect msg
batch =
    Batch


{-| Send a normal `Cmd msg` as an effect, something like `Http.get` or `Random.generate`.
-}
sendCmd : Cmd msg -> Effect msg
sendCmd =
    SendCmd


{-| Send a message as an effect. Useful when emitting events from UI components.
-}
sendMsg : msg -> Effect msg
sendMsg msg =
    Task.succeed msg
        |> Task.perform identity
        |> SendCmd



-- ROUTING


{-| Set the new route, and make the back button go back to the current route.
-}
pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
pushRoute route =
    PushUrl (Route.toString route)


{-| Same as `Effect.pushRoute`, but without `query` or `hash` support
-}
pushRoutePath : Route.Path.Path -> Effect msg
pushRoutePath path =
    PushUrl (Route.Path.toString path)


{-| Set the new route, but replace the previous one, so clicking the back
button **won't** go back to the previous route.
-}
replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
replaceRoute route =
    ReplaceUrl (Route.toString route)


{-| Same as `Effect.replaceRoute`, but without `query` or `hash` support
-}
replaceRoutePath : Route.Path.Path -> Effect msg
replaceRoutePath path =
    ReplaceUrl (Route.Path.toString path)


{-| Redirect users to a new URL, somewhere external to your web application.
-}
loadExternalUrl : String -> Effect msg
loadExternalUrl =
    LoadExternalUrl


{-| Navigate back one page
-}
back : Effect msg
back =
    Back



-- INTERNALS


{-| Elm Land depends on this function to connect pages and layouts
together into the overall app.
-}
map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        SendCmd cmd ->
            SendCmd (Cmd.map fn cmd)

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        Back ->
            Back

        LoadExternalUrl url ->
            LoadExternalUrl url

        SendSharedMsg sharedMsg ->
            SendSharedMsg sharedMsg

        SendMessageToJavaScript message ->
            SendMessageToJavaScript message


{-| Elm Land depends on this function to perform your effects.
-}
toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : Shared.Model.Model
    , fromSharedMsg : Shared.Msg.Msg -> msg
    , batch : List msg -> msg
    , toCmd : msg -> Cmd msg
    }
    -> Effect msg
    -> Cmd msg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        SendCmd cmd ->
            cmd

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        Back ->
            Browser.Navigation.back options.key 1

        LoadExternalUrl url ->
            Browser.Navigation.load url

        SendSharedMsg sharedMsg ->
            Task.succeed sharedMsg
                |> Task.perform options.fromSharedMsg

        SendMessageToJavaScript message ->
            outgoing message


port outgoing : { tag : String, data : E.Value } -> Cmd msg


sendSharedMsg : Shared.Msg.Msg -> Effect msg
sendSharedMsg msg =
    SendSharedMsg msg


switchTheme : String -> Effect msg
switchTheme theme =
    SendMessageToJavaScript
        { tag = "SWITCH_THEME"
        , data = E.string theme
        }


getNotes : { a | search : String, tags : List Int } -> Effect msg
getNotes options =
    SendMessageToJavaScript
        { tag = "GET_NOTES"
        , data =
            E.object
                [ ( "search", E.string options.search )
                , ( "tagIds", E.list E.int options.tags )
                ]
        }


deleteNote : Int -> Effect msg
deleteNote id =
    SendMessageToJavaScript
        { tag = "DELETE_NOTE"
        , data =
            E.int id
        }


getTags : String -> Effect msg
getTags query =
    SendMessageToJavaScript
        { tag = "GET_TAGS"
        , data = E.string query
        }


savePins : List Pin -> Effect msg
savePins pins =
    SendMessageToJavaScript
        { tag = "SAVE_PINS"
        , data = E.list Pin.encode pins
        }


getPins : Effect msg
getPins =
    SendMessageToJavaScript
        { tag = "GET_PINS"
        , data = E.null
        }


createPin : Pin.Form -> Effect msg
createPin pin =
    SendMessageToJavaScript
        { tag = "CREATE_PIN"
        , data = Pin.encode pin
        }


removePin : Int -> Effect msg
removePin id =
    SendMessageToJavaScript
        { tag = "DELETE_PIN"
        , data = E.int id
        }


pushToRoute : List Int -> String -> Effect msg
pushToRoute tags query =
    let
        tagStr =
            tags
                |> List.map String.fromInt
                |> String.join ","
    in
    pushRoute
        { path = Route.Path.Home_
        , query =
            Dict.empty
                |> Utils.ternery (query /= "") (Dict.insert "search" query) identity
                |> Utils.ternery (tags /= []) (Dict.insert "tags" tagStr) identity
        , hash = Nothing
        }


getNote : String -> Effect msg
getNote noteId =
    SendMessageToJavaScript
        { tag = "GET_NOTE"
        , data = E.string noteId
        }


saveNote : Note.Note -> Effect msg
saveNote note =
    SendMessageToJavaScript
        { tag = "SAVE_NOTE"
        , data = Note.encode note
        }


createNote :
    { a
        | title : String
        , content : String
        , tags : List { b | id : Int }
    }
    -> Effect msg
createNote note =
    SendMessageToJavaScript
        { tag = "CREATE_NOTE"
        , data = Note.encodeNew note
        }


createTag : { name : String, color : String } -> Effect msg
createTag tag =
    SendMessageToJavaScript
        { tag = "CREATE_TAG"
        , data = Tag.encodeNew tag
        }


port recNotes : (E.Value -> msg) -> Sub msg


port recNote : (E.Value -> msg) -> Sub msg


port recTags : (E.Value -> msg) -> Sub msg


port recPins : (E.Value -> msg) -> Sub msg


port recPin : (E.Value -> msg) -> Sub msg


port noteSaved : (Int -> msg) -> Sub msg


port tagSaved : (E.Value -> msg) -> Sub msg
