@tool
extends Area2D

@export var item_key_name: String = "hoe":
	set(new_name):
		item_key_name = new_name
		if Engine.is_editor_hint():
			_update_sprite_preview()

var runtime_data: ItemData

func _ready() -> void:
	if not Engine.is_editor_hint():
		_fetch_item_from_database()
		if runtime_data:
			$Sprite2D.texture = runtime_data.item_texture
		else:
			print("worldItem '" + item_key_name + "' failed to pull from toolDatabase!")


# called by the players CollectionArea
func get_item_data() -> ItemData:
	return runtime_data


func collect() -> void:
	# todo: sound or particle effect here later
	queue_free()


func _fetch_item_from_database() -> void:
	for key in ToolDatabase.items.keys():
		if key.to_lower() == item_key_name.to_lower().strip_edges():
			runtime_data = ToolDatabase.items[key]
			break


func _update_sprite_preview() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite == null:
		return
		
	# todo - eventually separate the items by categories for organization
	var expected_path = "res://assets/tools/" + item_key_name.to_lower().strip_edges() + ".png"
	if ResourceLoader.exists(expected_path):
		sprite.texture = load(expected_path)
	else:
		# default to the ho image if something goes wrong and the image cannot be found
		if ResourceLoader.exists("res://assets/tools/hoe.png"):
			sprite.texture = load("res://assets/tools/hoe.png")
