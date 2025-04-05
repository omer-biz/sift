module Utils exposing (ternery, formatDate)

import Time


ternery : Bool -> c -> c -> c
ternery cond exp1 exp2 =
    if cond then
        exp1

    else
        exp2


formatDate : Time.Zone -> Time.Posix -> String
formatDate zone posix =
    let
        monthToString m =
            case m of
                Time.Jan ->
                    "Jan"

                Time.Feb ->
                    "Feb"

                Time.Mar ->
                    "Mar"

                Time.Apr ->
                    "Apr"

                Time.May ->
                    "May"

                Time.Jun ->
                    "Jun"

                Time.Jul ->
                    "Jul"

                Time.Aug ->
                    "Aug"

                Time.Sep ->
                    "Sep"

                Time.Oct ->
                    "Oct"

                Time.Nov ->
                    "Nov"

                Time.Dec ->
                    "Dec"

        month =
            Time.toMonth zone posix |> monthToString

        day =
            Time.toDay zone posix |> String.fromInt

        year =
            Time.toYear zone posix |> String.fromInt
    in
    month ++ " " ++ day ++ ", " ++ year
