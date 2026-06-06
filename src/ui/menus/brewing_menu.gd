extends Control

func _ready() -> void:
	Globals.brewing_updated.connect(_update_slots)
	$Panel/brew_button.pressed.connect(_on_brew_button_pressed)
	_update_slots()


func validate_slot_drop(type: String, index: int, item_data: Resource) -> bool:
	if type == "brewing" and index == 2:
		return is_item_a_bottle(item_data)
	return true


func _update_slots() -> void:
	var slot1 = $Panel/ingredients_container/ingredient_slot
	var slot2 = $Panel/ingredients_container/ingredient_slot2
	var slot3 = $Panel/ingredients_container/ingredient_slot3
	var res_slot = $Panel/yeild_container/yield_slot
	
	if slot1: slot1.display_item(Globals.brewing_slots[0])
	if slot2: slot2.display_item(Globals.brewing_slots[1])
	if slot3: slot3.display_item(Globals.brewing_slots[2])
	
	if res_slot: res_slot.display_item(Globals.brewing_result)
	
	#enable the brew button when a valid recipe is given
	var can_brew = check_recipe() != null and Globals.brewing_result == null
	$Panel/brew_button.disabled = !can_brew


# checking if item is a bottle or vessel or whatever
func is_item_a_bottle(item: Resource) -> bool:
	if item == null:
		return false
	
	var lower_name = ""
	if "item_name" in item:
		lower_name = item.item_name.to_lower()
	elif item.resource_path != "":
		lower_name = item.resource_path.get_file().get_basename().to_lower()
		
	return "bottle" in lower_name or "vial" in lower_name or "flask" in lower_name


func check_recipe() -> ItemData:
	# make sure the last slot only has bottle items
	var slot3_item = Globals.brewing_slots[2]
	if slot3_item == null or not is_item_a_bottle(slot3_item):
		return null

	var current_ingredients: Array[String] = []
	#check if the slots are filled up and add it to the list of ingredients
	if Globals.brewing_slots[0] != null:
		current_ingredients.append(Globals.brewing_slots[0].item_name.to_lower().strip_edges())
	if Globals.brewing_slots[1] != null:
		current_ingredients.append(Globals.brewing_slots[1].item_name.to_lower().strip_edges())
	current_ingredients.sort()

	#loop thru the possible potion recipes and see if the ingredients match to anything
	for recipe in RecipeManager.potion_recipes:
		if current_ingredients == recipe.ingredients:
			# get the result of the ingredients from the recipes database
			# find the item using the result
			var result_name = recipe.result_item_name.to_lower().strip_edges()
			for key in ItemDatabase.items.keys():
				var clean_key = key.to_lower().strip_edges()
				var underscore_key = clean_key.replace(" ", "_")
				
				if clean_key == result_name or underscore_key == result_name:
					var found_item = ItemDatabase.items.get(key)
					print("match found: ", key, " ~ texture: ", found_item.item_texture.resource_path if found_item.item_texture else "no png image!")
					return found_item
			
			print("recipe matched but '", result_name, "' does not exist in item json probably!")
			
	return null

# after the recipe if confirmed
func _on_brew_button_pressed() -> void:
	var base_recipe = check_recipe()
	
	if base_recipe != null:
		var finalized_potion = base_recipe.duplicate()
		var total_quality: float = 0.0
		var ingredient_count: int = 0
		
		# checkthe quality attribute of each ingredient item
		for item in Globals.brewing_slots:
			if item != null:
				if "quality" in item and item.quality > 0:
					total_quality += item.quality
					ingredient_count += 1
		#calculate the average quality between the ingredients
		if ingredient_count > 0:
			var avg_quality = total_quality / ingredient_count
			finalized_potion.quality = snapped(avg_quality, 0.01)
		else:
			finalized_potion.quality = 0.0
		
		Globals.brewing_result = finalized_potion
		print("new potion: ", finalized_potion.item_name, " (quality: ", finalized_potion.quality, ")")
		
		Globals.brewing_slots[0] = null
		Globals.brewing_slots[1] = null
		Globals.brewing_slots[2] = null
		
		Globals.inventory_updated.emit()
		Globals.brewing_updated.emit()
	else:
		print("error someting went wrong!")
