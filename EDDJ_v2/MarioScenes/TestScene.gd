extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var level = "res://MarioScenes/TestScene.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pass_level()
	pass # Replace with function body.

func pass_level():
	Global.set_actual_map(self.level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
