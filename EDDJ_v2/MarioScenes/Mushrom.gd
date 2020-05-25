extends KinematicBody2D

const GRAVITY = 30 
const SPEED = 100
const FLOOR = Vector2(0, -1)

export(int, 1, 2) var mushrom_type = 1

var velocity = Vector2()
var direction = -1
var process_mushrom_type = ""

var state = 1 #  0 naciendo
			  #  1 caminando

# Called when the node enters the scene tree for the first time.
func _ready():
	self.process_mushrom_type = "_" + String(self.mushrom_type)
	pass # Replace with function body.

func _physics_process(delta):
	if self.state == 1:
		self.state_1()
	else:
		self.state_2()  #State 2  will be excuted once, when mushrom is born


func state_2():
	$Sounds/AudioBorn.play()
	velocity = Vector2(0, -50)
	velocity = move_and_slide(velocity, FLOOR)
	self.state = 1

func state_1():
	velocity.x = SPEED * direction
	$Sprite.play("mushrom" + self.process_mushrom_type)
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)
	
	if is_on_wall():
		self.direction = -self.direction




func destroy_object():
	queue_free()

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		#print("SUPER MARIO")
		if self.mushrom_type == 1:
			body.set_power_up(2) # 1 is actual so dont exists, 2 for mushroms, 3 for flowers and 4 for feathers
		else:
			body.live_up() # 1 is actual so dont exists, 2 for mushroms, 3 for flowers and 4 for feathers
		self.destroy_object()
	
	pass # Replace with function body.
