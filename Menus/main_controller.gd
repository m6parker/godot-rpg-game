extends Node2D

var level = "World"

func _on_new_button_pressed() -> void:
	get_tree().change_scene_to_file(str("res://World/", level, ".tscn"))


func _on_load_button_pressed() -> void:
	get_tree().change_scene_to_file(str("res://World/", level, ".tscn"))


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_help_button_pressed() -> void:
	pass


func _on_settings_button_pressed() -> void:
	$settings_container.visible = true
	$main_buttons.visible = false


func _on_back_button_2_pressed() -> void:
	$settings_container.visible = false
	$main_buttons.visible = true


func _on_credits_button_pressed() -> void:
	$credits_container.visible = true
	$main_buttons.visible = false
	$settings_container.visible = false


func _on_back_button_pressed() -> void:
	$credits_container.visible = false
	$settings_container.visible = false
	$main_buttons.visible = true
