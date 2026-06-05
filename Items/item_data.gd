extends Resource
class_name ItemData

@export var item_id: int = 0
@export var item_name: String = ""
@export var item_texture: Texture2D
@export_multiline var description: String = ""
@export_enum("farming", "foraging", "brewing", "combat", "misc") var item_type: String = "misc"
@export var quality: float = 0.0
@export var price: int = 0

func _init() -> void:
	quality = snapped(randf(), 0.01)
