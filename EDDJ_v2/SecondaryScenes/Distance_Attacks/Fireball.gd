extends Area2D

const SPEED = 800

var velocity = Vector2()
var direction = 1
var is_being_destroy = false
# Called when the node enters the scene tree for the first time.

var padre = get_parent() #Obtenemos al padre

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	velocity.x = SPEED * delta * direction #Move_Slide multiplica automaticamente
	if !is_being_destroy:
		translate(velocity)
		$SpriteFireball.play("Traveling")
	
func set_variable_direction(dir):
	direction = dir
	if direction == -1:
		$SpriteFireball.flip_h = true

func _on_VisibilityNotifier2D_screen_exited():
	queue_free() #Destroy Object
	 
func _on_Fireball_body_entered(body):
	# Comportamiento frente a objetos
	if "Enemy_Skull" in body.name:
		body.dead()
		var padre = self.get_parent()
		padre.receive_objective_shoot()
		
	#destroying_animation()	
	is_being_destroy = true
	$SpriteFireball.play("Destroying")
	velocity.x = 0
	yield($SpriteFireball, "animation_finished")

	queue_free() 
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	