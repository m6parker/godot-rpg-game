extends Node

var items: Dictionary = {}

func _ready() -> void:
	load_items_from_json("res://data/items.json")

func load_items_from_json(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		push_error("JSON file not found at: " + file_path)
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var raw_data = JSON.parse_string(json_text)
	if raw_data == null:
		push_error("Failed to parse items JSON. Check for syntax errors!")
		return
		
	# loop thru the json file and pull data
	for item_data in raw_data:
		var new_item = ItemData.new()
		
		new_item.item_name = item_data["name"]
		new_item.description = item_data["description"]
		
		if item_data.has("type"):
			new_item.item_type = item_data["type"]
		else:
			new_item.item_type = "misc"
		
		var expected_path = "res://assets/items/" + new_item.item_name.to_lower() + ".png"
		if ResourceLoader.exists(expected_path):
			new_item.item_texture = load(expected_path)
		else:
			new_item.item_texture = load("res://assets/items/acorn.png")
			print("failed to find path '", expected_path, "' for item: '", new_item.item_name, "'")
			
		# Save to global dictionary
		items[item_data["name"]] = new_item
