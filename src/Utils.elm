module Utils exposing (ternery)


ternery : Bool -> c -> c -> c
ternery cond exp1 exp2 =
    if cond then
        exp1

    else
        exp2
