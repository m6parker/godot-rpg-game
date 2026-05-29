extends Area2D
class_name InteractableComponent

# when the player interacts
signal player_entered(player: Node2D)
signal player_exited

@onready var interact_bubble_scene = preload("res://Menus/interact_bubble.tscn")

var active_bubble: Control = null
var current_player: Node2D = null

@export var bubble_offset_y: float = -30.0
@export var bubble_width_offset: float = 5.0
@export var bubble_scale: Vector2 = Vector2(0.7, 0.7)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(_delta: float) -> void:
	if active_bubble and current_player:
		# track player
		var target_pos = current_player.global_position + Vector2(bubble_width_offset, bubble_offset_y)
		
		# center bubble
		target_pos.x -= active_bubble.size.x / 2.0
		target_pos.y -= active_bubble.size.y / 3.0
		
		active_bubble.global_position = target_pos

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") or area.name == "CollectionArea": 
		current_player = area.get_parent() as Node2D
		_show_interact_bubble(true)
		player_entered.emit(current_player)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("player") or area.name == "CollectionArea":
		_show_interact_bubble(false)
		current_player = null
		player_exited.emit()

func _show_interact_bubble(show: bool) -> void:
	if show:
		if active_bubble == null:
			var bubble_instance = interact_bubble_scene.instantiate()
			if bubble_instance == null: return
				
			active_bubble = bubble_instance as Control
			if active_bubble:
				active_bubble.top_level = true
				active_bubble.z_index = 999
				active_bubble.scale = bubble_scale
				active_bubble.z_index = 10
				print("bubble showing")
			
			add_child(active_bubble)
	else:
		if active_bubble != null:
			active_bubble.queue_free()
			active_bubble = null

# remove bubble when done
func _exit_tree() -> void:
	if active_bubble != null:
		active_bubble.queue_free()
