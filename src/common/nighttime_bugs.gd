extends TileMapLayer

@export var day_night_cycle: CanvasModulate 

func _process(_delta: float) -> void:
	if day_night_cycle:
		visible = Globals.is_night
