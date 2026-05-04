extends Control

const HONEY_MUSHROOM = preload("res://items/honey_mushroom.tres")

func _ready() -> void:
	Globals.crafting_updated.connect(_update_slots)
	$Panel/craft_button.pressed.connect(_on_craft_button_pressed)
	_update_slots()
	

func _update_slots() -> void:
	var slot1 = $Panel/ingredients_container/ingredient_slot
	var slot2 = $Panel/ingredients_container/ingredient_slot2
	var res_slot = $Panel/yeild_container/yield_slot

	if slot1: slot1.display_item(Globals.crafting_slots[0])
	if slot2: slot2.display_item(Globals.crafting_slots[1])
	
	if res_slot: res_slot.display_item(Globals.crafting_result)
	
	var can_craft = check_recipe() != null and Globals.crafting_result == null
	$Panel/craft_button.disabled = !can_craft  


func check_recipe() -> Resource:
	var names = []
	for item in Globals.crafting_slots:
		if item != null:
			var item_name = item.resource_path.get_file().get_basename().to_lower()
			names.append(item_name)
	
	if names.size() < 2: return null
	
	names.sort()
	var recipe_key = ",".join(names) 

	if Recipes.recipes.has(recipe_key):
		var result_name = Recipes.recipes[recipe_key]
		var full_path = Recipes.get_recipe_path(result_name)
		return load(full_path)
	
	return null


func _on_craft_button_pressed() -> void:
	var result = check_recipe()
	
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
