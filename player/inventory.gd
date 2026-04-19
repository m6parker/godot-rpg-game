extends HBoxContainer

@export var start_index: int = 0

func _ready() -> void:
	# Wait for Globals to initialize its array
	await get_tree().process_frame
	
	Globals.inventory_updated.connect(_on_inventory_refresh)
	
	var children = get_children()
	var slot_count = 0
	for child in children:
		if child.has_method("display_item"):
			child.slot_index = start_index + slot_count
			slot_count += 1
			
	_on_inventory_refresh()

func _on_inventory_refresh() -> void:
	var children = get_children()
	var slot_count = 0
	for child in children:
		if child.has_method("display_item"):
			var global_idx = start_index + slot_count
			
			# Safety check to prevent the "Index 8" crash
			if global_idx < Globals.player_inventory.size():
				child.display_item(Globals.player_inventory[global_idx])
			else:
				child.display_item(null)
				
			slot_count += 1
