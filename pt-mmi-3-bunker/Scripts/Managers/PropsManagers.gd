extends RigidBody3D

# Props = objets : genre une chaise, une caisse, une tasse

@export_group("Statistiques_items")
@export var Vie: float = 100
@export var poids: float = 10
@export_group("Interactions")

@export var CanBePickedUp : bool = false # peut être tenu en maintenant E
@export var CanBeHeld : bool = true # peut être tenu en maintenant E
@export var CanBeBroken : bool = false # peut se casser si on le fait tomber / tape

@export_group("States")
var IsBroken : bool = false 
@export var BrokenModel : PackedScene

# ----------------------------------------------------------------------------------

func _Soulever() -> void:
	lock_rotation = true

func _Lacher() -> void:
	lock_rotation = false

func _ready() -> void:
	continuous_cd = true # si on lance, pour éviter de passer à travers les murs
