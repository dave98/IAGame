	extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time, la escena no se muestra hasta que la funcion este completa
func _ready():
	$Menu.set_visible(false)
	$Logo.set_visible(false)
	$Label.set_visible(false)

	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var is_move_camera = true
	var size_step = 500
	
	if is_move_camera == true:
		if $Camera2D.position.y < 100:
			$Camera2D.position.y += size_step * delta
			#print("Moving Camera: ", $Camera2D.position.y)
		else:
			is_move_camera = false
			$Menu.set_visible(true)
			$Logo.set_visible(true)
			$Label.set_visible(true)
	else:
		$Background.play("city_idle")
		
		
	pass


