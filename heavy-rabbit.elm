import Keyboard
import Window
import Text

-- Model
rabbit = { x=0, y=0 }

-- Display
rabbitImg = image 80 100 "http://www.canardpc.com/img/couly/img141.png"

bgBlue = rgb 100 220 255

formatDirection : {x: Int, y: Int} -> String
formatDirection direction = 
    concat [
           "KB direction: {"
         , show direction.x 
         , ", "
         , show direction.y 
         , "}"
    ]

render: (Int, Int) -> {x: Int, y: Int} -> Element
render (width, heigth) direction = collage width heigth [
             filled bgBlue <| rect (toFloat width) (toFloat heigth)
           , toForm rabbitImg
           , move (0, 80) <| toForm <| leftAligned <| toText <| formatDirection direction
       ]

input = Keyboard.arrows
       
main : Signal Element
main = lift2 render Window.dimensions input
