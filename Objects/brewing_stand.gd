extends Node2D

@onready var trigger_area = $Area2D

func _ready() -> void:
	if trigger_area:
		trigger_area.area_entered.connect(_on_enter_brewing_station)
		trigger_area.area_exited.connect(_on_leave_brewing_station)

func _on_enter_brewing_station(area: Area2D) -> void:
	if area != null:
		Globals.can_brew = true
		print('can brew (highlight brew table)')

func _on_leave_brewing_station(area: Area2D) -> void:
	Globals.can_brew = false
	print('cannot brew, brewing stand too far')
