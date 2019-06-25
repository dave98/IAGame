extends Area2D

var generate_enemies = false;
var max_enemies = 5;
var behavior = 0; #Variable que define el comportamiento de los enemigos

var padre = get_parent()
const ENEMY = preload("res://SecondaryScenes/Enemies/Enemy_Skull.tscn")

func _ready():
	pass # Replace with function body.

func _process(delta):
	if self.generate_enemies == true:
		self.generate_enemies = false;
		for i in range(self.max_enemies):
			var temp_enemy = ENEMY.instance()
			get_parent().add_child(temp_enemy)
			temp_enemy.position = $CollisionShape2D.global_position
			temp_enemy.position.x += randi() % 20

func activate_spawner():
	self.generate_enemies = true

func set_enemy_characteristics(var _max_en, var _behavior):
	self.max_enemies = _max_en
	self.behavior = _behavior