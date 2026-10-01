extends RigidBody3D

# Props = objets : genre une chaise, une caisse, une tasse

@export_group("Statistiques_items")
@export var Vie: float = 100
@export var poids: float = 10
@export_group("Interactions")
@export var snap_velocity: float = 25.0
@export var distance_de_lacher: float = 2.0

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

func bouger(prop_container: Node3D) -> bool:
	var distance: float = global_position.distance_to(prop_container.global_position)
	if not get_colliding_bodies().is_empty() and distance > distance_de_lacher:
		_Lacher()
		return false

	var direction: Vector3 = global_position.direction_to(prop_container.global_position)
	var facteur_poids: float = 1.0 / (1.0 + maxf(mass - 1.0, 0.0) * 0.15)
	linear_velocity = direction * distance * snap_velocity * facteur_poids
	angular_velocity *= 0.5
	return true

func _ready() -> void:
	mass = maxf(poids, 0.01)
	continuous_cd = true # si on lance, pour éviter de passer à travers les murs
	contact_monitor = true # pour calculer si le props doit être lacher automatiquement dans le cas où il est bloqué*
	max_contacts_reported = 4
