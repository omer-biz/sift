module Pages.Register exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder)
import Html.Events exposing (onClick)
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path
import Shared
import SvgAssets
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { email : String
    , password : String
    , passwordConfirm : String
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { email = ""
      , password = ""
      , passwordConfirm = ""
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = NoOp
    | UpdateField Field String
    | GoBack


type Field
   = Password
   | PasswordConfirm
   | Email


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )

        GoBack ->
            ( model, Effect.back )

        UpdateField field value ->
            ( updateField field value model, Effect.none )

updateField : Field -> String -> Model -> Model
updateField field value model =
    case field of
        Password ->
            { model | password =  value }
        PasswordConfirm ->
            { model | passwordConfirm = value}
        Email ->
            { model | email = value }


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Register | Sift"
    , body =
        [ viewHeader
        , div [ class "w-full mt-8" ]
            [ -- title and oauth buttons
              div [ class "w-full space-y-4" ]
                [ h1 [ class "text-3xl text-center underline" ] [ text "Sign Up" ]
                , p [ class "text-center mx-8" ] [ text "Register an account to have your notes synced. Read more about syncing ", a [ class "underline text-blue-200" ] [ text "here." ] ]

                -- socials
                , div [ class "flex gap-x-4 justify-center" ]
                    [ a [ class "p-2 px-6 border border-white-400 rounded-xl bg-white-200 flex gap-x-2 items-center" ]
                        [ SvgAssets.google "w-8 h-8", text "Google" ]
                    , a [ class "p-2 px-6 border border-white-400 rounded-xl bg-white-200 flex gap-x-2 items-center" ]
                        [ SvgAssets.github "w-8 h-8", text "Github" ]
                    ]
                ]
            , div [ class "text-center text-xl mt-4" ]
                [ text "Or" ]

            -- email and password
            , div [ class "flex flex-col justify-center gap-y-4 mx-8 mt-4" ]
                [ div [] [ input [ class "bg-white-200 w-full px-4 py-2 rounded-xl border border-white-300 focus:outline-none focus:ring-2 focus:ring-green-400", placeholder "email" ] [] ]
                , div [] [ input [ class "bg-white-200 w-full px-4 py-2 rounded-xl border border-white-300 focus:outline-none focus:ring-2 focus:ring-green-400", placeholder "password" ] [] ]
                , div [] [ input [ class "bg-white-200 w-full px-4 py-2 rounded-xl border border-white-300 focus:outline-none focus:ring-2 focus:ring-green-400", placeholder "password confirm" ] [] ]
                , button [ class "w-full rounded-xl bg-blue-200 text-white-100 py-2" ] [ text "Continue" ]
                ]

            -- extra
            , div [ class "mt-4 text-sm text-center" ]
                [ p [] [ text "Do you have account? ", a [ class "text-green-600 font-medium" ] [ text "Sign In" ] ]
                , p [] [ a [ class "text-green-600 font-medium", Path.href Path.Home_ ] [ text "Continue As a guest" ] ]
                ]
            ]
        ]
    }


viewHeader : Html Msg
viewHeader =
    header [ class "m-2" ]
        [ button [ onClick GoBack, class "m-2" ]
            [ SvgAssets.arrowLeft "w-8 h-8" ]
        ]
