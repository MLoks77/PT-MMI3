extends CharacterBody3D

#nodes mouvements
@onready var neck: Node3D = $Neck
@onready var head: Node3D = $Neck/Head
@onready var eyes: Node3D = $Neck/Head/eyes
@onready var collision_debout: CollisionShape3D = $Collision_debout
@onready var collision_accroupi: CollisionShape3D = $Collision_accroupi
@onready var ray_cast_3d_collision: RayCast3D = $RayCast3DCrouchCollision
@onready var camera_3d: Camera3D = $Neck/Head/eyes/Camera3D
@onready var animation_player: AnimationPlayer = $Neck/Head/eyes/AnimationPlayer

# nodes interactions
@onready var raycast_objet: RayCast3D = $Neck/Head/eyes/Camera3D/RayCast3D
@onready var position_objet: Marker3D = $Neck/Head/eyes/Camera3D/PositionObjet
var objet_tenu: RigidBody3D = null
# ----------------------------------------------------------------------------------

@export_group("Statistiques_joueur")
@export var vie: float = 10.0
@export var protection: float = 10.0
@export var vitesse_actuelle: float = 5.0
@export var sensi_souris: float = 0.15
@export var poids: float = 10

@export_group("Interactions")
@export var AttractionOnGrab: float = 8.0 # Force d'attraction douce de l'objet
@export var ForceInteraction: float = 20.0 # Vitesse appliquée à l'objet lorsqu'on le lâche

@export_group("Inventaire")
# il faudra faire en sorte de mettre des id d'objets qui prennent aussi
# en compte le positionnement dans l'inventaire si l'on ne le fait pas
# automatiquement et que le joueur peut les déplacer
@export var inventaire: Array[String] = [] #a completer avec le gd itemsmanager

@export_group("Crosshair")
@export var Crosshair: Texture2D
@export_range(0, 100, 1) var Opacite: int = 100

@export_group("Lerp déplacement")
@export var vitesse_lerp: float = 10.0  # variable qui sert à ce que lors des déplacements la vitesse du joueur soit progressive
@export var vitesse_lerp_air: float = 3.0

# ----------------------------------------------------------------------------------
# mouvements vars-------------------------------------------------------------------
# ----------------------------------------------------------------------------------
# variables vitesses
const vitesse_marche: float = 5.0
const vitesse_sprint: float = 8.0
const vitesse_accroupi: float = 3.0

# variables d'état
var isWalking = false
var isSprinting = false
var isCrouching = false
var isSliding = false

# variables slide

var timer_slide = 0.0
var timer_slide_max = 1.0
var vecteur_slide = Vector2.ZERO
var vitesse_slide = 10.0

# variables head bobbing
const vitesse_head_bobbing_sprint = 22.0
const vitesse_head_bobbing_crouch = 14.0
const vitesse_head_bobbing_marche = 10.0

const head_bobbing_sprint_intensite = 0.2
const head_bobbing_crouch_intensite = 0.05
const head_bobbing_marche_intensite = 0.1

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_intensite_actuelle = 0.0

# variables mouvements
const jump_velocity = 4.5
var direction = Vector3.ZERO
var profondeur_crouch = -0.5 # la hauteur de la caméra quand on crouch

# ----------------------------------------------------------------------------------
# mouvements------------------------------------------------------------------------
# ----------------------------------------------------------------------------------
func _ready(): # fonction qui est appelée une fois au lancement
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # pour détecter la souris dans le jeu (nécessaire pour tourner la cam)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensi_souris)) #sans deg_to_rad (convertir en radiants) la sensi est extremement forte
		head.rotate_x(deg_to_rad(-event.relative.y * sensi_souris))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))

func _physics_process(delta: float) -> void:
	
	var input_dir := Input.get_vector("Gauche", "Droite", "Avancer", "Reculer")
	
	# Accroupi + sprint
	if Input.is_action_pressed("Accroupi") || isSliding :
		vitesse_actuelle = lerp(vitesse_actuelle,vitesse_accroupi,delta*vitesse_lerp)
		head.position.y = lerp(head.position.y,profondeur_crouch,delta*vitesse_lerp)
		collision_debout.disabled = true
		collision_accroupi.disabled = false
		
		#logique du début de slide
		
		if isSprinting && input_dir != Vector2.ZERO:
			isSliding = true
			timer_slide = timer_slide_max
			vecteur_slide = input_dir
			print("Sliding")
		
		isWalking = false
		isSprinting = false
		isCrouching = true
		
	elif !ray_cast_3d_collision.is_colliding():
		collision_debout.disabled = false
		collision_accroupi.disabled = true
		head.position.y = lerp(head.position.y,0.0,delta*vitesse_lerp)  #taille du perso
		if Input.is_action_pressed("Sprint"):
			vitesse_actuelle = lerp(vitesse_actuelle,vitesse_sprint,delta*vitesse_lerp)
			
			isWalking = false
			isSprinting = true
			isCrouching = false
		else:
			vitesse_actuelle = lerp(vitesse_actuelle,vitesse_marche,delta*vitesse_lerp)
			isWalking = true
			isSprinting = false
			isCrouching = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		isSliding = false #Slide cancel quand tu sautes
		animation_player.play("jump")

	if isSliding:
		timer_slide -= delta
		if timer_slide <= 0:
			isSliding = false
			print("Sliding end")

	# head bobbing
	if is_on_floor() and not isSliding and input_dir != Vector2.ZERO:
		if isSprinting:
			head_bobbing_intensite_actuelle = head_bobbing_sprint_intensite
			head_bobbing_index += vitesse_head_bobbing_sprint * delta
		elif isCrouching:
			head_bobbing_intensite_actuelle = head_bobbing_crouch_intensite
			head_bobbing_index += vitesse_head_bobbing_crouch * delta
		else: # Marche par défaut
			head_bobbing_intensite_actuelle = head_bobbing_marche_intensite
			head_bobbing_index += vitesse_head_bobbing_marche * delta

		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index * 0.5)

		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_intensite_actuelle / 2.0), delta * vitesse_lerp)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_intensite_actuelle, delta * vitesse_lerp)
	else:
		head_bobbing_index = 0.0
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * vitesse_lerp)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * vitesse_lerp)
		
	if is_on_floor() && !isSliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2) + 0.5

	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*vitesse_lerp)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*vitesse_lerp_air)
	
	if isSliding:
		direction = (transform.basis * Vector3(vecteur_slide.x,0,vecteur_slide.y)).normalized()
		vitesse_actuelle = (timer_slide + 0.1) * vitesse_slide
	
	if direction:
		velocity.x = direction.x * vitesse_actuelle
		velocity.z = direction.z * vitesse_actuelle
		#vitesse custom pour le slide (ralentit avec le temps)
	else:
		velocity.x = move_toward(velocity.x, 0, vitesse_actuelle)
		velocity.z = move_toward(velocity.z, 0, vitesse_actuelle)

	move_and_slide()
	_physics_grab(delta)
	
# ----------------------------------------------------------------------------------
# Interactions grab et lacher ------------------------------------------------------
# ----------------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interagir"):
		if objet_tenu:
			_Lacher()
		else:
			_Essaie_Soulever()

func _physics_grab(_delta: float) -> void:
	if objet_tenu and not Input.is_action_pressed("Interagir"):
		_Lacher()
		return
	
	if objet_tenu:
		var target_pos = position_objet.global_position
		var current_pos = objet_tenu.global_position
		var offset = target_pos - current_pos
		
		objet_tenu.linear_velocity = offset * 20.0
		objet_tenu.angular_velocity *= 0.5

func _Essaie_Soulever() -> void:
	if raycast_objet.is_colliding():
		var collider = raycast_objet.get_collider()
		
		if collider is RigidBody3D and "CanBeHeld" in collider and collider.CanBeHeld:
			objet_tenu = collider
			objet_tenu._Soulever()

func _Lacher() -> void:
	if objet_tenu:
		objet_tenu._Lacher()
		objet_tenu = null
