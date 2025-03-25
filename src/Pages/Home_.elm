module Pages.Home_ exposing (page)

import Html
import Html.Attributes as Attr
import View exposing (View)


page : View msg
page =
    { title = "Homepage"
    , body = [ Html.p [ Attr.class "text-green-500 underline" ] 
         [ Html.text "Hello, world!" ] ]
    }
