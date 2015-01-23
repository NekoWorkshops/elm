import Keyboard
import Window
import Time (..)
import Signal (..)
import Graphics.Collage (..)
import Graphics.Element (..) 
import Color (..)
import Random (..)

-- Input
delta : Signal Time
delta = (fps 60)

zip : Signal a -> Signal b -> Signal (a,b)
zip = map2 (\x y -> (x,y))

addSize : Signal a -> Signal ((Int, Int), a)
addSize = zip Window.dimensions

deltaSizes : Signal (Int, Int)
deltaSizes = sampleOn delta Window.dimensions

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
    position = { x=100, y=50 }
    ,speed=2}

type alias Update = ((Int, Int), Direction)
type alias World = {
        rabbit: Model,
        sausage: Model,
        seed: Seed
    }

moveRabbit : Update -> Model -> Model -> Model
moveRabbit ((width, height), direction) _ model =
    let pos_x = model.position.x
        pos_y = model.position.y
        speed = model.speed
    in { model | position <- { x=clamp (-width // 2) (width // 2) (pos_x  + direction.x*speed), y=clamp (-height // 2) (height // 2) ( pos_y + direction.y*speed)} }

moveSausage : Update -> World -> World
moveSausage ((width, height), _) world =
    let rabbit = world.rabbit
        sausage = world.sausage
        pos_x = sausage.position.x
        pos_y = sausage.position.y
        speed = sausage.speed
        (x', seed') =
                if abs(pos_x - rabbit.position.x) < 10
                then generate (int -(width // 2) (width // 2)) world.seed
                else (pos_x + speed, world.seed)

    in { world | seed <- seed'
               , sausage <- 
                { sausage
                        | position <- { x=x', y=pos_y}
                        , speed <- (if pos_x >= width // 2 then -(abs speed) else speed)
                }
        }

updateWorld : Update -> World -> World
updateWorld sig world = 
        let world' = moveSausage sig world
        in { world' | rabbit <- moveRabbit sig world'.sausage world'.rabbit }

initialWorld : World
initialWorld = { rabbit = rabbitModel, sausage = sausageModel, seed = initialSeed 12345 }

-- Display
renderRabbit : Form
renderRabbit = toForm <| image 256 128 "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/canardage_lapin.png"

rabbitAndSausageModels : Signal World
rabbitAndSausageModels = foldp updateWorld initialWorld (addSize input)

renderSausage : Form
renderSausage = let height = 41
                in (toForm <| image 128 height "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/saucisse_pourrie.png")

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

backgroundAt : (Int, Int) -> Element
backgroundAt (width, height) =
    collage width height [renderBackground (width, height)]

background : Signal Element
background = map backgroundAt Window.dimensions

merge : Element -> Element -> Element
merge bg sprs = layers [bg, sprs]

moveSprite : Model -> Form -> Form
moveSprite m = move (toFloat m.position.x, toFloat m.position.y)

rabbitAndSausageAt : (Int, Int) -> World -> Element
rabbitAndSausageAt (width, height) {rabbit, sausage} =
    collage width height [
        moveSprite rabbit renderRabbit,
        moveSprite sausage renderSausage
    ]

sprites : Signal Element
sprites = map2 rabbitAndSausageAt Window.dimensions rabbitAndSausageModels
 
main = map2 merge background sprites
