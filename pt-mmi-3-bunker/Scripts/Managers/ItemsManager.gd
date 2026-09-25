extends Resource

# Pour gérer les items qui apparaissent dans l'inventaire

@export_group("Infos")
@export var Nom: String
@export var ID: int

# si on fait pas un carrousel mais un grid
@export_group("Positionnement")
@export var Row: int
@export var Col: int

@export_group("Personnaliser")
@export var Sprite: Texture2D

@export_group("Scripts")
@export var EffetInGame: Script
