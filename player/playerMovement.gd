extends CharacterBody2D


@export var move_speed: float = 150
@onready var animatedSprite = $AnimatedSprite2D
@onready var notebook: Panel = $CanvasLayer/notebook
@onready var inventory: Panel = $CanvasLayer/inventory
@onready var notification_scene = preload("res://Menus/skill_notification.tscn")
@onready var foragingCount = $CanvasLayer/notebook/SkillsGrid/ForagingPanel/count
@onready var playerNameLabel = $CanvasLayer/notebook/player_name
@onready var craft_station_scene = preload("res://Menus/crafting_menu.tscn")
@onready var brewing_station_scene = preload("res://Menus/brewing_menu.tscn")
var craft_instance = null
var brew_instance = null

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
		print(data.quality)
		
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
		Globals.crafting_open = true 
	else:
		craft_instance.visible = !craft_instance.visible
		Globals.crafting_open = craft_instance.visible
		
	# close brewing station when crafting station opens
	if Globals.crafting_open and brew_instance:
		brew_instance.hide()
		Globals.brewing_open = false
						
func toggleBrewStation() -> void:
	if brew_instance == null:
		brew_instance = brewing_station_scene.instantiate()
		$CanvasLayer.add_child(brew_instance)
		Globals.brewing_open = true
	else:
		brew_instance.visible = !brew_instance.visible
		Globals.brewing_open = brew_instance.visible

	# close crafting station
	if Globals.brewing_open and craft_instance:
		craft_instance.hide()
		Globals.crafting_open = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("notebook"):
		openNotebook()
	elif Input.is_action_just_pressed("inventory"):
		openInventory()
	elif Input.is_action_just_pressed("interact") && Globals.can_craft:
		toggleCraftStation()
		print("toggle craft")
	elif Input.is_action_just_pressed("interact") && Globals.can_brew:
		toggleBrewStation()
		print("toggle brew")
		
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
	
