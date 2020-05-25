extends Area2D

var is_ephimeral = false
var is_sound_played = false # Well i cant go for a different solution 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if self.is_ephimeral:
		self.position += Vector2(0, -15)
		yield(get_tree().create_timer(0.07), "timeout")
		destroy_object()


func destroy_object():
	self.is_ephimeral = false
	$Sprite.play("dissapear")
	if not self.is_sound_played:
		$coind_sound.play()
		self.is_sound_played = true

	yield($Sprite, "animation_finished")
	queue_free()

func _on_Coin_body_entered(body):
	if "Player" in body.name:
		self.destroy_object()
	pass # Replace with function body.
