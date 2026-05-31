#extends Control
#
#@onready var icon: TextureRect = $HBoxContainer/icon
#@onready var name_label: Label = $HBoxContainer/name_label
#@onready var price_label: Label = $HBoxContainer/price_label
#@onready var desc_label: Label = $HBoxContainer/desc_label
#
#func setup(item_data: Dictionary) -> void:
	#var id = item_data.get("id", "error")
	#var image_path = "res://assets/items/" + id + ".png"
	#
	#if ResourceLoader.exists(image_path):
		#icon.texture = load(image_path)
	#else:
		#push_warning("error " + image_path)
		## icon.texture = load("res://assets/items/default.png")
	#
	#name_label.text = item_data.get("name", "error")
	#price_label.text = str(item_data.get("price", 0)) + " gold"
	#desc_label.text = item_data.get("description", "")


extends Control

@onready var icon: TextureRect = $HBoxContainer/icon
@onready var name_label: Label = $HBoxContainer/name_label
@onready var price_label: Label = $HBoxContainer/price_label
@onready var desc_label: Label = $HBoxContainer/desc_label
@onready var buy_button: Button = $HBoxContainer/buy_button

# This will hold the specific item's dictionary data passed from the JSON
var item_data: Dictionary 

func _ready() -> void:
	# Connect the button's pressed signal via code
	buy_button.pressed.connect(_on_buy_button_pressed)

func setup(data: Dictionary) -> void:
	item_data = data
	
	# Set your visual elements
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
	
	# 1. Check if the player has enough gold
	if not Globals.can_afford(price):
		print("Not enough gold!")
		# Optional: Play a "no cash" sound effect or flash the text red
		return
		
	# 2. Check if the player has inventory space
	if not Globals.has_empty_inventory_slot():
		print("Inventory is full!")
		return
		
	# 3. Load the Resource file specified in your JSON
	if ResourceLoader.exists(res_path):
		# Use 'as ItemData' to match your inventory's type checking requirements
		var item_resource = load(res_path) as ItemData
		
		if item_resource == null:
			push_error("Resource found, but it is not of class type 'ItemData': " + res_path)
			return
			
		Globals.deduct_gold(price)
		Globals.add_item(item_resource)
		print("Successfully purchased: ", item_data.get("name"))
