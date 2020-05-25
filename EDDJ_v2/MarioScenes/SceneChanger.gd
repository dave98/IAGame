extends CanvasLayer

onready var animation_player = $AnimationPlayer
onready var black = $Control/ColorRect

func change_scene(path, delay = 1.0):
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play_backwards("fade")
	yield(animation_player, "animation_finished")
	get_tree().change_scene(path)
	animation_player.play("fade")	
	emit_signal("scene_changed")