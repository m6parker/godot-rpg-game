extends Control

@onready var icon: TextureRect = $TextureRect/icon_background/icon
@onready var name_label: Label = $TextureRect/name_label
@onready var price_label: Label = $TextureRect/price_label
@onready var desc_label: Label = $TextureRect/desc_label
@onready var buy_button: TextureButton = $TextureRect/buy_button

var current_item: ItemData 

func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)

func setup(item: ItemData) -> void:
	current_item = item 
	
	name_label.text = item.item_name
	desc_label.text = item.description
	icon.texture = item.item_texture
	
	if "price" in item:
		price_label.text = str(item.price) + " Gold"


func _on_buy_button_pressed() -> void:
	if current_item == null: 
		return
		
	var price = 0
	if "price" in current_item:
		price = current_item.price
	
	if not Globals.can_afford(price):
		print("not enough gold!")
		return
		
	if not Globals.has_empty_inventory_slot():
		print("inventory is full!")
		return
		
	Globals.deduct_gold(price)
	Globals.add_item(current_item)
	print("Successfully bought: ", current_item.item_name)
