extends Node2D

@onready var interactable_zone = $interactable

func _ready() -> void:
	if interactable_zone:
		interactable_zone.player_entered.connect(_on_player_entered)
		interactable_zone.player_exited.connect(_on_player_exited)

func _on_player_entered(_player: Node2D) -> void:
	Globals.can_brew = true

func _on_player_exited() -> void:
	Globals.can_brew = false
