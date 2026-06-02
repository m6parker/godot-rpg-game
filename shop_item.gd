extends Control

@onready var icon: TextureRect = $NinePatchRect/icon
@onready var name_label: Label = $NinePatchRect/name_label
@onready var price_label: Label = $NinePatchRect/price_label
@onready var desc_label: Label = $NinePatchRect/desc_label
@onready var buy_button: TextureButton = $NinePatchRect/buy_button

var item_data: Dictionary 

func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)

func setup(data: Dictionary) -> void:
	item_data = data
	
	# get info from json file
	var id = item_data.get("id", "error")
	var image_path = "res://assets/items/" + id + ".png"
	
	if ResourceLoader.exists(image_path):
		icon.texture = load(image_path)
		
	name_label.text = item_data.get("name", "error")
	price_label.text = str(item_data.get("price", 0)) + " gold"
	desc_label.text = item_data.get("description", "")

func _on_buy_button_pressed() -> void:
	var price = item_data.get("price", 0)
	var res_path = item_data.get("resource_path", "")
	
	if not Globals.can_afford(price):
		print("not enough gold!")
		return
		
	if not Globals.has_empty_inventory_slot():
		print("inventory is full!")
		return
		
	if ResourceLoader.exists(res_path):
		var item_resource = load(res_path) as ItemData
		
		if item_resource == null:
			push_error("error " + res_path)
			return
			
		Globals.deduct_gold(price)
		Globals.add_item(item_resource)
		
