extends GridContainer


func _ready() -> void:
	Globals.inventory_updated.connect(_on_inventory_refresh)
	var children = get_children()
	var slot_count = 0
	for child in children:
		if child.has_method("display_item"):
			child.container_type = "inventory"
			child.slot_index = slot_count
			slot_count += 1
			
	_on_inventory_refresh.call_deferred()

func _on_inventory_refresh() -> void:
	if not is_inside_tree():
		return
		
	var children = get_children()
	var slot_count = 0
	var target_array: Array = Globals.player_inventory

	for child in children:
		if child.has_method("display_item"):
			if slot_count < target_array.size():
				child.display_item(target_array[slot_count])
			else:
				child.display_item(null)
			slot_count += 1
