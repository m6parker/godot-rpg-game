extends GridContainer

var currently_equipped_index: int = -1

func _ready() -> void:
	await get_tree().process_frame
	Globals.inventory_updated.connect(_on_hotbar_refresh)
	
	var children = get_children()
	var slot_count = 0
	for child in children:
		if child.has_method("display_item"):
			child.container_type = "hotbar"
			child.slot_index = slot_count
			
			if child.has_method("set_equipped_visual"):
				child.set_equipped_visual(false)
				
			slot_count += 1
			
	_on_hotbar_refresh()

func _on_hotbar_refresh() -> void:
	var children = get_children()
	var slot_count = 0
	var target_array: Array = Globals.hotbar_slots

	for child in children:
		if child.has_method("display_item"):
			if slot_count < target_array.size():
				child.display_item(target_array[slot_count])
			else:
				child.display_item(null)
			slot_count += 1
			
	_update_equipped_highlights()

## Intercept keyboard inputs 1-4 (matching your 4 slots)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			var slot_pressed = event.keycode - KEY_1
			if slot_pressed < get_child_count():
				equip_slot(slot_pressed)

func equip_slot(index: int) -> void:
	if currently_equipped_index == index:
		currently_equipped_index = -1 # Unequip
	else:
		currently_equipped_index = index
		
	_update_equipped_highlights()
	
	# todo - change player animations
	var equipped_item = Globals.hotbar_slots[currently_equipped_index] if currently_equipped_index != -1 else null
	# Globals.change_held_item(equipped_item)
	#print("equipped: ", equipped_item.item_name)
	Globals.equip_item(equipped_item)

func _update_equipped_highlights() -> void:
	var children = get_children()
	for i in range(children.size()):
		var child = children[i]
		if child.has_method("set_equipped_visual"):
			child.set_equipped_visual(i == currently_equipped_index)
