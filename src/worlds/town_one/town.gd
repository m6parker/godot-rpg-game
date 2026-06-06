extends Node2D

@onready var player: CharacterBody2D = $player

func _ready() -> void:
	if Globals.target_transition_marker != "":
		var marker = find_child(Globals.target_transition_marker, true, false)
		
		if marker and marker is Marker2D:
			player.global_position = marker.global_position
		else:
			push_warning("error: no spawn marker: ", Globals.target_transition_marker)
		
		Globals.target_transition_marker = ""
