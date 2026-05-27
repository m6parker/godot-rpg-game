extends Node2D

@onready var trigger_area = $Area2D
@onready var interact_bubble_scene = preload("res://Menus/interact_bubble.tscn")

var active_bubble: Control = null
var current_player: Node2D = null

@export var bubble_offset_y: float = -30.0 #height above player

func _ready() -> void:
	if trigger_area:
		trigger_area.area_entered.connect(_on_enter_brewing_station)
		trigger_area.area_exited.connect(_on_leave_brewing_station)

func _process(_delta: float) -> void:
	# track player
	if active_bubble and current_player:
		# target position
		var target_pos = current_player.global_position + Vector2(0, bubble_offset_y)
		
		target_pos.x -= active_bubble.size.x / 2.0
		target_pos.y -= active_bubble.size.y / 3.0
		
		active_bubble.global_position = target_pos

func _on_enter_brewing_station(area: Area2D) -> void:
	if area.is_in_group("player") or area.name == "CollectionArea": 
		Globals.can_brew = true
		current_player = area.get_parent() as Node2D
		show_interact_bubble(true)

func _on_leave_brewing_station(area: Area2D) -> void:
	if area.is_in_group("player") or area.name == "CollectionArea":
		Globals.can_brew = false
		current_player = null
		show_interact_bubble(false)

func show_interact_bubble(show: bool):
	if show:
		if active_bubble == null:
			var bubble_instance = interact_bubble_scene.instantiate()
			if bubble_instance == null:
				return
				
			active_bubble = bubble_instance
			if active_bubble is Control:
				active_bubble.top_level = true
			
			if "z_index" in active_bubble:
				active_bubble.z_index = 10
			
			add_child(active_bubble)
	else:
		if active_bubble != null:
			active_bubble.queue_free()
			active_bubble = null
