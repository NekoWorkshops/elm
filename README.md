# Atelier Programmation Fonctionnelle Réactive (FRP) avec [ELM](http://elm-lang.org)

La Programmation Fonctionnelle Réactive (PFR) est basée sur les flux de données et la propagation des changements à travers l'application de fonctions composites sur les données à traiter.

La donnée dans l'univers de la FRP est appelée *Signal*. Cette donnée peu provenir des périphériques d'entrée tels que la souris et le clavier ou bien d'une réponse d'un serveur.

Dans le language ELM, les *signaux* peuvent être traités en flux en utilisant la fonction `lift` :

```elm
lift asText Mouse.position
```

À chaque modification de la position de la souris, `lift` appliquera la fonction `asText`.
