extends Area2D

# This is where you will drag your .tres file in the Inspector
@export var data: ItemData

func _ready() -> void:
	if data:
		# Automatically set the sprite to the resource's texture
		$Sprite2D.texture = data.item_texture
	else:
		print("Warning: WorldItem spawned without ItemData!")

# This is called by the Player's 'CollectionArea'
func get_item_data() -> ItemData:
	return data

func collect() -> void:
	# You can add a sound or particle effect here later
	queue_free()
