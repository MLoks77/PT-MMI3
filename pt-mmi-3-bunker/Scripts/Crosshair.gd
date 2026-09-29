extends Control

@onready var crosshair_rect: TextureRect = $CenterContainer/CrosshairRect

func _ready() -> void:
	var player = get_parent() # on remonte de Crosshair -> Player
	
	if player and player.Crosshair:
		crosshair_rect.texture = player.Crosshair
		
		# opacité de la crosshair
		if "Opacite" in player:
			var alpha: float = player.Opacite / 100.0
			crosshair_rect.modulate.a = alpha
	else:
		print("Problème avec image / crosshair")
