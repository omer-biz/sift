module Utils exposing (formatDate, receieve, tagIdsStr, ternery)

import Json.Decode as D exposing (Decoder)
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


tagIdsStr : List Int -> String
tagIdsStr ids =
    ids
        |> List.map String.fromInt
        |> String.join ","


receieve : Decoder a
         -> (Result D.Error a -> msg) -> ((D.Value -> msg) -> Sub msg) -> Sub msg
receieve decoder toMsg effect =
    effect (\value -> D.decodeValue decoder value |> toMsg)
