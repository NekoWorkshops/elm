import Keyboard
import Window


-- Input

delta : Signal Time
delta = fps 25

input : Signal Direction
input = sampleOn delta Keyboard.arrows

-- Model
type Position = {x:Int, y:Int}
type Direction = {x:Int, y:Int}
type Model = {
    direction:Direction
    , position:Position
    , speed:Int}

rabbitModel : Model
rabbitModel = {
    direction = { x=0, y=0 }
    , position = { x=0, y=0 }
    ,speed=10}

sausageModel : Model
sausageModel = {
    direction = { x=-1, y=0 }
    , position = { x=200, y=50 }
    ,speed=1}

walk : Direction -> Model -> Model
walk dir m =
    let pos_x = m.position.x
        pos_y = m.position.y
        speed = m.speed
    in { m | direction <- dir,
             position <- { x=pos_x + dir.x*speed, y=pos_y + dir.y*speed}
       }

-- Display
renderRabbit : Form
renderRabbit = toForm <| image 256 128 "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/canardage_lapin.png"

rabbitAt : (Int, Int) -> Model -> Element
rabbitAt (width, height) model =
    collage width height [
        move (toFloat <| model.position.x, toFloat <| model.position.y) renderRabbit]

rabbit : Signal Element
rabbit = lift2 rabbitAt Window.dimensions (foldp walk rabbitModel input)

renderSausage : Form
renderSausage = let height = 41
                in move (100, 100) (toForm <| image 128 height "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/saucisse_pourrie.png")

sausageAt : (Int, Int) -> Model -> Element
sausageAt (width, height) model =
    collage width height [
        move (toFloat <| model.position.x, toFloat <| model.position.y) renderSausage]


renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

backgroundAt : (Int, Int) -> Element
backgroundAt (width, height) =
    collage width height [renderBackground (width, height)]

background : Signal Element
background = lift backgroundAt Window.dimensions


merge : Element -> Element -> Element
merge fig1 fig2 = layers [fig1, fig2]

main = lift2 merge background rabbit