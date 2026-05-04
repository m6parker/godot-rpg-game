extends CharacterBody2D


@export var move_speed: float = 150
@onready var animatedSprite = $AnimatedSprite2D
@onready var notebook: Panel = $CanvasLayer/notebook
@onready var inventory: Panel = $CanvasLayer/inventory
@onready var notification_scene = preload("res://Menus/skill_notification.tscn")
@onready var foragingCount = $CanvasLayer/notebook/SkillsGrid/ForagingPanel/count
@onready var playerNameLabel = $CanvasLayer/notebook/player_name
@onready var craft_station_scene = preload("res://Menus/crafting_menu.tscn") 
var craft_instance = null

func _ready() -> void:
	$CollectionArea.area_entered.connect(_on_item_collected)
	playerNameLabel.text = Globals.player_name
	

func show_notification(text: String):
	var instance = notification_scene.instantiate()
	instance.get_node("Panel/description").text = text
	add_child(instance)
	
func updateSkillsNotebook():
	print(foragingCount.text)
	print(Globals.playerSkills["Foraging"])
	foragingCount.text = str(Globals.playerSkills["Foraging"])


func _on_item_collected(area: Area2D) -> void:
	# Check if the thing hit is actually an inventory item
	if area.has_method("get_item_data"):
		var data = area.get_item_data()
		
		# try to add to inventory
		var success = Globals.add_item(data)
		
		if success:
			area.collect()
			
		show_notification("+1 " + data.item_type)
		Globals.increase_skill(data.item_type)
		updateSkillsNotebook()

	
func openNotebook() -> void:
	if notebook.visible == false:
		notebook.visible = true
	else:
		notebook.visible = false
		
func openInventory() -> void:
	if inventory.visible == false:
		inventory.visible = true
	else:
		inventory.visible = false
				
func toggleCraftStation() -> void:
	if craft_instance == null:
		craft_instance = craft_station_scene.instantiate()
		$CanvasLayer.add_child(craft_instance)
	else:
		craft_instance.visible = !craft_instance.visible

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("notebook"):
		openNotebook()
	elif Input.is_action_just_pressed("inventory"):
		openInventory()
	elif Input.is_action_just_pressed("interact") && Globals.can_craft:
		toggleCraftStation()
		
	var inputDirection = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	velocity = inputDirection * move_speed

	if inputDirection.length() > 0:
		animatedSprite.play("run")
		#flip the walking animation if walking left
		animatedSprite.flip_h = inputDirection.x < 0
	else:
		animatedSprite.play("idle")

	move_and_slide()


func _on_quit_button_pressed() -> void:
	pass # Replace with function body.
	
