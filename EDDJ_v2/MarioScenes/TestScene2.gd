extends Node2D

var level = "res://MarioScenes/TestScene2.tscn"

func _ready():
	self.pass_level()
	pass # Replace with function body.

func pass_level():
	Global.set_actual_map(self.level)#	pass
