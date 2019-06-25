extends Area2D

export var founded = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AreaOculta_body_entered(body):
	if "Player" in body.name:
		body.areas_exploradas += 1
		if founded == true:
			$Audio.play()
			$CollisionShape2D.set_disabled(true)
			yield($Audio, "finished")
			
		self.queue_free()

	pass # Replace with function body.
