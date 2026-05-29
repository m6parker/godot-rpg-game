extends CharacterBody2D

@export var movement_speed: float = 50.0
@export var wander_radius: float = 100.0

var starting_position: Vector2
var target_position: Vector2
var is_wandering: bool = false
var player_in_range: bool = false

@onready var interaction_area: Area2D = $interaction_zone

func _ready() -> void:
	starting_position = global_position
	target_position = global_position
	# connecting area2d signals to detect player
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	_update_behavior_loop()

func _physics_process(_delta: float) -> void:
	if is_wandering and global_position.distance_to(target_position) > 10:
		# move to random target position
		var direction = (target_position - global_position).normalized()
		velocity = direction * movement_speed
		move_and_slide()
	else:
		# stop if idle or at destination
		velocity = Vector2.ZERO
		is_wandering = false

func _unhandled_input(event: InputEvent) -> void:
	# player presses e
	if player_in_range and event.is_action_pressed("interact"):
		_interact()

func _update_behavior_loop() -> void:
	while true:
		var decide_to_wander = randf() > 0.5
		if decide_to_wander:
			_get_random_target()
			is_wandering = true
		else:
			is_wandering = false
			
		# wait for 2 to 5 seconds 
		await get_tree().create_timer(randf_range(2.0, 5.0)).timeout

func _get_random_target() -> void:
	# picking random point within wander radius of starting spot
	var random_offset = Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)
	target_position = starting_position + random_offset

func _interact() -> void:
	print("npc speaking")

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		print("can interact with npc")

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		print("Player left.")
