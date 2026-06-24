extends CharacterBody2D

@export var move_speed: float = 150.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ui: CanvasLayer = $CanvasLayer


func _ready() -> void:
	$CollectionArea.area_entered.connect(_on_item_collected)


func _physics_process(_delta: float) -> void:
	# ask ui manager is ui is blicking anything
	if ui.is_any_menu_open():
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		move_and_slide()
		return

	var input_direction := Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * move_speed

	if input_direction.length() > 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = input_direction.x < 0
	else:
		animated_sprite.play("idle")

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		ui.toggle_pause_menu()
	
	if event.is_action_pressed("notebook"):
		ui.toggle_notebook()
		
	if event.is_action_pressed("inventory"):
		ui.toggle_inventory()
		
	if event.is_action_pressed("skill_tree"):
		ui.toggle_skill_tree()
	
	if event.is_action_pressed("interact"):
		if Globals.can_craft:
			ui.toggle_craft_station()
		elif Globals.can_brew:
			ui.toggle_brew_station()


func _on_item_collected(area: Area2D) -> void:
	if not area.has_method("get_item_data"):
		return
		
	var data = area.get_item_data()
	var success = Globals.add_item(data)
	
	if success:
		print("picking up item!")
		area.collect()
		
		# tell ui manager to display the sill notification
		ui.show_notification("+1 " + data.item_type)
		Globals.increase_skill(data.item_type)
		#ui.update_skills_notebook()
