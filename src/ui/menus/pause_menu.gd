extends Control



func _on_save_button_pressed() -> void:
	Globals.save_game()

func _on_settings_button_pressed() -> void:
	$settings_container.visible = true
	$main_buttons.visible = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_2_pressed() -> void:
	$settings_container.visible = false
	$main_buttons.visible = true
