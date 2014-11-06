import Keyboard
import Window

-- Model
type Rectangle = {
  dimension: (Int, Int)
  , color: Color}
type Position = (Int, Int)
type Direction = {x:Int, y:Int}
type Model = {
    direction:Direction
    , position:Position
    , speed:Int}
  
model : Model
model = {direction = {x=0, y=0}, position =(0,0), speed=6}


walk : Direction -> Model -> Model
walk dir m = 
    let (x, y) = m.position
    in { m | direction <- dir, position <- (x + dir.x*m.speed, y + dir.y*m.speed) }

-- Display
renderRabbit : Form
renderRabbit = let height = 64
               in moveY (toFloat height / toFloat 2) (toForm <| image 128 height "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/canardage_lapin.png")

renderBackground : Rectangle -> Form
renderBackground r =
    filled r.color <| rect (toFloat <| fst <| r.dimension) (toFloat <| snd <| r.dimension)

render: (Int, Int) -> Model -> Element
render (width, height) model =
    let sky = {dimension=(width, height), color= rgb 100 220 255}
        groundHeight = toFloat height / toFloat 2
        ground = {dimension=(width, round(groundHeight)), color= rgb 74 163 41}
    in collage width height [
        renderBackground sky
        , moveY (-groundHeight / 2) (renderBackground ground)
        , move (toFloat <| fst <| model.position, toFloat <| snd <| model.position) renderRabbit]

delta : Signal Time
delta = fps 25

input : Signal Direction
input = sampleOn delta Keyboard.arrows

main : Signal Element
main = lift2 render Window.dimensions (foldp walk model input)
