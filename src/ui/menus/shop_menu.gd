extends CanvasLayer

const ITEM_UI_SCENE = preload("res://src/ui/shop_item.tscn")
@onready var list_container: VBoxContainer = $Panel/ScrollContainer/VBoxContainer

func _ready() -> void:
	load_shop_items()


func load_shop_items() -> void:
	if ITEM_UI_SCENE == null:
		push_error("item ui error")
		return

	for child in list_container.get_children():
		child.queue_free()
		
	# only put the foraging and brewing type items int the general shop
	var brewing_items: Dictionary = ItemDatabase.get_items_in_category("brewing")
	var forraging_items: Dictionary = ItemDatabase.get_items_in_category("foraging")
	for item_name in brewing_items:
		var item_data = ItemDatabase.items[item_name]
		create_item_element(item_data)
	for item_name in forraging_items:
		var item_data = ItemDatabase.items[item_name]
		create_item_element(item_data)
		

func create_item_element(item_data: ItemData) -> void:
	var item_element = ITEM_UI_SCENE.instantiate() 
	list_container.add_child(item_element)
	
	if item_element.has_method("setup"):
		item_element.setup(item_data)
