extends CharacterBody3D

#nodes Player
@onready var head: Node3D = $Head
@onready var collision_debout: CollisionShape3D = $Collision_debout
@onready var collision_accroupi: CollisionShape3D = $Collision_accroupi
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@export_group("Statistiques_joueur")
@export var vie: float = 10.0
@export var protection: float = 10.0
@export var vitesse_actuelle: float = 5.0
@export var poids: float = 10.0
@export var sensi_souris = 0.4

@export_group("Inventaire")
# il faudra faire en sorte de mettre des id d'objets qui prennent aussi
# en compte le positionnement dans l'inventaire si l'on ne le fait pas
# automatiquement et que le joueur peut les déplacer
@export var inventaire: Array[String] = [] #a completer avec le gd itemsmanager

# variables vitesses
const vitesse_marche: float = 5.0
const vitesse_sprint: float = 8.0
const vitesse_accroupi: float = 3.0

# variables mouvements
const jump_velocity = 4.5
@export var vitesse_lerp = 10.0  # variable qui sert à ce que lors des déplacements la vitesse du joueur soit progressive
var direction = Vector3.ZERO
var profondeur_crouch = -0.5 # la hauteur de la caméra quand on crouch

func _ready(): # fonction qui est appelée une fois au lancement
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # pour détecter la souris dans le jeu (nécessaire pour tourner la cam)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensi_souris)) #sans deg_to_rad (convertir en radiants) la sensi est extremement forte
		head.rotate_x(deg_to_rad(-event.relative.y * sensi_souris))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))

func _physics_process(delta: float) -> void:
	
	# Accroupi + sprint
	if Input.is_action_pressed("Accroupi"):
		vitesse_actuelle = vitesse_accroupi
		head.position.y = lerp(head.position.y,1.8 + profondeur_crouch,delta*vitesse_lerp)
		collision_debout.disabled = true
		collision_accroupi.disabled = false
	elif !ray_cast_3d.is_colliding():
		collision_debout.disabled = false
		collision_accroupi.disabled = true
		head.position.y = lerp(head.position.y,1.8,delta*vitesse_lerp)  #taille du perso
		if Input.is_action_pressed("Sprint"):
			vitesse_actuelle = vitesse_sprint
		else:
			vitesse_actuelle = vitesse_marche
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("Gauche", "Droite", "Avancer", "Reculer")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*vitesse_lerp)
	
	if direction:
		velocity.x = direction.x * vitesse_actuelle
		velocity.z = direction.z * vitesse_actuelle
	else:
		velocity.x = move_toward(velocity.x, 0, vitesse_actuelle)
		velocity.z = move_toward(velocity.z, 0, vitesse_actuelle)

	move_and_slide()
