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

## Composition d'images dans un cadre dynamique

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

