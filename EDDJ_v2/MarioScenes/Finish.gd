extends Area2D

export(String, FILE, "*.tscn") var next_level
var is_passed = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Finish_body_entered(body):
	if "Player" in body.name and $Area2D.visible == true:
		$Area2D.visible = false
		body.level_ended(next_level)
		pass

func _on_Area2D_body_entered(body):
	if "Player" in body.name and $Area2D.visible == true:
		$Area2D.visible = false
		body.level_ended(next_level)