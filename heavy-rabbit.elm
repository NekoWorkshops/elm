import Keyboard
import Window
import Text

type Position = (Int, Int)

type Direction = {x:Int, y:Int}

model = {
  direction = { x=0, y=0 }
  , rabbit = (0, 0)
  }
  
walk dir m = 
    let (x, y) = m.rabbit
    in { m | direction <- dir
           , rabbit <- (x + dir.x, y) }
                 
-- Display
rabbitImg = image 80 100 "http://www.canardpc.com/img/couly/img141.png"

bgBlue = rgb 100 220 255

render: (Int, Int) -> {direction:Direction, rabbit:Position} -> Element
render (width, heigth) model = collage width heigth [
             filled bgBlue <| rect (toFloat width) (toFloat heigth)
           , moveX (toFloat <| fst <| model.rabbit) <| toForm rabbitImg
           , move (0, 80) <| toForm <| leftAligned <| toText <| "Arrows = " ++ show model.direction
       ]

input : Signal Direction
input = Keyboard.arrows
       
main : Signal Element
main = lift2 render Window.dimensions (foldp walk model input)
