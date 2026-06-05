extends Control

func _ready() -> void:
	Globals.brewing_updated.connect(_update_slots)
	$Panel/brew_button.pressed.connect(_on_brew_button_pressed)
	_update_slots()

func _update_slots() -> void:
	var slot1 = $Panel/ingredients_container/ingredient_slot
	var slot2 = $Panel/ingredients_container/ingredient_slot2
	var slot3 = $Panel/ingredients_container/ingredient_slot3
	var res_slot = $Panel/yeild_container/yield_slot
	
	var item3 = Globals.brewing_slots[2]
	if item3 and not is_item_a_bottle(item3):
		print("non vessel in third slot!")
		Globals.brewing_slots[2] = null
		Globals.inventory_updated.emit()

	if slot1: slot1.display_item(Globals.brewing_slots[0])
	if slot2: slot2.display_item(Globals.brewing_slots[1])
	if slot3: slot3.display_item(Globals.brewing_slots[2])
	
	if res_slot: res_slot.display_item(Globals.brewing_result)
	
	var can_brew = check_recipe() != null and Globals.brewing_result == null
	$Panel/brew_button.disabled = !can_brew  

func check_recipe() -> ItemData:
	var slot3_item = Globals.brewing_slots[2]
	if slot3_item == null or not is_item_a_bottle(slot3_item):
		return null

	var current_ingredients: Array[String] = []
	print("checking recipe")
	
	if Globals.brewing_slots[0] != null:
		current_ingredients.append(Globals.brewing_slots[0].item_name.to_lower().strip_edges())
	if Globals.brewing_slots[1] != null:
		current_ingredients.append(Globals.brewing_slots[1].item_name.to_lower().strip_edges())
		
	current_ingredients.sort()
	print("current ingredients: ", current_ingredients)

	for recipe in RecipeManager.potion_recipes:
		print("recipe: ", recipe.ingredients)
		if current_ingredients == recipe.ingredients:
			var result_name = recipe.result_item_name
			print("result name: ", result_name)
			
			var exact_db_key = result_name
			for key in ItemDatabase.items.keys():
				if key.to_lower() == result_name:
					exact_db_key = key
					break
			
			print("ItemDatabase.items.get(exact_db_key): ", ItemDatabase.items.get(exact_db_key))
			return ItemDatabase.items.get(exact_db_key)
			
	return null

func is_item_a_bottle(item: ItemData) -> bool:
	if item == null: 
		return false
	return "bottle" in item.item_name.to_lower()

func _on_brew_button_pressed() -> void:
	var base_recipe = check_recipe()
	
	if base_recipe != null:
		var finalized_potion = base_recipe.duplicate()
		
		var total_quality: float = 0.0
		var ingredient_count: int = 0
		
		for item in Globals.brewing_slots:
			if item != null:
				if "quality" in item and item.quality > 0:
					total_quality += item.quality
					ingredient_count += 1
		
		if ingredient_count > 0:
			var avg_quality = total_quality / ingredient_count
			finalized_potion.quality = snapped(avg_quality, 0.01)
		else:
			finalized_potion.quality = 0.0
		
		Globals.brewing_result = finalized_potion
		print("Brewed potion: ", finalized_potion.item_name, " with Quality: ", finalized_potion.quality)
		
		Globals.brewing_slots[0] = null
		Globals.brewing_slots[1] = null
		Globals.brewing_slots[2] = null
		Globals.inventory_updated.emit()
		Globals.brewing_updated.emit()
	else:
		print("invalid ingredients!")
