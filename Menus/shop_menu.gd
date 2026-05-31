extends CanvasLayer

@export var item_ui_scene: PackedScene 
@onready var list_container: VBoxContainer = $ScrollContainer/VBoxContainer

const JSON_PATH = "res://items.json"

func _ready() -> void:
	load_shop_items()

func load_shop_items() -> void:
	if not FileAccess.file_exists(JSON_PATH):
		push_error("missing json file: " + JSON_PATH)
		return
	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	# parsing
	var items_data = JSON.parse_string(json_string)
	
	if items_data == null:
		push_error("failed to parse json string")
		return
		
	# clear ui
	for child in list_container.get_children():
		child.queue_free()
		
	# loop thru and create ui elements
	for item in items_data:
		if item is Dictionary:
			create_item_element(item)

func create_item_element(data: Dictionary) -> void:
	var item_element = item_ui_scene.instantiate()
	list_container.add_child(item_element)
	print(item_element)
	if item_element.has_method("setup"):
		item_element.setup(data)
