extends Area2D

const SPEED = 800
const TIME_ALIVE = 0.8

var velocity = Vector2()
var direction = 1
var is_being_destroy = false
var living = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	velocity.x = SPEED * delta * direction #Move_Slide multiplica automaticamente
	living += delta
	if !is_being_destroy:
		translate(velocity)
		$SpriteHit.play("Travel")
		
		if living > TIME_ALIVE:
			is_being_destroy = true
	else:
		destroying()
		queue_free()
		
func set_variable_direction(dir):
	direction = dir
	if direction == -1:
		$SpriteHit.flip_h = true

func _on_EnemyHit_body_entered(body):
	if "Player" in body.name:
		body.stunt_player(2, 0)
	is_being_destroy = true

func destroying():
	velocity.x = 0
	$SpriteHit.play("Detroy")
	yield($SpriteHit, "animation_finished")
	
