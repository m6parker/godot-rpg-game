extends TileMapLayer

@export var day_night_cycle: CanvasModulate 

func _process(_delta: float) -> void:
	if day_night_cycle:
		visible = day_night_cycle.is_night
