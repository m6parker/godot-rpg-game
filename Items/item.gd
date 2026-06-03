@tool
extends Area2D

@export var data: ItemData

func _ready() -> void:
	if data:
		$Sprite2D.texture = data.item_texture
	else:
		print("worldItem spawned without item_data!")

# called by the players CollectionArea
func get_item_data() -> ItemData:
	return data

func collect() -> void:
	# todo: sound or particle effect here later
	queue_free()
