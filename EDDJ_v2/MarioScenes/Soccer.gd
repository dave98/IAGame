extends KinematicBody2D


const GRAVITY = 30
const SPEED = 200
const IS_REALLY_ABOVE = 10
const FLOOR = Vector2(0, -1)
const JUMP_VAL = -700

var velocity = Vector2()
var direction = 1
var is_dead = false
var killing = true # Parte del procedimiento para matar una objeto
var is_sounded = false

var states = 1
var idle_posibility = 0
var lives = 2
var can_be_damaged = true

# Called when the node enters the scene tree for the first time.
func _ready():
	self.states = 1
	self.jump_time()


func _physics_process(delta):
	turn_aroun()
	if self.is_dead == false:
		if self.states == 1:
			self.state_1()
		elif self.states == 2:
			self.state_2()
		elif self.states == 3:
			self.state_3()
		elif self.states == 4:
			self.state_4()
	else:
		self.kill_character()
		
func state_1(): # Idle State
	if self.idle_posibility < 40:
		$Sprite.play("soccer_idle")
	else:
		if is_on_floor():
			velocity.y = JUMP_VAL
	
	if velocity.y < 0:
		$Sprite.play("soccer_jump")
	elif velocity.y > 0:
		$Sprite.play("soccer_fall")
	
	
	velocity.x = 0
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)

	
func state_2():
	$Sprite.play("soccer_turn")
	velocity.x = 0
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)
	self.states = 3

func state_3():
	$Sprite.play("soccer_see")
	velocity.x = 0
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)

func state_4():
	velocity.x = SPEED * direction
	velocity.y += GRAVITY
	$Sprite.play("soccer_run")
	velocity = move_and_slide(velocity, FLOOR)
	
	if is_on_wall():
		self.direction = -self.direction
		
func state_5():
	self.states = 5
	if is_on_floor():
		$Sprite.play("soccer_hitted")
		self.can_be_damaged = false
		yield($Sprite,"animation_finished")
		self.can_be_damaged = true
		self.lives -= 1
		self.states = 4
	else:
		$Sprite.play("soccer_idle")	
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)
	
func state_4_duration():
	if self.states != 4:
		$TimeAttack.start()
		yield($TimeAttack, "timeout")
		self.states = 3
	
func jump_time():
	while(true):
		$TimeJump.start()
		yield($TimeJump, "timeout")
		self.idle_posibility = randi()%100

func turn_aroun():
	if self.direction == 1:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
	
	
func point_to_player(var p_pos_x):
	if self.position.x < p_pos_x:
		self.direction = 1
	else:
		self.direction = -1
	


func _on_AreaDetection_body_entered(body):
	if "Player" in body.name:
		self.is_sounded = true
		self.point_to_player(body.position.x)
		self.states = 2

func _on_AreaDetection_body_exited(body):
	if "Player" in body.name:
		self.point_to_player(body.position.x)
		self.states = 1
	
func _on_AreaAction_body_entered(body):
	if "Player" in body.name:
		self.point_to_player(body.position.x)
		if self.states != 5:
			self.states = 4
			self.state_4_duration()
	
func _on_Sprite_frame_changed():
	if $Sprite.get_animation() == "soccer_run":
		match $Sprite.get_frame():
			0:
				$Sounds/run.play()
				
	elif $Sprite.get_animation() == "soccer_jump":
		match $Sprite.get_frame():
			0:
				if self.is_sounded:
					$Sounds/jump.play()
				
			
	pass # Replace with function body.

func is_above(var b_y, var b_self):
	if abs(b_self - b_y) > IS_REALLY_ABOVE:
		return true
	else:
		return false

func kill_character():
	self.is_dead = true
	
	$CollisionShape2D.set_disabled(true)
	$AreaAction/CollisionShape2D.set_disabled(true)
	$AreaDetection/CollisionShape2D.set_disabled(true)
	$Area2D/CollisionShape2D.set_disabled(true)
	
	if self.killing:
		self.velocity = Vector2(-1 * self.direction * 400, -100)
		self.killing = false
	
	else:
		velocity.y += GRAVITY
		self.velocity = move_and_slide(velocity, FLOOR)
		$Sprite.play("soccer_death")

	

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		if self.is_above(body.position.y, self.position.y):
			if not self.can_be_damaged:
				body.reverse_force(2, 3)
			else:
				if self.lives > 0:
					body.reverse_force(2, 2)	
					self.state_5()
				elif self.lives == 0:
					body.reverse_force(1, 1)
					self.kill_character()
		else:
			body.kill_player()
	pass # Replace with function body.


func _on_VisibilityNotifier2D_screen_exited():
	if self.is_dead:
		queue_free()
