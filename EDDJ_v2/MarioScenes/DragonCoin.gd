extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func destroy_object():
	$Sprite.play("dissapear")
	yield($Sprite, "animation_finished")
	queue_free()

func _on_DragonCoin_body_entered(body):
	if "Player" in body.name:
		$coin_sound.play()
		self.destroy_object()
	pass # Replace with function body.
