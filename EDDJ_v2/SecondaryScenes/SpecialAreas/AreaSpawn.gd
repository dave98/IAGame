extends Area2D

var is_activate = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AreaSpawn_body_entered(body):
	if "Player" in body.name:
		if self.is_activate == true:
			self.is_activate = false #Desactivamos alertspawn hasta el siguiente turno
			$CollisionShape2D.set_disabled(true)
			
			$ReactivateSpawner.start()
			var padre = get_parent()
			padre.receive_enemy_spawn_alert()
		
func _on_ReactivateSpawner_timeout():
	self.is_activate = true
	$CollisionShape2D.set_disabled(false)
	pass # Replace with function body.
