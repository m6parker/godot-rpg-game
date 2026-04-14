
#func _drop_data(_at_position: Vector2, data: Variant) -> void:
##	swaps the icons between the current slot and the dragged item
	#var tempItem = icon.texture
	#icon.texture = data.texture
	#data.texture = tempItem

extends Panel

@onready var icon: TextureRect = $icon if has_node("icon") else null


func _get_drag_data(_at_position: Vector2) -> Variant:
	# check slot  for item
	if icon == null or icon.texture == null:
		return

	#show the item moving
	var preview = duplicate()
	var c = Control.new()
	c.add_child(preview)
	preview.position -= Vector2(25, 25)
	preview.self_modulate = Color.TRANSPARENT

	set_drag_preview(c)
	return icon
	#return {"texture": icon.texture}
	#return {"texture": icon.texture, "item_id": 111}

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	# drop if the slot is empty
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data == null: #or not data.has("texture"):
		return
#
	##if this slot is empty, create an icon node dynamically
	if icon == null:
		icon = TextureRect.new()
		add_child(icon)
		icon.name = "icon"

	## swap textures of items if dropping on another item
	var tempItem = icon.texture
	icon.texture = data.texture
	#icon.texture = data["texture"]
	data.texture = tempItem
