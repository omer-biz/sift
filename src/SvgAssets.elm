
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
