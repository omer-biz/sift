module Layouts.Scaffold exposing (Model, Msg, Props, layout, map)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, href, rel, target)
import Html.Events exposing (onClick)
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import SvgAssets
import Utils
import View exposing (View)


type alias Props contentMsg =
    { header : Html contentMsg
    }


layout : Props contentMsg -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init
        , update = update
        , view = view props
        , subscriptions = subscriptions
        }


map : (msg1 -> msg2) -> Props msg1 -> Props msg2
map fn props =
    { header = Html.map fn props.header }



-- MODEL


type alias Model =
    { sidebarOpen : Bool
    }


init : () -> ( Model, Effect Msg )
init _ =
    ( { sidebarOpen = False }
    , Effect.none
    )



-- UPDATE


type Msg
    = ToggleNavBar


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ToggleNavBar ->
            ( { model | sidebarOpen = not model.sidebarOpen }
            , Effect.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Props contentMsg -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view props { toContentMsg, model, content } =
    { title = content.title ++ " | Sift"
    , body =
        [ header
            [ class <|
                String.join " "
                    [ "bg-white dark:bg-black-500 shadow"
                    , Utils.ternery model.sidebarOpen "sticky top-0 z-50" ""
                    ]
            ]
            [ div [ class "mx-auto h-16 px-4 py-4 flex justify-between items-center" ]
                [ Html.map toContentMsg <| navBarIcon model.sidebarOpen
                , div [ class "w-full flex justify-between" ]
                    [ props.header
                    ]
                ]
            ]
        , div [ class "mx-auto px-4 flex-1" ] content.body
        , viewFooter
        ]
    }


navBarIcon : Bool -> Html.Html Msg
navBarIcon state =
    button [ class "focus:outline-none", onClick ToggleNavBar ]
        [ SvgAssets.hamIcon state
        ]


viewFooter : Html.Html msg
viewFooter =
    footer [ class "bg-white dark:bg-black-500 shadow mt-auto" ]
        [ div [ class "mx-auto px-4 py-4 text-center text-sm text-black-500 dark:text-white" ]
            [ p [ class "text-black-500 dark:text-white text-sm" ]
                [ text "This project is open source. Check it out on "
                , a
                    [ class "underline hover:text-blue-500"
                    , href "https://github.com/omer-biz/sift"
                    , target "_blank"
                    , rel "noopenr noreferrer"
                    ]
                    [ text "Github" ]
                , text "."
                ]
            , p [ class "text-black-500 dark:text-white text-xs mt-1" ]
                [ text "Contributions are welcome!" ]
            ]
        ]
