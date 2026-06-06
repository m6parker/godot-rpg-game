extends Node2D

@onready var interactable_zone = $interactable

func _ready() -> void:
	if interactable_zone:
		interactable_zone.player_entered.connect(_on_player_entered)
		interactable_zone.player_exited.connect(_on_player_exited)

# when the player gets close to the brewing stand theyre able to use it
func _on_player_entered(_player: Node2D) -> void:
	Globals.can_brew = true

# the player can no longer brew anything from too far away
func _on_player_exited() -> void:
	Globals.can_brew = false
