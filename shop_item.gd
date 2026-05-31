extends Control

@onready var icon: TextureRect = $HBoxContainer/icon
@onready var name_label: Label = $HBoxContainer/name_label
@onready var price_label: Label = $HBoxContainer/price_label
@onready var desc_label: Label = $HBoxContainer/desc_label

func setup(item_data: Dictionary) -> void:
	var id = item_data.get("id", "error")
	var image_path = "res://assets/items/" + id + ".png"
	
	if ResourceLoader.exists(image_path):
		icon.texture = load(image_path)
	else:
		push_warning("error " + image_path)
		# icon.texture = load("res://assets/items/default.png")
	
	name_label.text = item_data.get("name", "error")
	price_label.text = str(item_data.get("price", 0)) + " gold"
	desc_label.text = item_data.get("description", "")
