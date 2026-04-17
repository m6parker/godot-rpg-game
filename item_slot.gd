#extends Panel
#
#@onready var icon: TextureRect = $icon if has_node("icon") else null
#var is_dragging := false
#var is_hovered_with_drag := false
#var hover_style: StyleBoxFlat
#@onready var hover_sprite: CanvasItem = $hover_sprite if has_node("hover_sprite") else null
#
#
#func _ready() -> void:
	#hover_style = StyleBoxFlat.new()
	#hover_style.draw_center = false
	#hover_style.border_width_left = 5
	#hover_style.border_width_top = 5
	#hover_style.border_width_right = 5
	#hover_style.border_width_bottom = 5
	#hover_style.set_border_color(Color.YELLOW)
	#
	#
#func _get_drag_data(_at_position: Vector2) -> Variant:
	#if icon == null or icon.texture == null:
		#return null
#
	#is_dragging = true
	#
	## show item being dragged by mouse
	#var preview = TextureRect.new()
	#preview.texture = icon.texture
	#preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	#preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	#preview.size = icon.size
	#
	## Center the preview under the mouse
	#var preview_container = Control.new()
	##preview_container.top_level = true
	#preview_container.z_index = 100 # Force it to the front
	#preview_container.z_as_relative = false # Make it absolute
	#preview_container.add_child(preview)
	#preview.position = -preview.size / 2
	##preview.position = Vector2(-40, -40)
	#set_drag_preview(preview_container)
#
	## Hide the original icon while dragging (better than setting to null immediately)
	#icon.modulate.a = 0.5 
	#
	#return {
		#"texture": icon.texture,
		#"source_node": self,
		#"item_id": 1
	#}
#
#func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	#var can_drop = data is Dictionary and data.has("texture")
	#if can_drop:
		#is_hovered_with_drag = true
		##queue_redraw() # Force the panel to draw the highlight
		#if hover_sprite:
			#hover_sprite.show() # Make the sprite visible
	#
	#return can_drop
	#
	#
#func _hide_hover_visuals() -> void:
	#is_hovered_with_drag = false
	#if hover_sprite:
		#hover_sprite.hide()
		#
#
#func _draw() -> void:
	## If we are currently being hovered over by a valid drag, draw the box
	#if is_hovered_with_drag:
		##draw_style_box(hover_style, Rect2(Vector2.ZERO, size))
		#var mouse_pos = get_local_mouse_position()
		#if not Rect2(Vector2.ZERO, size).has_point(mouse_pos):
			#_hide_hover_visuals()
#
#func _process(_delta: float) -> void:
	## Manually detect when the drag leaves this specific slot
	## because Godot doesn't have a 'drag_exited' notification for individual nodes
	#if is_hovered_with_drag:
		#var mouse_pos = get_local_mouse_position()
		#if not Rect2(Vector2.ZERO, size).has_point(mouse_pos):
			#is_hovered_with_drag = false
			#queue_redraw()
#
#
#func _drop_data(_at_position: Vector2, data: Variant) -> void:
	#_hide_hover_visuals()
	#var source_node = data["source_node"]
	#var incoming_texture = data["texture"]
	#
	## check if there's something int he slot youre dropping on
	#if icon.texture != null:
		##swap the items if the item is placed on a slot with an item inside it already
		#source_node.icon.texture = icon.texture
		#icon.texture = incoming_texture
	#else:
		## move the item into the new slot
		#icon.texture = incoming_texture
		#source_node.icon.texture = null
	#
	## Reset visual state of the source
	#source_node.icon.modulate.a = 1.0
	#source_node.is_dragging = false
#
#func _notification(what: int) -> void:
	## Safety check: if the drag ends anywhere, clear all highlights
	#if what == NOTIFICATION_DRAG_END:
		#is_hovered_with_drag = false
		#queue_redraw()
		#_hide_hover_visuals()
		#
		## (Rest of your existing DRAG_END logic)
		#if is_dragging:
			#if not get_viewport().gui_is_drag_successful():
				#icon.modulate.a = 1.0
			#is_dragging = false


extends Panel

@onready var icon: TextureRect = $icon if has_node("icon") else null
@onready var hover_sprite: CanvasItem = $hover_sprite if has_node("hover_sprite") else null

var is_dragging := false
var is_hovered_with_drag := false

func _get_drag_data(_at_position: Vector2) -> Variant:
	if icon == null or icon.texture == null:
		return null

	is_dragging = true
	
	# Create the visual preview
	var preview = TextureRect.new()
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = icon.size
	
	var preview_container = Control.new()
	# Set top_level to true so it ignores parent Z-index/Clip Children issues
	preview_container.z_index = 100 # Force it to the front
	preview_container.z_as_relative = false # Make it absolute
	preview_container.add_child(preview)
	preview.position = -preview.size / 2
	
	set_drag_preview(preview_container)

	# Ghost the original item
	icon.modulate.a = 0.5 
	
	return {
		"texture": icon.texture,
		"source_node": self,
		"item_id": 1
	}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var can_drop = data is Dictionary and data.has("texture")
	
	if can_drop:
		if not is_hovered_with_drag:
			is_hovered_with_drag = true
			if hover_sprite:
				hover_sprite.show()
	
	return can_drop

func _process(_delta: float) -> void:
	# This handles the "Drag Exited" logic which Godot doesn't provide a signal for
	if is_hovered_with_drag:
		var mouse_pos = get_local_mouse_position()
		# If the mouse is no longer inside the Panel's bounds
		if not Rect2(Vector2.ZERO, size).has_point(mouse_pos):
			_hide_hover_visuals()

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_hide_hover_visuals()
	
	var source_node = data["source_node"]
	var incoming_texture = data["texture"]
	
	if icon.texture != null:
		# Swapping textures
		var temp_texture = icon.texture
		icon.texture = incoming_texture
		source_node.icon.texture = temp_texture
	else:
		# Placing into empty slot
		icon.texture = incoming_texture
		source_node.icon.texture = null
	
	# Reset source visuals
	source_node.icon.modulate.a = 1.0
	source_node.is_dragging = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_hide_hover_visuals()
		
		if is_dragging:
			# If the drag failed (dropped in void), restore the icon alpha
			if not get_viewport().gui_is_drag_successful():
				icon.modulate.a = 1.0
			is_dragging = false

func _hide_hover_visuals() -> void:
	is_hovered_with_drag = false
	if hover_sprite:
		hover_sprite.hide()
