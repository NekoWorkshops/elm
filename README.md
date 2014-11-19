# Atelier découverte du langage [ELM](http://elm-lang.org)

## Introduction

ELM est un langage de programmation fonctionnel basé sur Haskell issu des de la thèse de Evan Czaplicki.
Il inclut un cadre de développement suffisamment complet pour créer des applications web réactives en générant le HTML, CSS et JS.

Dans cet atelier, nous allons nous intéresser au traitement de données en flux et la propagation des changements à travers l'application de fonctions composites sur ces données.

Nous verrons également que ELM basé sur le concept FRP (Fonctionnal Reactive Programming) ne l'est que partiellement.

## Signal

La donnée dans l'univers ELM est appelée *Signal*. Cette donnée peut provenir des périphériques d'entrée tels que la souris et le clavier ou bien d'une réponse d'un serveur. Ces *signaux* de valeurs (qui varient dans le temps) peuvent être traités en flux en utilisant la fonction [lift](http://elm-lang.org/learn/Syntax.elm#lifting).
Affichons les coordonnées de la souris :

```elm
import Mouse

main : Signal Element
main = lift asText Mouse.position
```

À chaque envoi de la position de la souris, `lift` appliquera la fonction [asText](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Text) sur la propriété `position` du signal [Mouse](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Mouse).

## Affichage d'une image

Application de la fonction [image](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Graphics-Element#image)

```elm
main : Element
main = image 256 128 "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/canardage_lapin.png"
```

Notons que cette image s'affiche dans le coin haut-gauche du cadre HTML

## Composition d'images dans un cadre statique

La composition d'image s'apparente à un empilement de calque (au sens Gimp ou Photoshop).

Application des fonctions :
* [<|](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Basics#%3C|)
* [image](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Graphics-Element#image)
* [toForm](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Graphics-Collage#toForm)
* [filled](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Graphics-Collage#filled)
* [collage](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Graphics-Collage#collage)

```elm
renderRabbit : Form
renderRabbit = toForm <| image 256 128 "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/canardage_lapin.png"

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

main : Element
main = collage 800 600 [renderBackground (800, 800), renderRabbit] 
```

Nous remarquons que l'image de la soucoupe volante est centrée. En effet, la fonction `collage` dessine chaque `Form` au centre du cadre.
Par ailleurs, la taille du cadre est en dur.

## Composition d'images dans un cadre à taille variable

Utilisation de l'API [Window](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Window) pour récupérer les dimensions du cadre `div`

```elm
import Window

-- Display
renderRabbit : Form
renderRabbit = toForm <| image 256 128 "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/canardage_lapin.png"

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

render : (Int, Int) -> Element
render (width, height) =
  collage width height [renderBackground (width, height), renderRabbit]

main : Signal Element
main = lift render Window.dimensions
```

## Déplacement d'un `Form` avec le clavier

Utilisation de l'API [Keyboard](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Keyboard)

### Affichage des valeurs de la propriété arrows

```elm
import Keyboard

main : Signal Element
main = lift asText Keyboard.arrows
```

## Bouger le lapin avec les flèches du clavier

```elm
import Keyboard
import Window

-- Model
type Position = {x:Int, y:Int}
type Direction = {x:Int, y:Int}
type Model = {
    direction:Direction
    , position:Position
    }

model : Model
model = {
    direction = { x=0, y=0 }
    , position = { x=0, y=0 }
    }


walk : Direction -> Model -> Model
walk dir m =
    let pos_x = m.position.x
        pos_y = m.position.y
    in { m | direction <- dir,
             position <- { x=pos_x + dir.x, y=pos_y + dir.y}
       }

-- Display
renderRabbit : Form
renderRabbit = toForm <| image 256 128 "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/canardage_lapin.png"

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

render: (Int, Int) -> Model -> Element
render (width, height) model =
    collage width height [
        renderBackground (width, height)
        , move (toFloat <| model.position.x, toFloat <| model.position.y) renderRabbit]

input : Signal Direction
input = Keyboard.arrows

main : Signal Element
main = lift2 render Window.dimensions (foldp walk model input)
```

## Bouger le lapin en laissant appuyé la touche flèche du clavier

Utilisation de la fonction [fps](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Time#fps)
Utilisation de la fonction [sampleOn](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Signal#sampleOn)

```elm
import Keyboard
import Window

-- Model
type Position = {x:Int, y:Int}
type Direction = {x:Int, y:Int}
type Model = {
    direction:Direction
    , position:Position
    }

model : Model
model = {
    direction = { x=0, y=0 }
    , position = { x=0, y=0 }
    }


walk : Direction -> Model -> Model
walk dir m =
    let pos_x = m.position.x
        pos_y = m.position.y
    in { m | direction <- dir,
             position <- { x=pos_x + dir.x, y=pos_y + dir.y}
       }

-- Display
renderRabbit : Form
renderRabbit = toForm <| image 256 128 "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/canardage_lapin.png"

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

render: (Int, Int) -> Model -> Element
render (width, height) model =
    collage width height [
        renderBackground (width, height)
        , move (toFloat <| model.position.x, toFloat <| model.position.y) renderRabbit]

delta : Signal Time
delta = fps 25

input : Signal Direction
input = sampleOn delta Keyboard.arrows

main : Signal Element
main = lift2 render Window.dimensions (foldp walk model input)
```

## Refactor

```elm
import Keyboard
import Window


-- Input
delta : Signal Time
delta = fps 60

input : Signal Direction
input = sampleOn delta Keyboard.arrows

-- Model
type Position = {x:Int, y:Int}
type Direction = {x:Int, y:Int}
type Model = {
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
rabbit = lift2 rabbitAt Window.dimensions (foldp moveRabbit rabbitModel input)

renderSausage : Form
renderSausage = let height = 41
                in move (100, 100) (toForm <| image 128 height "https://raw.githubusercontent.com/dboissier/canardage-web/master/src/images/saucisse_pourrie.png")

sausageAt : (Int, Int) -> Model -> Element
sausageAt (width, height) model =
    collage width height [
        move (toFloat <| model.position.x, toFloat <| model.position.y) renderSausage]

sausage : Signal Element
sausage = lift2 sausageAt Window.dimensions (foldp moveSausage sausageModel delta)

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

backgroundAt : (Int, Int) -> Element
backgroundAt (width, height) =
    collage width height [renderBackground (width, height)]

background : Signal Element
background = lift backgroundAt Window.dimensions


merge : Element -> Element -> Element -> Element
merge fig1 fig2 fig3 = layers [fig1, fig2, fig3]

main = merge <~ background ~ rabbit ~ sausage
```

