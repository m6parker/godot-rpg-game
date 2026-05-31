extends Control

@onready var name_label: Label = $HBoxContainer/name_label
@onready var price_label: Label = $HBoxContainer/price_label
@onready var desc_label: Label = $HBoxContainer/desc_label

func setup(item_data: Dictionary) -> void:
	name_label.text = item_data.get("name", "error")
	price_label.text = str(item_data.get("price", 0)) + " gold"
	desc_label.text = item_data.get("description", "")
