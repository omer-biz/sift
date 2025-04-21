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


add : String -> Html msg
add classStr =
    svg [ class classStr, fill "none", stroke "currentColor", viewBox "0 0 24 24" ] [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M12 4v16m8-8H4" ] [] ]


cal : String -> Html msg
cal classStr =
    svg [ class classStr, fill "none", stroke "currentColor", viewBox "0 0 24 24" ] [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" ] [] ]


fullStar : String -> Html msg
fullStar classStr =
    svg [ class classStr, fill "currentColor", viewBox "0 0 24 24", enableBackground "new 0 0 24 24" ] [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] [], g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] [], g [ id "SVGRepo_iconCarrier" ] [ Svg.path [ d "M22,10.1c0.1-0.5-0.3-1.1-0.8-1.1l-5.7-0.8L12.9,3c-0.1-0.2-0.2-0.3-0.4-0.4C12,2.3,11.4,2.5,11.1,3L8.6,8.2L2.9,9C2.6,9,2.4,9.1,2.3,9.3c-0.4,0.4-0.4,1,0,1.4l4.1,4l-1,5.7c0,0.2,0,0.4,0.1,0.6c0.3,0.5,0.9,0.7,1.4,0.4l5.1-2.7l5.1,2.7c0.1,0.1,0.3,0.1,0.5,0.1l0,0c0.1,0,0.1,0,0.2,0c0.5-0.1,0.9-0.6,0.8-1.2l-1-5.7l4.1-4C21.9,10.5,22,10.3,22,10.1z" ] [] ] ]


hollowStar : String -> Html msg
hollowStar classStr =
    svg [ class classStr, fill "currentColor", viewBox "0 0 24 24" ] [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] [], g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] [], g [ id "SVGRepo_iconCarrier" ] [ Svg.path [ d "M22,9.67A1,1,0,0,0,21.14,9l-5.69-.83L12.9,3a1,1,0,0,0-1.8,0L8.55,8.16,2.86,9a1,1,0,0,0-.81.68,1,1,0,0,0,.25,1l4.13,4-1,5.68A1,1,0,0,0,6.9,21.44L12,18.77l5.1,2.67a.93.93,0,0,0,.46.12,1,1,0,0,0,.59-.19,1,1,0,0,0,.4-1l-1-5.68,4.13-4A1,1,0,0,0,22,9.67Zm-6.15,4a1,1,0,0,0-.29.88l.72,4.2-3.76-2a1.06,1.06,0,0,0-.94,0l-3.76,2,.72-4.2a1,1,0,0,0-.29-.88l-3-3,4.21-.61a1,1,0,0,0,.76-.55L12,5.7l1.88,3.82a1,1,0,0,0,.76.55l4.21.61Z" ] [] ] ]


delete : String -> Html msg
delete classStr =
    svg [ class classStr, viewBox "0 0 24 24", fill "currentColor" ] [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] [], g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] [], g [ id "SVGRepo_iconCarrier" ] [ Svg.path [ d "M10 12V17", stroke "#000000", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round" ] [], Svg.path [ d "M14 12V17", stroke "#000000", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round" ] [], Svg.path [ d "M4 7H20", stroke "#000000", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round" ] [], Svg.path [ d "M6 10V18C6 19.6569 7.34315 21 9 21H15C16.6569 21 18 19.6569 18 18V10", stroke "#000000", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round" ] [], Svg.path [ d "M9 5C9 3.89543 9.89543 3 11 3H13C14.1046 3 15 3.89543 15 5V7H9V5Z", stroke "#000000", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round" ] [] ] ]


pinhollow : String -> Html msg
pinhollow classStr =
    svg [ class classStr, fill "currentColor", viewBox "-2.5 -2.5 24 24", preserveAspectRatio "xMinYMin", class "jam jam-pin" ] [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] [], g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] [], g [ id "SVGRepo_iconCarrier" ] [ Svg.path [ d "M12.626 11.346l-.184-1.036 4.49-4.491-2.851-2.852-4.492 4.49-1.035-.184a5.05 5.05 0 0 0-2.734.269l6.538 6.537a5.05 5.05 0 0 0 .268-2.733zm-4.25 1.604L2.67 18.654a1.008 1.008 0 0 1-1.426-1.426l5.705-5.704L2.67 7.245a7.051 7.051 0 0 1 6.236-1.958l3.747-3.747a2.017 2.017 0 0 1 2.853 0l2.852 2.853a2.017 2.017 0 0 1 0 2.852l-3.747 3.747a7.051 7.051 0 0 1-1.958 6.236L8.376 12.95z" ] [] ] ]


pinFilled : String -> Html msg
pinFilled classStr =
    svg [ class classStr, fill "currentColor", viewBox "-3 -2.5 24 24", preserveAspectRatio "xMinYMin", class "jam jam-pin-f" ] [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] [], g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] [], g [ id "SVGRepo_iconCarrier" ] [ Svg.path [ d "M7.374 12.268l-5.656 5.657A1 1 0 1 1 .303 16.51l5.657-5.656L1.718 6.61A6.992 6.992 0 0 1 7.9 4.67L11.617.954a2 2 0 0 1 2.828 0l2.829 2.828a2 2 0 0 1 0 2.829l-3.716 3.716a6.992 6.992 0 0 1-1.941 6.183l-4.243-4.242z" ] [] ] ]


threeDot : String -> Html msg
threeDot classStr =
    svg [ class classStr, viewBox "0 0 16 16", fill "currentColor", class "bi bi-three-dots-vertical" ]
        [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] [], g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] [], g [ id "SVGRepo_iconCarrier" ] [ Svg.path [ d "M9.5 13a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0zm0-5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0zm0-5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0z" ] [] ] ]


calDownArrow : String -> Html msg
calDownArrow classStr =
    svg
        [ class <| classStr ++ " fill-white-100 stroke-black-500 dark:fill-black-500 dark:stroke-white-100"
        , viewBox "0 0 24 24"
        ]
        [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] []
        , g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] []
        , g [ id "SVGRepo_iconCarrier" ]
            [ Svg.path
                [ d "M3 9H21M7 3V5M17 3V5M10 16L12 18M12 18L14 16M12 18V12M6.2 21H17.8C18.9201 21 19.4802 21 19.908 20.782C20.2843 20.5903 20.5903 20.2843 20.782 19.908C21 19.4802 21 18.9201 21 17.8V8.2C21 7.07989 21 6.51984 20.782 6.09202C20.5903 5.71569 20.2843 5.40973 19.908 5.21799C19.4802 5 18.9201 5 17.8 5H6.2C5.0799 5 4.51984 5 4.09202 5.21799C3.71569 5.40973 3.40973 5.71569 3.21799 6.09202C3 6.51984 3 7.07989 3 8.2V17.8C3 18.9201 3 19.4802 3.21799 19.908C3.40973 20.2843 3.71569 20.5903 4.09202 20.782C4.51984 21 5.07989 21 6.2 21Z"
                , strokeWidth "2"
                , strokeLinecap "round"
                , strokeLinejoin "round"
                ]
                []
            ]
        ]


calLines : String -> Html msg
calLines classStr =
    svg
        [ class <| classStr ++ " fill-white-100 stroke-black-500 dark:fill-black-500 dark:stroke-white-100"
        , viewBox "0 0 24 24"
        ]
        [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] []
        , g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] []
        , g [ id "SVGRepo_iconCarrier" ]
            [ Svg.path
                [ d "M3 9H21M17 13.0014L7 13M10.3333 17.0005L7 17M7 3V5M17 3V5M6.2 21H17.8C18.9201 21 19.4802 21 19.908 20.782C20.2843 20.5903 20.5903 20.2843 20.782 19.908C21 19.4802 21 18.9201 21 17.8V8.2C21 7.07989 21 6.51984 20.782 6.09202C20.5903 5.71569 20.2843 5.40973 19.908 5.21799C19.4802 5 18.9201 5 17.8 5H6.2C5.0799 5 4.51984 5 4.09202 5.21799C3.71569 5.40973 3.40973 5.71569 3.21799 6.09202C3 6.51984 3 7.07989 3 8.2V17.8C3 18.9201 3 19.4802 3.21799 19.908C3.40973 20.2843 3.71569 20.5903 4.09202 20.782C4.51984 21 5.07989 21 6.2 21Z"
                , strokeWidth "2"
                , strokeLinecap "round"
                , strokeLinejoin "round"
                ]
                []
            ]
        ]


arrowLeft : String -> Html msg
arrowLeft classStr =
    svg [ class classStr, viewBox "0 0 24 24", fill "currentColor" ]
        [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] []
        , g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] []
        , g [ id "SVGRepo_iconCarrier" ]
            [ Svg.path
                [ d "M5 12H19M5 12L11 6M5 12L11 18"
                , stroke "currentColor"
                , strokeWidth "2"
                , strokeLinecap "round"
                , strokeLinejoin "round"
                ]
                []
            ]
        ]


google : String -> Html msg
google classStr =
    svg [ class classStr, viewBox "0 0 32 32", fill "none" ]
        [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] []
        , g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] []
        , g [ id "SVGRepo_iconCarrier" ]
            [ Svg.path [ d "M30.0014 16.3109C30.0014 15.1598 29.9061 14.3198 29.6998 13.4487H16.2871V18.6442H24.1601C24.0014 19.9354 23.1442 21.8798 21.2394 23.1864L21.2127 23.3604L25.4536 26.58L25.7474 26.6087C28.4458 24.1665 30.0014 20.5731 30.0014 16.3109Z", fill "#4285F4" ] []
            , Svg.path [ d "M16.2863 29.9998C20.1434 29.9998 23.3814 28.7553 25.7466 26.6086L21.2386 23.1863C20.0323 24.0108 18.4132 24.5863 16.2863 24.5863C12.5086 24.5863 9.30225 22.1441 8.15929 18.7686L7.99176 18.7825L3.58208 22.127L3.52441 22.2841C5.87359 26.8574 10.699 29.9998 16.2863 29.9998Z", fill "#34A853" ] []
            , Svg.path [ d "M8.15964 18.769C7.85806 17.8979 7.68352 16.9645 7.68352 16.0001C7.68352 15.0356 7.85806 14.1023 8.14377 13.2312L8.13578 13.0456L3.67083 9.64746L3.52475 9.71556C2.55654 11.6134 2.00098 13.7445 2.00098 16.0001C2.00098 18.2556 2.55654 20.3867 3.52475 22.2845L8.15964 18.769Z", fill "#FBBC05" ] []
            , Svg.path [ d "M16.2864 7.4133C18.9689 7.4133 20.7784 8.54885 21.8102 9.4978L25.8419 5.64C23.3658 3.38445 20.1435 2 16.2864 2C10.699 2 5.8736 5.1422 3.52441 9.71549L8.14345 13.2311C9.30229 9.85555 12.5086 7.4133 16.2864 7.4133Z", fill "#EB4335" ] []
            ]
        ]


github : String -> Html msg
github classStr =
    svg [ class classStr, viewBox "0 0 48 48", fill "none" ]
        [ g [ id "SVGRepo_bgCarrier", strokeWidth "0" ] []
        , g [ id "SVGRepo_tracerCarrier", strokeLinecap "round", strokeLinejoin "round" ] []
        , g [ id "SVGRepo_iconCarrier" ]
            [ circle
                [ cx "24", cy "24", r "20", fill "#181717" ]
                []
            , Svg.path
                [ d "M6.81348 34.235C9.24811 38.3138 13.0939 41.4526 17.6772 42.9784C18.6779 43.1614 19.0425 42.5438 19.0425 42.0134C19.0425 41.7938 19.0388 41.4058 19.0339 40.8866C19.0282 40.2852 19.0208 39.5079 19.0155 38.6124C13.4524 39.8206 12.2787 35.931 12.2787 35.931C11.3689 33.6215 10.0576 33.0064 10.0576 33.0064C8.2417 31.7651 10.1951 31.7896 10.1951 31.7896C12.2025 31.9321 13.2584 33.8511 13.2584 33.8511C15.0424 36.9071 17.94 36.0243 19.0794 35.5135C19.2611 34.2207 19.7767 33.3391 20.3489 32.8394C15.908 32.3348 11.2387 30.6183 11.2387 22.9545C11.2387 20.7715 12.0184 18.9863 13.2977 17.5879C13.0914 17.082 12.4051 15.0488 13.4929 12.2949C13.4929 12.2949 15.1725 11.7571 18.9934 14.3453C20.5883 13.9021 22.2998 13.6798 24.0003 13.6725C25.6983 13.6798 27.4099 13.9021 29.0072 14.3453C32.8256 11.7571 34.5016 12.2949 34.5016 12.2949C35.5931 15.0488 34.9067 17.082 34.7005 17.5879C35.9823 18.9863 36.757 20.7715 36.757 22.9545C36.757 30.638 32.0804 32.3286 27.6247 32.8234C28.343 33.441 28.9827 34.6614 28.9827 36.5277C28.9827 38.3152 28.9717 39.8722 28.9644 40.9035C28.9608 41.4143 28.9581 41.7962 28.9581 42.0134C28.9581 42.5487 29.3178 43.1712 30.3332 42.976C33.9844 41.7572 37.1671 39.5154 39.5403 36.5903C35.8734 41.1108 30.274 44 23.9997 44C16.6943 44 10.3038 40.0832 6.81348 34.235Z", fill "white" ]
                []
            ]
        ]
