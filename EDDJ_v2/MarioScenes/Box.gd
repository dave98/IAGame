extends StaticBody2D


const IS_REALLY_DOWN = 10
export(int, 1, 3) var type_of_box = 1 # 1 for coins and 2 for mushroms

const COIN = preload("res://MarioScenes/Coin.tscn")
const MUSHROM = preload("res://MarioScenes/Mushrom.tscn")

var is_done = false # is_done cuando la caja ya fue usada

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	if self.is_done == false:
		$Sprite.play("idle")
	else:
		$Sprite.play("done")

func is_down(var b_y, var pos_y): # Si realmente es golpeado de abajo
	if b_y > pos_y and abs(b_y - pos_y) > IS_REALLY_DOWN:
		return true
	else:
		return false

func create_product(var direction):
	if type_of_box == 1: #For money
		var coin = COIN.instance()
		get_parent().add_child(coin)
		coin.position = self.global_position
		coin.is_ephimeral = true
	elif type_of_box == 2:
		var mushrom = MUSHROM.instance()
		get_parent().add_child(mushrom)
		mushrom.position = self.global_position + Vector2(0, -10)	
		mushrom.state = 0
		if direction < 0:
			mushrom.direction = -1
		else:
			mushrom.direction = 1
	elif type_of_box == 3:
		var mushrom = MUSHROM.instance()
		mushrom.mushrom_type = 2
		get_parent().add_child(mushrom) # Asumiendo que todo lo que esta antes de aqui se utilizará en la funció ready
		mushrom.position = self.global_position + Vector2(0, -10)	
		mushrom.state = 0
		#mushrom.mushrom_type = 2
		if direction < 0:
			mushrom.direction = -1
		else:
			mushrom.direction = 1
		

func stop_monitoring(): # Liberando recursos
	$Area2D.free()
	$Area2DEnemies.free()
	
func jump():
	self.position -= Vector2(0, 5)
	var t = Timer.new()
	t.set_wait_time(0.07)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	self.position -= Vector2(0, -5)
	self.stop_monitoring()    # Tras efecto del salto liberamos nuestra area de detección 

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		if self.is_down(body.position.y, self.position.y):
			self.create_product(body.position.x - self.position.x)
			self.jump()
			self.is_done = true
			
	
	pass # Replace with function body.


func _on_Area2DEnemies_body_entered(body):
	if "Turtle" in body.name:
		if body.get_state() == 3:
			self.create_product(body.position.x - self.position.x)
			self.jump()
			self.is_done = true
	pass # Replace with function body.
