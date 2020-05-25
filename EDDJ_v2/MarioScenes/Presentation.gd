extends Control

var button_1 = false
var button_2 = false

func _ready():
	pass # Replace with function body.

func _on_Button2_pressed():
	if self.button_2 != true:
		self.button_1 = true
		self.button_2 = true
		$Sounds/Select.play()
		$Objects/Coin2.destroy_object()
	
		$TimerSelection.start()
		yield($TimerSelection, "timeout")
		get_tree().quit()


func _on_Button_pressed():
	if self.button_1 != true:
		self.button_2 = true
		self.button_1 = true
		$Sounds/Select.play()
		$Objects/Coin.destroy_object()
	
		SceneChanger.change_scene("res://MarioScenes/TestScene.tscn")
