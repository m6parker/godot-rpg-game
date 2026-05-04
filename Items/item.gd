@tool
extends Area2D

@export var data: ItemData

func _ready() -> void:
	if data:
		$Sprite2D.texture = data.item_texture
	else:
		print("WorldItem spawned without ItemData!")

# This is called by the Player's 'CollectionArea'
func get_item_data() -> ItemData:
	return data

func collect() -> void:
	# You can add a sound or particle effect here later
	queue_free()
