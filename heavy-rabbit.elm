import Keyboard
import Window
import Text

type Position = (Int, Int)

type Direction = {x:Int, y:Int}

type Model = {
      direction:Direction
      , rabbitPosition:Position
    }

model : Model
model = {
  direction = { x=0, y=0 }
  , rabbitPosition = (0, 0)
  }

walk : Direction -> Model -> Model  
walk dir m = 
    let (x, y) = m.rabbitPosition
    in { m | direction <- dir
           , rabbitPosition <- (x + dir.x, y) }
                 
-- Display
rabbitImg = image 80 100 "http://www.canardpc.com/img/couly/img141.png"

bgBlue = rgb 100 220 255

render: (Int, Int) -> {direction:Direction, rabbitPosition:Position} -> Element
render (width, heigth) model = collage width heigth [
             filled bgBlue <| rect (toFloat width) (toFloat heigth)
           , moveX (toFloat <| fst <| model.rabbitPosition) <| toForm rabbitImg
           , move (0, 80) <| toForm <| leftAligned <| toText <| "Arrows = " ++ show model.direction
       ]

input : Signal Direction
input = Keyboard.arrows
       
main : Signal Element
main = lift2 render Window.dimensions (foldp walk model input)
