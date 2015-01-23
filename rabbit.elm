import Keyboard
import Window
import Time (..)
import Signal (..)
import Graphics.Collage (..)
import Graphics.Element (..) 
import Color (..)

-- Input
delta : Signal Time
delta = (fps 60)

input : Signal Direction
input = sampleOn delta Keyboard.arrows

-- Model

type alias Position = {x:Int, y:Int}
type alias Direction = {x:Int, y:Int}
type alias Model = {
    position:Position
    , speed:Int}

rabbitModel : Model
rabbitModel = {
    position = { x=0, y=0 }
    ,speed=5}

sausageModel : Model
sausageModel = {
    position = { x=200, y=50 }
    ,speed=2}

moveRabbit : Direction -> Model -> Model
moveRabbit direction model =
    let pos_x = model.position.x
        pos_y = model.position.y
        speed = model.speed
    in { model | position <- { x=pos_x + direction.x*speed, y=pos_y + direction.y*speed} }

moveSausage : Time -> Model -> Model
moveSausage time model =
    let pos_x = model.position.x
        pos_y = model.position.y
        speed = model.speed
    in { model | position <- { x=pos_x + -1*speed, y=pos_y} }

-- Display
renderRabbit : Form
renderRabbit = toForm <| image 256 128 "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/canardage_lapin.png"

rabbitAt : (Int, Int) -> Model -> Element
rabbitAt (width, height) model =
    collage width height [
        move (toFloat <| model.position.x, toFloat <| model.position.y) renderRabbit]

rabbit : Signal Element
rabbit = map2 rabbitAt Window.dimensions (foldp moveRabbit rabbitModel input)

renderSausage : Form
renderSausage = let height = 41
                in move (100, 100) (toForm <| image 128 height "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/saucisse_pourrie.png")

sausageAt : (Int, Int) -> Model -> Element
sausageAt (width, height) model =
    collage width height [
        move (toFloat <| model.position.x, toFloat <| model.position.y) renderSausage]

sausage : Signal Element
sausage = map2 sausageAt Window.dimensions (foldp moveSausage sausageModel delta)

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

backgroundAt : (Int, Int) -> Element
backgroundAt (width, height) =
    collage width height [renderBackground (width, height)]

background : Signal Element
background = map backgroundAt Window.dimensions


merge : Element -> Element -> Element -> Element
merge fig1 fig2 fig3 = layers [fig1, fig2, fig3]
 
main = merge <~ background ~ rabbit ~ sausage
