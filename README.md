# Atelier Programmation Fonctionnelle Réactive (FRP) avec [ELM](http://elm-lang.org)

## Introduction

La Programmation Fonctionnelle Réactive (PFR) est basée sur les flux de données et la propagation des changements à travers l'application de fonctions composites sur les données à traiter.

La donnée dans l'univers de la FRP est appelée *Signal*. Cette donnée peut provenir des périphériques d'entrée tels que la souris et le clavier ou bien d'une réponse d'un serveur.

Dans le langage ELM, les *signaux* de valeurs (qui varient dans le temps) peuvent être traités en flux en utilisant la fonction [lift](http://elm-lang.org/learn/Syntax.elm#lifting) :

```elm
import Mouse

main : Signal Element
main = lift asText Mouse.position
```

À chaque modification de la position de la souris, `lift` appliquera la fonction [asText](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Text) sur la propriété `position`.

## Affichage d'une image

Utilisation de l'API [Element](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Graphics-Element)

```elm
main : Element
main = image 80 100 "http://www.canardpc.com/img/couly/img141.png"
```

## Composition d'images dans un cadre statique

Utilisation de l'API [Collage](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Graphics-Collage)

```elm
renderRabbit : Form
renderRabbit = toForm <| image 80 100 "http://www.canardpc.com/img/couly/img141.png"

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

main : Element    
main = collage 800 600 [renderBackground (800, 800), renderRabbit] 
```

## Composition d'images dans un cadre dynamique

Utilisation de l'API [Window](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Window) pour récupérer les dimensions du cadre `div`

```elm
import Window

-- Display
renderRabbit : Form
renderRabbit = toForm <| image 80 100 "http://www.canardpc.com/img/couly/img141.png"

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

## Bouger le lapin avec les flèches gauche et droite

```elm
import Keyboard
import Window

-- Model
type Position = (Int, Int)
type Direction = {x:Int, y:Int}
type Model = {
    direction:Direction
    , rabbitPosition:Position}

model : Model
model = {
    direction = { x=0, y=0 }
    , rabbitPosition = (0, 0)}


walk : Direction -> Model -> Model
walk dir m = 
    let (x, y) = m.rabbitPosition
    in { m | direction <- dir, rabbitPosition <- (x + dir.x, y) }

-- Display
renderRabbit : Form
renderRabbit = toForm <| image 80 100 "http://www.canardpc.com/img/couly/img141.png"

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

render: (Int, Int) -> Model -> Element
render (width, height) model = 
    collage width height [
        renderBackground (width, height)
        , moveX (toFloat <| fst <| model.rabbitPosition) renderRabbit]

input : Signal Direction
input = Keyboard.arrows

main : Signal Element
main = lift2 render Window.dimensions (foldp walk model input)
```

## Bouger le lapin avec les flèches gauche et droite en laissant appuyé la touche du clavier

Utilisation de la fonction [fps](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Time#fps)
Utilisation de la fonction [sampleOn](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Signal#sampleOn)

```elm
import Keyboard
import Window

-- Model
type Position = (Int, Int)
type Direction = {x:Int, y:Int}
type Model = {
    direction:Direction
    , rabbitPosition:Position}

model : Model
model = {
    direction = { x=0, y=0 }
    , rabbitPosition = (0, 0)}


walk : Direction -> Model -> Model
walk dir m = 
    let (x, y) = m.rabbitPosition
    in { m | direction <- dir, rabbitPosition <- (x + dir.x, y) }

-- Display
renderRabbit : Form
renderRabbit = toForm <| image 80 100 "http://www.canardpc.com/img/couly/img141.png"

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)

render: (Int, Int) -> Model -> Element
render (width, height) model = 
    collage width height [
        renderBackground (width, height)
        , moveX (toFloat <| fst <| model.rabbitPosition) renderRabbit]

delta : Signal Time
delta = fps 25

input : Signal Direction
input = sampleOn delta Keyboard.arrows

main : Signal Element
main = lift2 render Window.dimensions (foldp walk model input)
```

