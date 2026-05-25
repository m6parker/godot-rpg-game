extends Area2D

@export_file("*.tscn") var target_scene: String
@export var target_spawn_marker: String

var can_interact: bool = false

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		can_interact = true
	

func _on_body_exited(body: CharacterBody2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		can_interact = false


func _process(_delta: float) -> void:
	if can_interact && Input.is_action_just_pressed("interact"):
		for body in get_overlapping_bodies():
			if body.name == "player" or body.is_in_group("player"):
				Globals.target_transition_marker = target_spawn_marker
				get_tree().change_scene_to_file(target_scene)
				break
