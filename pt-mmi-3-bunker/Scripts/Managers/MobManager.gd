extends CharacterBody3D

@export_group("Statistiques")

@export var Vie: float = 200
@export var Protection: float = 0
@export var Vitesse: float = 50
@export var Poids: int = 70
@export var VitesseAttaque: float = 1

# faudra assigner un path3d pour créer une patrouille / ne rien mettre
@export_group("Fonctionnalité")

@export var chemin_patrouille: Path3D

@export_group("States")
@export var isActive: bool = true # hostile ou pas / permet aussi de juste le laisser immobile
@export var isStunned: bool = false # est étourdi ou pas
@export var isBleeding: bool = false # saigne ou pas
