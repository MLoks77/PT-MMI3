extends RigidBody3D

# Props = objets : genre une chaise, une caisse, une tasse

@export_group("Statistiques_items")

@export var Vie: float = 100.0:
	set(value):
		Vie = value
		if Vie <= 0.0 and is_inside_tree(): # is inside tree permet de savoir si le node est dans la scene
			call_deferred("ChangementModel")

@export_group("Interactions")
@export var snap_velocity: float = 25.0
@export var distance_de_lacher: float = 2.0

@export var CanBePickedUp: bool = false # peut être tenu en maintenant E
@export var CanBeHeld: bool = true # peut être tenu en maintenant E
@export var CanBeBroken: bool = false # peut se casser si on le fait tomber / tape
@export var CanBePushed: bool = true # peut etre pousse par le joueur

@export_group("States")
var IsBroken: bool = false
@export var BrokenModel: PackedScene

var _current_model: Node

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
	var facteur_masse: float = 1.0 / (1.0 + maxf(mass - 1.0, 0.0) * 0.15)
	linear_velocity = direction * distance * snap_velocity * facteur_masse
	angular_velocity *= 0.5
	return true

func _ready() -> void:
	# variables trouvables dans les paramètres du rigidbody
	continuous_cd = true # si on lance, pour éviter de passer à travers les murs
	contact_monitor = true # pour calculer si le props doit être lacher automatiquement dans le cas où il est bloqué*
	max_contacts_reported = 4
	_current_model = get_node_or_null("chaisefusion")
	
	# Initialise les morceaux des objets s'ils sont déjà présents dans la scène
	_preparer_morceaux_enfants(self)
	
	if Vie <= 0.0:
		ChangementModel()
	
# ----------------------------------------------------------------------------------

# https://www.youtube.com/watch?v=3PbGFMFh4pU

# fonction pour passer du model complet à BrokenModel ( model avec toute les pièces détachés ) quand sa vie passe à 0

func ChangementModel() -> void:
	if not CanBeBroken or BrokenModel == null or IsBroken:
		return

	IsBroken = true
	CanBeHeld = false
	freeze = true
	collision_layer = 0
	collision_mask = 0

	for enfant in get_children():
		if enfant is CollisionShape3D:
			enfant.set_deferred("disabled", true)

	if _current_model != null:
		remove_child(_current_model)
		_current_model.queue_free()

	_current_model = BrokenModel.instantiate()
	add_child(_current_model)
	
	# Active la physique et éparpille les morceaux de la version cassée
	_liberer_et_eparpiller_morceaux(_current_model)

# ----------------------------------------------------------------------------------
# Fonctions internes pour la gestion des morceaux destructibles

func _preparer_morceaux_enfants(noeud_parent: Node) -> void:
	for enfant in noeud_parent.get_children():
		if enfant is RigidBody3D and enfant != self:
			enfant.freeze = true
			if "CanBeHeld" in enfant:
				enfant.CanBeHeld = false
		_preparer_morceaux_enfants(enfant)

func _liberer_et_eparpiller_morceaux(noeud_parent: Node) -> void:
	for enfant in noeud_parent.get_children():
		if enfant is RigidBody3D and enfant != self:
			enfant.freeze = false
			if "CanBeHeld" in enfant:
				enfant.CanBeHeld = true
			
			# Impulsion aléatoire pour éparpiller chaque pièce
			var dispersion = Vector3(
				randf_range(-1.0, 1.0),
				randf_range(0.2, 1.2),
				randf_range(-1.0, 1.0)
			).normalized()
			
			enfant.apply_central_impulse(dispersion * 3.5)
		
		_liberer_et_eparpiller_morceaux(enfant)
