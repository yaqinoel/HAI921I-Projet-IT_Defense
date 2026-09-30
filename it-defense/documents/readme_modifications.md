# Structure des fichiers

- `assets/` contient les images et les ressources graphiques. Par exemple, `assets/tiles/ground_tileset.tres` définit les tuiles utilisées pour dessiner le sol.

- `data/` contient les paramètres des éléments du jeu. Par exemple, `data/threats/virus.tres` définit les caractéristiques du virus, comme sa vitesse et sa santé.

- `scenes/` contient les scènes `.tscn` : le jeu principal, les niveaux, le sol et les dangers.

- `scripts/` contient la logique du jeu et les définitions des ressources personnalisées.

## Comment les fichiers sont liés

`main.tscn` charge `level_01.tscn`, qui utilise `ground.tscn` pour afficher le sol. Celui-ci utilise `ground_tileset.tres`.

`danger_data.gd` définit les propriétés communes à tous les dangers. Les fichiers `.tres` sont créés à partir de cette classe et permettent de configurer facilement des valeurs différentes pour chaque type de danger.

Chaque scène de danger (`.tscn`) utilise son propre script, qui hérite de `danger.gd`. Ce script possède une propriété `data` commune, à laquelle on associe le fichier `.tres` correspondant pour définir les valeurs du danger.

## Génération des dangers

Dans `level_01.tscn`, le nœud `DangerSpawner` utilise le script `danger_spawner.gd`. Son `Timer` déclenche la création d'un danger à intervalles réguliers. La durée de cet intervalle peut être modifiée dans l'Inspecteur.

Les nœuds `Lane0`, `Lane1` et `Lane2` sont des `Marker2D` qui indiquent les points d'apparition des dangers. On peut les déplacer à la souris dans la scène ou modifier leur position dans la section `Transform` de l'Inspecteur.

Le script `danger_spawner.gd` expose un tableau `dangers` grâce à `@export`. Pour choisir les dangers qui peuvent apparaître, sélectionnez le nœud `DangerSpawner`, puis ajoutez leurs scènes `.tscn` à ce tableau dans l'Inspecteur.

À chaque déclenchement, le script choisit au hasard une scène dans ce tableau (actuellement `virus.tscn` ou `phishing.tscn`), puis un point d'apparition parmi `Lane0`, `Lane1` et `Lane2`. Le nouveau danger est ajouté au nœud `Dangers` du niveau et placé au point choisi.
