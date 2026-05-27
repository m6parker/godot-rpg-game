extends Node2D

#@onready var icon:TextureRect = $TextureRect
@onready var interact_bubble = preload("res://Menus/interact_bubble.tscn")

func _ready() -> void:
	$Area2D.area_entered.connect(_on_enter_craft_station)
	$Area2D.area_exited.connect(_on_leave_craft_station)

func _on_enter_craft_station(area: Area2D) -> void:
	Globals.can_craft = true
	print('can craft (highlight crratting table)')

func _on_leave_craft_station(area: Area2D) -> void:
	Globals.can_craft = false
	print('cannot craft, crafting table too far')
