extends Area2D

const SPEED_X = -7
const SPEED_Y = 10
const IS_REALLY_ABOVE = 10
const FLOOR = Vector2(0, -1)


var velocity = Vector2()
var is_active = false
var is_dead = false

func _physics_process(delta):
	if not self.is_dead:
		if self.is_active:
			self.velocity.y = 0
			self.velocity.x = SPEED_X
			self.position += velocity
	else:
		self.velocity.x = 0
		self.velocity.y = SPEED_Y
		self.position += velocity


func _on_VisibilityNotifier2D_screen_entered():
	$Sounds/Enter.play()
	self.is_active = true
	pass # Replace with function body.


func _on_Bullet_body_entered(body):
	if "Player" in body.name:
		if(self.position.y > body.position.y):
			body.reverse_force(1)
			self.is_dead = true
		else:
			body.kill_player()
	pass # Replace with function body.


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.
