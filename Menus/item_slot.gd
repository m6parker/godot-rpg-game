extends Panel
#
@onready var icon: TextureRect = $icon if has_node("icon") else null
@onready var hover_sprite: CanvasItem = $hover_sprite if has_node("hover_sprite") else null
# options: inventory, crafting, brewing, result, brewing_result
@export var container_type: String = "inventory" 
@export var slot_index: int = -1

var is_dragging := false
var is_hovered_with_drag := false


func _ready() -> void:
	if icon:
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Helper to get the correct data source
func get_target_array() -> Array:
	if container_type == "inventory":
		return Globals.player_inventory
	elif container_type == "crafting":
		return Globals.crafting_slots
	elif container_type == "brewing":
		return Globals.brewing_slots
	elif container_type == "brewing_result":
		return [Globals.brewing_result]
	else: # "result"
		return [Globals.crafting_result]


func _get_drag_data(_at_position: Vector2) -> Variant:
	var current_array = get_target_array()
	var item_resource = null
	
	if container_type == "result":
		item_resource = Globals.crafting_result
	elif container_type == "brewing_result":
		item_resource = Globals.brewing_result
	else:
		item_resource = current_array[slot_index]

	if item_resource == null: return null

	is_dragging = true
	
	# show item being dragged 
	var preview = TextureRect.new()
	preview.texture = item_resource.item_texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = icon.size
	var preview_container = Control.new()
	preview_container.add_child(preview)
	preview.position = -preview.size / 2
	set_drag_preview(preview_container)
	icon.modulate.a = 0.2
	
	return { 
		"origin_node": self, 
		"item_data": item_resource,
		"origin_slot_index": slot_index 
	}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# cannot place items in yield slots
	if container_type == "result" or container_type == "brewing_result":
		return false
		
	var valid_data = data is Dictionary and data.has("origin_node") and data.has("item_data")
	if not valid_data:
		return false
		
	if container_type == "brewing" and slot_index == 2:
		var dragging_item = data["item_data"]
		if not is_item_a_bottle(dragging_item):
			return false
			
	# hover effect over valid slots
	if not is_hovered_with_drag:
		_show_hover_visuals()
	
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var origin_node = data["origin_node"]
	var item_to_move = data["item_data"]
	
	var target_array = get_target_array()
	var origin_array = origin_node.get_target_array()
	
	if container_type == "result" || container_type == "brewing_result":
		return

	var item_already_here = target_array[slot_index]
	
	target_array[slot_index] = item_to_move
	
	if origin_node.container_type == "result":
		Globals.crafting_result = null
	elif origin_node.container_type == "brewing_result":
		Globals.brewing_result = null
	else:
		origin_array[origin_node.slot_index] = item_already_here
	
	_hide_hover_visuals()
	Globals.inventory_updated.emit()
	if Globals.has_signal("crafting_updated"):
		Globals.crafting_updated.emit()
	if Globals.has_signal("brewing_updated"):
		Globals.brewing_updated.emit()
	

func _process(_delta: float) -> void:
	if is_hovered_with_drag:
		var mouse_pos = get_local_mouse_position()
		if not Rect2(Vector2.ZERO, size).has_point(mouse_pos):
			_hide_hover_visuals()

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_hide_hover_visuals()
		if is_dragging:
			is_dragging = false
			if not get_viewport().gui_is_drag_successful():
				if icon: icon.modulate.a = 1.0

func _show_hover_visuals() -> void:
	is_hovered_with_drag = true
	if hover_sprite: hover_sprite.show()

func _hide_hover_visuals() -> void:
	is_hovered_with_drag = false
	if hover_sprite: hover_sprite.hide()

func display_item(data: Variant) -> void:
	if icon == null: return
	if data is ItemData:
		icon.texture = data.item_texture
		icon.modulate.a = 1.0 
		icon.show()
	else:
		icon.texture = null
		icon.hide()
		
		
# -------- shift clicking ---------

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SHIFT):
			handle_shift_click()


#func handle_shift_click() -> void:
	#var item = get_item_in_this_slot()
	#if item == null: return
#
	#match container_type:
		#"inventory":
			## sorting from inventory depending which ui is open
			#if Globals.get(&"brewing_open") and Globals.move_to_brewing(item, slot_index):
				#print("moved to brewing station")
			#elif Globals.get(&"crafting_open") and Globals.move_to_crafting(item, slot_index):
				#print("moved to crafting station")
			#else:
				## other inventory
				#pass
		#"crafting", "brewing", "result", "brewing_result":
			## back to inventory from result slot
			#if Globals.move_to_inventory(item, container_type, slot_index):
				#print("moved to inventory")
				
func handle_shift_click() -> void:
	var item = get_item_in_this_slot()
	if item == null: return

	match container_type:
		"inventory":
			if Globals.get(&"brewing_open"):
				# if the brewing stand if full, and its not a bottle, leave it
				if not is_item_a_bottle(item):
					var slot1 = Globals.brewing_slots[0]
					var slot2 = Globals.brewing_slots[1]
					if slot1 != null and slot2 != null:
						return 
				
				if Globals.move_to_brewing(item, slot_index):
					print("moved to brewing station")
					
			elif Globals.get(&"crafting_open") and Globals.move_to_crafting(item, slot_index):
				print("moved to crafting station")
				
		"crafting", "brewing", "result", "brewing_result":
			if Globals.move_to_inventory(item, container_type, slot_index):
				print("moved to inventory")
				
	_update_all_systems()


func _update_all_systems() -> void:
	Globals.inventory_updated.emit()
	if Globals.has_signal("crafting_updated"):
		Globals.crafting_updated.emit()
	if Globals.has_signal("brewing_updated"):
		Globals.brewing_updated.emit()
		

func get_item_in_this_slot() -> Resource:
	#if container_type == "result":
		#return Globals.crafting_result
	#elif container_type == "crafting":
		#return Globals.crafting_slots[slot_index]
	#else:
		#return Globals.player_inventory[slot_index]
	match container_type:
		"result":
			return Globals.crafting_result
		"brewing_result":
			return Globals.brewing_result
		"crafting":
			return Globals.crafting_slots[slot_index]
		"brewing":
			return Globals.brewing_slots[slot_index]
		_:
			return Globals.player_inventory[slot_index]


func is_item_a_bottle(item: Resource) -> bool:
	if item == null: 
		return false
	var filename = item.resource_path.get_file().get_basename().to_lower()
	return "bottle" in filename
