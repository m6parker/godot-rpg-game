extends Panel

@onready var icon: TextureRect = $icon if has_node("icon") else null
@onready var hover_sprite: CanvasItem = $hover_sprite if has_node("hover_sprite") else null

var is_dragging := false
var is_hovered_with_drag := false
var slot_index: int = -1 

func _ready() -> void:
	if icon:
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _get_drag_data(_at_position: Vector2) -> Variant:
	# safety
	if slot_index == -1 or slot_index >= Globals.player_inventory.size():
		return null
	if Globals.player_inventory[slot_index] == null:
		return null

	is_dragging = true
	
	# show the item being dragged under the cursor
	var preview = TextureRect.new()
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = icon.size
	
	var preview_container = Control.new()
	preview_container.top_level = true
	preview_container.add_child(preview)
	preview.position = -preview.size / 2
	set_drag_preview(preview_container)

	# item temporarily lifted appearance
	icon.modulate.a = 0.2
	
	return { "origin_slot_index": slot_index }

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var can_drop = data is Dictionary and data.has("origin_slot_index")
	
	# hover effect over slots
	if can_drop:
		if not is_hovered_with_drag:
			_show_hover_visuals()
	
	return can_drop

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var origin_idx = data["origin_slot_index"]
	var target_idx = slot_index
	
	# safety
	var inv_size = Globals.player_inventory.size()
	if origin_idx >= inv_size or target_idx >= inv_size:
		_hide_hover_visuals()
		return

	if origin_idx == target_idx:
		_hide_hover_visuals()
		return

	# swap slots data
	var temp = Globals.player_inventory[target_idx]
	Globals.player_inventory[target_idx] = Globals.player_inventory[origin_idx]
	Globals.player_inventory[origin_idx] = temp
	
	_hide_hover_visuals()
	Globals.inventory_updated.emit()

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
			
			# check if drag landed in valid slot
			if not get_viewport().gui_is_drag_successful():
				# send item back on fail
				if icon:
					icon.modulate.a = 1.0
			else:
				# success
				pass


func _show_hover_visuals() -> void:
	is_hovered_with_drag = true
	if hover_sprite:
		hover_sprite.show()

func _hide_hover_visuals() -> void:
	is_hovered_with_drag = false
	if hover_sprite:
		hover_sprite.hide()

func display_item(data: Variant) -> void:
	if icon == null: return
	
	if data != null and data is Dictionary and data.has("texture"):
		icon.texture = data["texture"]
		icon.modulate.a = 1.0
		icon.show()
	else:
		icon.texture = null
		icon.hide()
