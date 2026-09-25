extends CharacterBody3D

@export_group("Statistiques_joueur")

@export var Vie: float = 10
@export var Protection: float = 10
@export var Vitesse: float = 10
@export var Poids: float = 10

@export_group("Inventaire")
# Il faudra faire en sorte de mettre des id d'objets qui prennent aussi
# en compte le positionnement dans l'inventaire si l'on ne le fait pas
# automatiquement et que le joueur peut les déplacer
@export var inventaire: Array[String] = [] # a completer avec le gd ItemsManager
