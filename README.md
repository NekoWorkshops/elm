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

À chaque modification de la position de la souris, `lift` appliquera la fonction `asText` sur la propriété position.

## Affichage d'une image

Utilisation de l'API [Element](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Graphics-Element)

```elm
main : Element
main = image 80 100 "http://www.canardpc.com/img/couly/img141.png"
```

## Composition d'images

Utilisation de l'API [Collage](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Graphics-Collage)

```elm
renderRabbit : Form
renderRabbit = toForm <| image 80 100 "http://www.canardpc.com/img/couly/img141.png"

renderBackground : (Int, Int) -> Form
renderBackground (width, height) =
    let blue = rgb 100 220 255
    in filled blue <| rect (toFloat width) (toFloat height)
    
main = collage 800 600 [renderBackground (800, 800), renderRabbit] 
```


