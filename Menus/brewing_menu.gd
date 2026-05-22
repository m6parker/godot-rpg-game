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

	if slot1: slot1.display_item(Globals.brewing_slots[0])
	if slot2: slot2.display_item(Globals.brewing_slots[1])
	if slot3: slot3.display_item(Globals.brewing_slots[2])
	
	if res_slot: res_slot.display_item(Globals.brewing_result)
	
	var can_brew = check_recipe() != null and Globals.brewing_result == null
	$Panel/brew_button.disabled = !can_brew  


func check_recipe() -> Resource:
	var names = []
	for item in Globals.brewing_slots:
		if item != null:
			var item_name = item.resource_path.get_file().get_basename().to_lower()
			names.append(item_name)
	
	# 3 required ingredients
	if names.size() < 3: return null
	
	names.sort()
	var recipe_key = ",".join(names) 

	if Recipes.potion_recipes.has(recipe_key):
		var result_name = Recipes.potion_recipes[recipe_key]
		var full_path = Recipes.get_recipe_path(result_name)
		return load(full_path)
	
	return null

# simple potion brewing 
#func _on_brew_button_pressed() -> void:
	#var result = check_recipe()
	##print("RESULT: ", result.quality)
	#
	#if result != null:
		#Globals.brewing_result = result
		#
		## clear ingredients
		#Globals.brewing_slots[0] = null
		#Globals.brewing_slots[1] = null
		#Globals.brewing_slots[2] = null
		#
		## update ui
		#Globals.inventory_updated.emit()
		#Globals.brewing_updated.emit()
	#else:
		#print("invalid ingredients!")
		
func _on_brew_button_pressed() -> void:
	var base_recipe = check_recipe()
	
	if base_recipe != null:
		# create a unique/independent duplicate of the base potion resource
		var finalized_potion = base_recipe.duplicate()
		
		# track total stats from the ingredients actually inside the slots
		var total_quality: float = 0.0
		#var total_potency: float = 0.0
		var ingredient_count: int = 0
		
		for item in Globals.brewing_slots:
			if item != null:
				# default to 1 if item missing attributes
				total_quality += item.get("quality") if "quality" in item else 1.0
				#total_potency += item.get("potency") if "potency" in item else 1.0
				ingredient_count += 1
		
		# calculate average
		if ingredient_count > 0:
			finalized_potion.quality = total_quality / ingredient_count
			#finalized_potion.potency = total_potency / ingredient_count
			
			# round values
			finalized_potion.quality = snapped(finalized_potion.quality, 0.01)
			#finalized_potion.potency = snapped(finalized_potion.potency, 0.01)
		
		# set global result to calculated potion
		Globals.brewing_result = finalized_potion
		print("finalized_potion: ", finalized_potion)
		print("potion quality: ", finalized_potion.quality)
		
		# clear ingredients
		Globals.brewing_slots[0] = null
		Globals.brewing_slots[1] = null
		Globals.brewing_slots[2] = null
		
		# update ui
		Globals.inventory_updated.emit()
		Globals.brewing_updated.emit()
	else:
		print("invalid ingredients!")
