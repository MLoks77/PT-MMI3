extends RigidBody3D

# Props = objets : genre une chaise, une caisse, une tasse

@export_group("Statistiques_items")
@export var Vie: float = 100
@export var Poids: int = 70

@export_group("Booleans")
@export var CanBeBroken : bool = false # peut se casser si on le fait tomber
@export var CanBeHeld : bool = true # peut être tenu en maintenant E

@export_group("States")
@export var IsBroken : bool = false 
