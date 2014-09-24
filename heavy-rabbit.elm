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
renderRabbit : Form
renderRabbit = toForm <| image 80 100 "http://www.canardpc.com/img/couly/img141.png"

renderDirection: Direction -> Form
renderDirection direction = toForm <| leftAligned <| toText <| "Arrows = " ++ show direction

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

render: (Int, Int) -> {direction:Direction, rabbitPosition:Position} -> Element
render (width, height) model = 
    collage width height [
                 renderBackground (width, height)
                , moveX (toFloat <| fst <| model.rabbitPosition) renderRabbit
                , move (0, 80) <| renderDirection model.direction
       ]

input : Signal Direction
input = Keyboard.arrows
       
main : Signal Element
main = lift2 render Window.dimensions (foldp walk model input)
