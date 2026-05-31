extends Resource
class_name ItemData

@export var item_id: int = 0
@export var item_name: String = ""
@export var item_texture: Texture = null
@export var description: String = ""
@export var item_type: String = ""
#@export var flamable: bool = false
#@export var poisonous: bool = false
@export var quality: float = snapped(randf(), 0.01) #random number between 0-1 to nearest hundresth
