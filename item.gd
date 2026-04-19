extends Area2D

@export var item_id: int = 0
@export var item_name: String = "Item"
@export var item_texture: Texture

func _ready() -> void:
	if has_node("Sprite2D") and item_texture:
		$Sprite2D.texture = item_texture


func get_item_data() -> Dictionary:
	return {
		"item_id": item_id,
		"name": item_name,
		"texture": item_texture
	}

func collect() -> void:
	# todo: notification or effect after picking up item
	queue_free()
