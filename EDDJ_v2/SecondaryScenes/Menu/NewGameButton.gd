extends Button

func _on_NewGameButton_pressed():
	get_tree().change_scene("MainScenes/Scene3.tscn")
	pass # Replace with function body.
	
func _on_OptionsButtom_pressed():
	print("Mostrando Opciones")
	pass # Replace with function body.

func _on_ContinueButton_pressed():
	print("Cargando Partidas")
	pass # Replace with function body.

func _on_ExitButton_pressed():
	get_tree().quit()
	pass # Replace with function body.