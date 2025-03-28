module SvgAssets exposing (..)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes as Attributes exposing (..)
import Utils


hamIcon : Bool -> Html msg
hamIcon open =
    svg
        [ class "w-8 h-8", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round" ]
        [ line [ x1 "4", y1 "7", x2 "20", y2 "7", class <| String.join " " [ "transition-all duration-300 ease-in-out origin-[12px_7px] ", Utils.ternery open "transform translate-y-[5px] rotate-45" "" ] ] []
        , line [ x1 "4", y1 "12", x2 "20", y2 "12", class <| String.join " " [ "transition-all duration-300 ease-in-out ", Utils.ternery open "opacity-0" "opacity-100" ] ] []
        , line [ x1 "4", y1 "17", x2 "20", y2 "17", class <| String.join " " [ "transition-all duration-300 ease-in-out origin-[12px_17px]", Utils.ternery open "transform -translate-y-[5px] -rotate-45" "" ] ] []
        ]


home : String -> Html msg
home classStr =
    svg
        [ class classStr, fill "none", stroke "currentColor", viewBox "0 0 24 24" ]
        [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" ] [] ]


sun : String -> Html msg
sun classStr =
    svg [ viewBox "0 0 20 20", fill "currentColor", Attributes.style "", class classStr ]
        [ Svg.path
            [ d "M10 2a.75.75 0 0 1 .75.75v1.5a.75.75 0 0 1-1.5 0v-1.5A.75.75 0 0 1 10 2ZM10 15a.75.75 0 0 1 .75.75v1.5a.75.75 0 0 1-1.5 0v-1.5A.75.75 0 0 1 10 15ZM10 7a3 3 0 1 0 0 6 3 3 0 0 0 0-6ZM15.657 5.404a.75.75 0 1 0-1.06-1.06l-1.061 1.06a.75.75 0 0 0 1.06 1.06l1.06-1.06ZM6.464 14.596a.75.75 0 1 0-1.06-1.06l-1.06 1.06a.75.75 0 0 0 1.06 1.06l1.06-1.06ZM18 10a.75.75 0 0 1-.75.75h-1.5a.75.75 0 0 1 0-1.5h1.5A.75.75 0 0 1 18 10ZM5 10a.75.75 0 0 1-.75.75h-1.5a.75.75 0 0 1 0-1.5h1.5A.75.75 0 0 1 5 10ZM14.596 15.657a.75.75 0 0 0 1.06-1.06l-1.06-1.061a.75.75 0 1 0-1.06 1.06l1.06 1.06ZM5.404 6.464a.75.75 0 0 0 1.06-1.06l-1.06-1.06a.75.75 0 1 0-1.061 1.06l1.06 1.06Z" ]
            []
        ]


moon : String -> Html msg
moon classStr =
    svg
        [ viewBox "0 0 20 20", fill "currentColor", class classStr ]
        [ Svg.path
            [ fillRule "evenodd", d "M7.455 2.004a.75.75 0 0 1 .26.77 7 7 0 0 0 9.958 7.967.75.75 0 0 1 1.067.853A8.5 8.5 0 1 1 6.647 1.921a.75.75 0 0 1 .808.083Z", clipRule "evenodd" ]
            []
        ]

display : String -> Html msg
display classStr =
    svg [ viewBox "0 0 16 16", fill "currentColor", class classStr ]
        [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] []
        , g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] []
        , g [ id "SVGRepo_iconCarrier" ]
            [ Svg.path
                [ d "M0 4s0-2 2-2h12s2 0 2 2v6s0 2-2 2h-4c0 .667.083 1.167.25 1.5H11a.5.5 0 0 1 0 1H5a.5.5 0 0 1 0-1h.75c.167-.333.25-.833.25-1.5H2s-2 0-2-2V4zm1.398-.855a.758.758 0 0 0-.254.302A1.46 1.46 0 0 0 1 4.01V10c0 .325.078.502.145.602.07.105.17.188.302.254a1.464 1.464 0 0 0 .538.143L2.01 11H14c.325 0 .502-.078.602-.145a.758.758 0 0 0 .254-.302 1.464 1.464 0 0 0 .143-.538L15 9.99V4c0-.325-.078-.502-.145-.602a.757.757 0 0 0-.302-.254A1.46 1.46 0 0 0 13.99 3H2c-.325 0-.502.078-.602.145z" ]
                []
            ]
        ]
