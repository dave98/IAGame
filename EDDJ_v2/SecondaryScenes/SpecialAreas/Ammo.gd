extends Area2D

var time_alive = 0.0
var is_dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if is_dead == false:
		time_alive += delta
	else:
		destroy()

func destroy():
	self.queue_free()

func _on_Ammo_body_entered(body):	
	if "Player" in body.name:
		body.give_ammo()
		var padre = get_parent()
		padre.receive_health_death_timer(time_alive)
		
		is_dead = true
	pass # Replace with function body.	pass # Replace with function body.
