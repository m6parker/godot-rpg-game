extends Area2D

@export_file("*.tscn") var target_scene: String
@export var target_spawn_marker: String

var can_interact: bool = false

#only open the doorway for the player, ignore other entities that could potentially interact
func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		can_interact = true
	

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		can_interact = false


func _unhandled_input(event: InputEvent) -> void:
	if can_interact && event.is_action_pressed("interact"):
		for body in get_overlapping_bodies():
			if body.name == "player" or body.is_in_group("player"):
				can_interact = false 
				
				# change scene and set where player will spawn to/from
				Globals.target_transition_marker = target_spawn_marker
				get_tree().call_deferred("change_scene_to_file", target_scene)
				break
