@tool
extends Area2D

@export var data: ItemData

func _ready() -> void:
	if data:
		$Sprite2D.texture = data.item_texture
	else:
		print("WorldItem spawned without ItemData!")

# called by the players CollectionArea
func get_item_data() -> ItemData:
	return data

func collect() -> void:
	# sound or particle effect here later
	queue_free()
