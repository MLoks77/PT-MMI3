extends CSGTorus3D

@export var vitesse: float = 2.0
@export var distance: float = 3.0
@export var vitesse_rotation: float = 1.0

var position_initiale: Vector3
var temps: float = 0.0

func _ready() -> void:
	position_initiale = position

func _process(delta: float) -> void:
	temps += delta * vitesse
	var decalage = sin(temps) * distance
	position = Vector3(position_initiale.x + decalage, position_initiale.y, position_initiale.z)
	rotation.y += vitesse_rotation * delta
