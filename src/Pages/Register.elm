module Pages.Register exposing (Model, Msg, page)

import Api
import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path
import Shared
import SvgAssets
import Validate exposing (fromErrors, ifBlank, ifInvalidEmail, validate)
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
    , errors : Dict String String
    , isLoading : Bool
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { email = ""
      , password = ""
      , passwordConfirm = ""
      , errors = Dict.empty
      , isLoading = False
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = NoOp
    | UpdateField Field String
    | GoBack
    | SubmitForm
    | GotNewUser (Result Http.Error User)


type alias User =
    { token : String }


type Field
    = Password
    | PasswordConfirm
    | Email


toString : Field -> String
toString field =
    case field of
        Password ->
            "password"

        PasswordConfirm ->
            "password confirm"

        Email ->
            "Email"


fromFieldToInputType : Field -> String
fromFieldToInputType field =
    case field of
        Email ->
            "email"

        Password ->
            "password"

        PasswordConfirm ->
            "password"


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

        SubmitForm ->
            let
                errorToDict errors =
                    errors
                        |> List.map (Tuple.mapFirst toString)
                        |> Dict.fromList

                validatedForm =
                    validate modelValidator model
                        |> Result.mapError errorToDict
            in
            case validatedForm of
                Ok _ ->
                    ( { model | errors = Dict.empty, isLoading = True }
                    , Effect.sendCmd <|
                        Api.createUser
                            { onResponse = GotNewUser
                            , password = model.password
                            , email = model.email
                            }
                    )

                Err errors ->
                    ( { model | errors = errors }, Effect.none )

        GotNewUser _ ->
            ( model, Effect.none )


updateField : Field -> String -> Model -> Model
updateField field value model =
    case field of
        Password ->
            { model | password = value }

        PasswordConfirm ->
            { model | passwordConfirm = value }

        Email ->
            { model | email = value }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    let
        viewField : String -> Field -> Html Msg
        viewField val field =
            div []
                [ input
                    [ class "bg-white-200 w-full px-4 py-2 rounded-xl border border-white-300 focus:outline-none focus:ring-2 focus:ring-green-400"
                    , placeholder <| toString field
                    , value val
                    , onInput <| UpdateField field
                    , type_ <| fromFieldToInputType field
                    ]
                    []
                , case Dict.get (toString field) model.errors of
                    Just err ->
                        span [ class "ml-2 text-red-200" ] [ text err ]

                    Nothing ->
                        text ""
                ]
    in
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
                [ viewField model.email Email
                , viewField model.password Password
                , viewField model.passwordConfirm PasswordConfirm
                , button [ onClick SubmitForm, class "w-full rounded-xl bg-blue-200 text-white-100 py-2 flex items-center justify-center " ]
                    [ text "Continue"

                    , if model.isLoading then
                        div [ class "ml-2 animate-spin rounded-full h-5 w-5 border-4 border-white-300 border-t-transparent" ] []

                      else
                        text ""
                    ]
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



-- validator


modelValidator : Validate.Validator ( Field, String ) Model
modelValidator =
    Validate.all
        [ ifBlank .password ( Password, "can't be emtpy" )
        , ifBlank .passwordConfirm ( PasswordConfirm, "can't be emtpy" )
        , ifBlank .email ( Email, "can't be emtpy" )
        , ifInvalidEmail .email (\_ -> ( Email, "please enter a valid email" ))
        , fromErrors modeltoErrors
        ]


modeltoErrors : Model -> List ( Field, String )
modeltoErrors model =
    let
        passwordLength =
            String.length model.password
    in
    if passwordLength > 32 then
        [ ( Password, "can't be greater than 32" ) ]

    else if passwordLength < 8 then
        [ ( Password, "can't be less than 8" ) ]

    else if model.passwordConfirm /= model.password then
        [ ( PasswordConfirm, "password confirm must match password" ) ]

    else
        []
