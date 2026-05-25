extends Node2D

@onready var player: CharacterBody2D = $player

func _ready() -> void:
	if Globals.target_transition_marker != "":
		var spawn_point = find_child(Globals.target_transition_marker)
		
		if spawn_point:
			player.global_position = spawn_point.global_position
			print("Player spawned successfully at: ", spawn_point.name)
		else:
			print("Error: Could not find a marker named ", Globals.target_transition_marker)
			
		Globals.target_transition_marker = ""
