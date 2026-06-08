extends GridContainer

@export var container_type: String = "inventory"
@export var start_index: int = 0

func _ready() -> void:
	await get_tree().process_frame
	
	Globals.inventory_updated.connect(_on_inventory_refresh)
	
	var children = get_children()
	var slot_count = 0
	for child in children:
		if child.has_method("display_item"):
			child.container_type = container_type
			child.slot_index = start_index + slot_count
			slot_count += 1
			
	_on_inventory_refresh()


func _on_inventory_refresh() -> void:
	var children = get_children()
	var slot_count = 0
	
	var target_array: Array = Globals.player_inventory
	if container_type == "hotbar":
		target_array = Globals.hotbar_slots

	for child in children:
		if child.has_method("display_item"):
			var global_index = start_index + slot_count
			
			if global_index < target_array.size():
				child.display_item(target_array[global_index])
			else:
				child.display_item(null)
				
			slot_count += 1
