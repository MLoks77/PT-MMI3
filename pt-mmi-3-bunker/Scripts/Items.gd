#script a mettre sur les parties des objets cassé juste pour avoir la possibilité de soulever les parties
extends RigidBody3D

@export_group("Interactions")
@export var snap_velocity: float = 25.0
@export var distance_de_lacher: float = 2.0
@export var CanBeHeld: bool = true

func _ready() -> void:
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 4

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
	var facteur_masse: float = 1.0 / (1.0 + maxf(mass - 1.0, 0.0) * 0.15)
	linear_velocity = direction * distance * snap_velocity * facteur_masse
	angular_velocity *= 0.5
	return true
