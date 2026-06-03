#extends Resource
#class_name ItemData
#
#@export var item_id: int = 0
#@export var item_name: String = ""
#@export var item_texture: Texture = "res://assets/items/" + item_name + ".png"
#@export var description: String = ""
#@export var item_type: String = ""
##@export var flamable: bool = false
##@export var poisonous: bool = false
#@export var quality: float = snapped(randf(), 0.01) #random number between 0-1 to nearest hundresth
extends Resource
class_name ItemData

@export var item_id: int = 0
@export var item_name: String = "":
	set(value):
		item_name = value
		_auto_load_texture()

@export var item_texture: Texture2D
@export_multiline var description: String = ""
@export_enum("farming", "foraging", "brewing", "combat", "misc")
var item_type: String = "misc"
@export var quality: float = 0.0

func _init() -> void:
	# number between 0 and 1
	quality = snapped(randf(), 0.01) 

func _auto_load_texture() -> void:
	if item_name != "":
		var expected_path = "res://assets/items/" + item_name.to_lower() + ".png"
		if ResourceLoader.exists(expected_path):
			item_texture = load(expected_path)
		else:
			item_texture = load("res://assets/items/acorn.png")
