import Keyboard
import Text

rabbitImg = image 80 100 "http://www.canardpc.com/img/couly/img141.png"

bgBlue = rgb 100 220 255
rectWidth  = 320
recHeight = 200

format_direction : {x: Int, y: Int} -> String
format_direction direction = 
    concat [
           "KB direction: {"
         , show direction.x 
         , ", "
         , show direction.y 
         , "}"
    ]

display : {x: Int, y: Int} -> Element
display direction = collage rectWidth recHeight [
             filled bgBlue <| rect rectWidth recHeight
           , toForm rabbitImg
           , move (0, 80) <| toForm <| leftAligned <| toText <| format_direction direction
       ]
       
main : Signal Element
main = lift display Keyboard.arrows
