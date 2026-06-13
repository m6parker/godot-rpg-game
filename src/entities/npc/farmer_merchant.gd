extends CharacterBody2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var shop_menu: CanvasLayer
var player_in_range: bool = false

func _ready() -> void:
	animated_sprite.play("idle")
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	if shop_menu:
		shop_menu.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range:
		open_shop_ui()

func _on_dialogue_finished() -> void:
	if player_in_range and shop_menu:
		open_shop_ui()

func open_shop_ui() -> void:
	shop_menu.show()

func _on_player_entered(body: Node2D) -> void:
	player_in_range = true

func _on_player_exited(body: Node2D) -> void:
	player_in_range = false
	if shop_menu and shop_menu.visible:
		shop_menu.hide()
