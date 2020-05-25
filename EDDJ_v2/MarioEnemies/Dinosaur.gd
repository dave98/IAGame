extends KinematicBody2D

const GRAVITY = 30 
const SPEED = 100
const SPEED_SHIELD = 200
const IS_REALLY_ABOVE = 10
const FLOOR = Vector2(0, -1)

export(int, 1, 2) var turtle_type = 1

var velocity = Vector2()
var direction = 1
var is_dead = false
var killing = true # Parte del procedimiento para matar una objeto

var process_turtle_type = ""

var total_states = 2
var states = 1 #State 1 = walking
			   #State 2 = stand_shield
			   #State 3 = runnig shield

# Called when the node enters the scene tree for the first time.
func _ready():
	self.direction = -1
	$RayCastBorde.position.x *= -1	
	self.process_turtle_type = "_" + String(self.turtle_type)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if self.is_dead == false:
		if self.states == 1:
			state_1()
		elif self.states == 2:
			state_2()
		else:
			pass
	else:
		self.kill_character()
	
func state_2():
	$CollisionShape2D.disabled = true        # Solo cambiamos la colisión para que se adpate al caparazón
	$CollisionShape2DShield.disabled = false
	velocity.x = SPEED_SHIELD * direction
	$Sprite.play("koopa_shield_walk" + self.process_turtle_type)
	turn_around()
	
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)			
	if is_on_wall():
		direction = -direction
		$RayCastBorde.position.x *= -1 #Cambiando posicion del reycast en caso giremos el personaje
		#$Sounds/hit.play()

	if $RayCastBorde.is_colliding() == false and is_on_floor(): #Definiendo el Raycast de colision, basicamente si no hay colision cambia de direccion 
		direction = -direction
		$RayCastBorde.position.x *= -1	
		
	
func state_1():
	velocity.x = SPEED * direction
	$Sprite.play("koopa_walk" + self.process_turtle_type)
	turn_around()
	
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)		
	
	if is_on_wall():
		direction = -direction
		$RayCastBorde.position.x *= -1 #Cambiando posicion del reycast en caso giremos el personaje
	

	if $RayCastBorde.is_colliding() == false and is_on_floor(): #Definiendo el Raycast de colision, basicamente si no hay colision cambia de direccion 
		direction = -direction
		$RayCastBorde.position.x *= -1	

func turn_around():
	if direction == 1:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true

func increase_state():
	if self.states < self.total_states:
		self.states += 1

func get_state():
	return self.states


func is_above(var b_y, var b_self):
	if abs(b_self - b_y) > IS_REALLY_ABOVE:
		return true
	else:
		return false

func kill_character():
	self.is_dead = true
	
	$CollisionShape2D.set_disabled(true)
	$CollisionShape2DShield.set_disabled(true)
	$TouchBody/CollisionShape2D.set_disabled(true)
	
	if self.killing:
		self.velocity = Vector2(-1 * self.direction * 400, -100)
		self.killing = false
	else:
		velocity.y += GRAVITY
		self.velocity = move_and_slide(velocity, FLOOR)
		$Sprite.play("koopa_death" + self.process_turtle_type )

	

func _on_TouchBody_body_entered(body):
	if "Player" in body.name:
		if self.is_above(body.position.y, self.position.y):
			body.reverse_force(1)
			if self.states == 2:
				self.kill_character()
			else:
				self.increase_state()
		else:
			body.kill_player() # Killing mario
				
func _on_VisibilityNotifier2D_screen_exited():
	if self.is_dead:
		queue_free()
