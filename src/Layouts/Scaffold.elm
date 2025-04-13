module Layouts.Scaffold exposing (Model, Msg, Props, layout, map)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, href, rel, target)
import Html.Events exposing (onClick)
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path as Path
import Shared
import SvgAssets
import Types.Theme as Theme exposing (Theme(..))
import Utils
import View exposing (View)


type alias Props contentMsg =
    { header : Html contentMsg
    }


layout : Props contentMsg -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init shared.theme
        , update = update
        , view = view route props
        , subscriptions = subscriptions
        }


map : (msg1 -> msg2) -> Props msg1 -> Props msg2
map fn props =
    { header = Html.map fn props.header }



-- MODEL


type alias Model =
    { sidebarOpen : Bool
    , theme : Theme
    }


init : Theme -> () -> ( Model, Effect Msg )
init theme _ =
    ( { sidebarOpen = False, theme = theme }
    , Effect.none
    )



-- UPDATE


type Msg
    = ToggleNavBar
    | SwitchTheme Theme


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ToggleNavBar ->
            ( { model | sidebarOpen = not model.sidebarOpen }
            , Effect.none
            )

        SwitchTheme theme ->
            ( { model | theme = theme }
            , Effect.switchTheme (Theme.toString theme)
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Route () -> Props contentMsg -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view route props { toContentMsg, model, content } =
    { title = content.title ++ " | Sift"
    , body =
        [ header
            [ class <|
                String.join " "
                    [ "md:w-[900px] md:mx-auto bg-white dark:bg-black-500 border-b border-black-500"
                    , Utils.ternery model.sidebarOpen "sticky top-0 z-50" ""
                    ]
            ]
            [ div [ class "mx-auto h-16 px-4 py-4 flex justify-between items-center" ]
                [ Html.map toContentMsg <| navBarIcon model.sidebarOpen
                , div [ class "w-full flex justify-between" ] [ props.header ]
                ]
            ]
        , div [ class "md:max-w-[700px] md:mx-auto min-h-screen" ] content.body
        , Html.map toContentMsg <| viewSideBar model route
        , viewFooter
        ]
    }


viewSideBar : Model -> Route () -> Html.Html Msg
viewSideBar model route =
    let
        navItem path_ =
            a
                [ onClick ToggleNavBar
                , Path.href path_
                , class <|
                    String.join " "
                        [ "flex items-center space-x-2 px-4 py-2 text-black-500 dark:text-white-100 hover:bg-white-300 dark:hover:bg-black-600 rounded-lg transition-colors"
                        , Utils.ternery (route.path == path_) "bg-white-200 dark:bg-black-400 shadow" ""
                        ]
                ]
    in
    aside
        [ class <|
            String.join " "
                [ "fixed left-0 top-16 h-[calc(100vh-4rem)] w-64 dark:bg-black-500 bg-white-100 transform transition-transform duration-300 ease-in-out z-40 shadow-xl flex flex-col justify-between"
                , Utils.ternery model.sidebarOpen "translate-x-0" "-translate-x-full"
                ]
        ]
        [ div [ class "p-4" ]
            [ h2 [ class "text-2xl font-bold mb-4" ] []
            , nav [ class "space-y-2" ]
                [ navItem Path.Home_ <| [ SvgAssets.home "w-5 h-5", span [] [ text "Home" ] ]
                , navItem Path.Pinned <| [ SvgAssets.pinhollow "w-5 h-5", span [] [ text "Pinned" ] ]
                ]
            ]
        , div [ class "flex flex-col p-4 space-y-4" ]
            [ div [ class "flex justify-between items-center" ]
                [ span [] [ text "Theme" ]
                , viewThemeSwitch model.theme
                ]
            ]
        ]


viewThemeSwitch : Theme -> Html.Html Msg
viewThemeSwitch theme =
    div [ class "border rounded-lg border-sm border-gray-300  dark:border-gray-600 flex gap-x-2 items-center" ]
        [ button
            [ class <| isThemeActive theme Light, onClick <| SwitchTheme Light ]
            [ SvgAssets.sun "h-6 w-6" ]
        , button
            [ class <| isThemeActive theme Dark, onClick <| SwitchTheme Dark ]
            [ SvgAssets.moon "h-5 w-5" ]
        , button
            [ class <| isThemeActive theme System, onClick <| SwitchTheme System ]
            [ SvgAssets.display "h-5 w-5" ]
        ]


isThemeActive : b -> b -> String
isThemeActive theme curr =
    String.join " "
        [ Utils.ternery (theme == curr)
            "bg-black-500 dark:bg-white-100 text-white-100 dark:text-black-500"
            ""
        , "rounded p-1"
        ]


navBarIcon : Bool -> Html.Html Msg
navBarIcon state =
    button [ class "focus:outline-none", onClick ToggleNavBar ]
        [ SvgAssets.hamIcon state
        ]


viewFooter : Html.Html msg
viewFooter =
    footer [ class "bg-white-100 dark:bg-black-500 shadow mt-auto" ]
        [ div [ class "mx-auto px-4 py-4 text-center text-sm text-black-500 dark:text-white-100" ]
            [ p [ class "text-black-500 dark:text-white-100 text-sm" ]
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
            , p [ class "text-black-500 dark:text-white-100 text-xs mt-1" ]
                [ text "Contributions are welcome!" ]
            ]
        ]
