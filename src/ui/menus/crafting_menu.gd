extends Control


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


func check_recipe() -> ItemData:
	var names = []
	for item in Globals.crafting_slots: 
		if item != null:
			var item_name = item.item_name.to_lower().strip_edges()
			names.append(item_name)
	
	if names.size() < 2: return null 
	
	names.sort() 
	var recipe_key = ",".join(names) 

	#check if the recipe is real 
	if RecipeManager.item_recipes.has(recipe_key):
		var result_name = RecipeManager.item_recipes[recipe_key]
		
		#get the result of the recipe if its found
		if ItemDatabase.items.has(result_name):
			return ItemDatabase.items[result_name]
		else:
			print("recipe found, but result item '" + result_name + "' doesnt exist in ItemDatabase!")
	
	return null


# returns an ItemData object from the database
func _on_craft_button_pressed() -> void:
	var result = check_recipe()
	
	if result != null:
		Globals.crafting_result = result 
		
		# clear ingredients
		Globals.crafting_slots[0] = null 
		Globals.crafting_slots[1] = null 
		
		# update ui
		Globals.inventory_updated.emit() 
		Globals.crafting_updated.emit() 
	else:
		print("invalid ingredients!")
