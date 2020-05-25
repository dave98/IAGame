extends Node

var mario_lives = 3
var actual_level = "res://MarioScenes/Presentation.tscn"

func add_lives():
	self.mario_lives += 1

func take_lives():
	self.mario_lives -=1
	
func get_lives():
	return self.mario_lives

func set_actual_map(path):
	self.actual_level = path

func get_actual_map():
	return self.actual_level

func restore_mario_properties():
	self.mario_lives = 3
	self.actual_level = "res://MarioScenes/Presentation.tscn"



