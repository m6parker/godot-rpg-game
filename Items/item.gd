@tool
extends Area2D

@export var item_key_name: String = "acorn":
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
			print("worldItem '" + item_key_name + "' failed to pull from ItemDatabase!")


# called by the players CollectionArea
func get_item_data() -> ItemData:
	return runtime_data


func collect() -> void:
	# todo: sound or particle effect here later
	queue_free()


func _fetch_item_from_database() -> void:
	for key in ItemDatabase.items.keys():
		if key.to_lower() == item_key_name.to_lower().strip_edges():
			runtime_data = ItemDatabase.items[key]
			break


func _update_sprite_preview() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite == null:
		return
	var expected_path = "res://assets/items/" + item_key_name.to_lower().strip_edges() + ".png"
	if ResourceLoader.exists(expected_path):
		sprite.texture = load(expected_path)
	else:
		if ResourceLoader.exists("res://assets/items/acorn.png"):
			sprite.texture = load("res://assets/items/acorn.png")
