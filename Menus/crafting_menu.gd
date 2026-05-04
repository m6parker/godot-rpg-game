extends Control

const HONEY_MUSHROOM = preload("res://items/honey_mushroom.tres")

func _ready() -> void:
	Globals.crafting_updated.connect(_update_slots)
	$Panel/craft_button.pressed.connect(_on_craft_button_pressed)
	_update_slots()

func check_recipes() -> void:
	if Globals.crafting_result != null:
		return

	var ing1 = Globals.crafting_slots[0]
	var ing2 = Globals.crafting_slots[1]
	
	if ing1 and ing2:
		if (ing1.item_id == 1 and ing2.item_id == 0) or (ing1.item_id == 0 and ing2.item_id == 1):
			Globals.crafting_result = HONEY_MUSHROOM
			return
			
	Globals.crafting_result = null

func _update_slots() -> void:
	var slot1 = $Panel/ingredients_container/ingredient_slot
	var slot2 = $Panel/ingredients_container/ingredient_slot2
	var res_slot = $Panel/yeild_container/yield_slot

	if slot1: slot1.display_item(Globals.crafting_slots[0])
	if slot2: slot2.display_item(Globals.crafting_slots[1])
	
	if res_slot: res_slot.display_item(Globals.crafting_result)
	
	var can_craft = get_valid_recipe() != null and Globals.crafting_result == null
	$Panel/craft_button.disabled = !can_craft

func get_valid_recipe() -> Resource:
	var ing1 = Globals.crafting_slots[0]
	var ing2 = Globals.crafting_slots[1]
	
	if ing1 and ing2:
		if (ing1.item_id == 1 and ing2.item_id == 0) or (ing1.item_id == 0 and ing2.item_id == 1):
			return HONEY_MUSHROOM
	
	return null

func _on_craft_button_pressed() -> void:
	var result = get_valid_recipe()
	
	if result != null:
		Globals.crafting_result = result
		
		# clear ingredients
		Globals.crafting_slots[0] = null
		Globals.crafting_slots[1] = null
		
		# update UI
		Globals.inventory_updated.emit()
		Globals.crafting_updated.emit()
		print("Crafted successfully!")
	else:
		print("Invalid ingredients!")
