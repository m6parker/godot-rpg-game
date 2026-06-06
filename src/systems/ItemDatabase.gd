extends Node

var items: Dictionary = {}

func _ready() -> void:
	load_items_from_json("res://data/items.json")

func load_items_from_json(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		push_error("json file not found at: " + file_path)
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	#parse the json data into readable text
	var raw_data = JSON.parse_string(json_text)
	if raw_data == null:
		push_error("error parsing")
		return
		
	# loop thru the text and pull data
	for item_data in raw_data:
		var new_item = ItemData.new()
		
		new_item.item_name = item_data["name"]
		new_item.description = item_data["description"]
		new_item.price = item_data.get("price", 0)
		
		if item_data.has("type"):
			new_item.item_type = item_data["type"]
		else:
			new_item.item_type = "misc"
		
		# formatting
		var clean_file_name = new_item.item_name.to_lower().replace(" ", "_")
		var expected_path = "res://assets/items/" + clean_file_name + ".png"
		
		# potions are organized in a seperate file,
		# check what type of item, if potion relate, check potion folder
		if "potion" in clean_file_name:
			expected_path = "res://assets/potions/" + clean_file_name + ".png"
		print("expected path: ", expected_path)
		
		if ResourceLoader.exists(expected_path):
			new_item.item_texture = load(expected_path)
		else:
			# default to acorn image if the png image cannot be found
			new_item.item_texture = load("res://assets/items/acorn.png")
			print("failed to find path '", expected_path, "' for item: '", new_item.item_name, "'")
			
		items[item_data["name"]] = new_item
