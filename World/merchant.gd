extends CharacterBody2D

@onready var interaction_area: Area2D = $InteractionArea
@export var shop_menu: CanvasLayer
@export var npc_id: String = ""
var player_in_range: bool = false

func _ready() -> void:
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	if shop_menu:
		shop_menu.hide()

# removing code from the _process function into here to prevent checking if player is in range a billion times
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range:
		if DialogueManager.is_active:
			DialogueManager.advance_dialogue()
			get_viewport().set_input_as_handled()
		else:
			# start talking if the shop menu is hidden
			if shop_menu and not shop_menu.visible:
				var lines = DialogueManager.get_dialogue_by_id(npc_id)
				DialogueManager.start_dialogue(lines)
				get_viewport().set_input_as_handled()

func _on_dialogue_finished() -> void:
	if player_in_range and shop_menu:
		open_shop_ui()

func open_shop_ui() -> void:
	shop_menu.show()

func _on_player_entered(body: Node2D) -> void:
	player_in_range = true

func _on_player_exited(body: Node2D) -> void:
	player_in_range = false
	if DialogueManager.is_active:
		DialogueManager.end_dialogue()
	if shop_menu and shop_menu.visible:
		shop_menu.hide()
