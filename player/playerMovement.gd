extends CharacterBody2D


@export var move_speed: float = 150

@onready var animatedSprite = $AnimatedSprite2D
@onready var notebook: Panel = $CanvasLayer/notebook
@onready var inventory: Panel = $CanvasLayer/inventory
@onready var foragingCount = $CanvasLayer/notebook/SkillsGrid/ForagingPanel/count
@onready var playerNameLabel = $CanvasLayer/notebook/player_name

@onready var notification_scene = preload("res://Menus/skill_notification.tscn")
@onready var craft_station_scene = preload("res://Menus/crafting_menu.tscn")
@onready var brewing_station_scene = preload("res://Menus/brewing_menu.tscn")

var craft_instance = null
var brew_instance = null


func _ready() -> void:
	$CollectionArea.area_entered.connect(_on_item_collected)
	playerNameLabel.text = Globals.player_name
	

# prevents menus from going out of sync
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("notebook"):
		openNotebook()
	if event.is_action_pressed("inventory"):
		toggleInventory()
	
	if event.is_action_pressed("interact"):
		if Globals.can_craft:
			toggleCraftStation()
			print("toggle craft")
		elif Globals.can_brew:
			toggleBrewStation()
			print("toggle brew")
			

func _physics_process(_delta: float) -> void:
	# prevent movement
	if notebook.visible or (craft_instance and craft_instance.visible) or (brew_instance and brew_instance.visible):
		velocity = Vector2.ZERO
		animatedSprite.play("idle")
		move_and_slide()
		return

	var inputDirection = Input.get_vector("left", "right", "up", "down")
	velocity = inputDirection * move_speed

	if inputDirection.length() > 0:
		animatedSprite.play("run")
		animatedSprite.flip_h = inputDirection.x < 0
	else:
		animatedSprite.play("idle")

	move_and_slide()
			
func show_notification(text: String):
	var instance = notification_scene.instantiate()
	instance.get_node("Panel/description").text = text
	add_child(instance)
	
func updateSkillsNotebook():
	print(foragingCount.text)
	print(Globals.playerSkills["Foraging"])
	foragingCount.text = str(Globals.playerSkills["Foraging"])


func _on_item_collected(area: Area2D) -> void:
	# check if the thing hit is actually an inventory item
	if area.has_method("get_item_data"):
		
		# try to add to inventory
		var data = area.get_item_data()
		var success = Globals.add_item(data)
		
		if success:
			area.collect()
			
		show_notification("+1 " + data.item_type)
		Globals.increase_skill(data.item_type)
		updateSkillsNotebook()
	
	
func openNotebook() -> void:
	notebook.visible = !notebook.visible
		

func toggleInventory() -> void:
	inventory.visible = !inventory.visible
				
		
func toggleCraftStation() -> void:
	# first time creation
	if craft_instance == null:
		craft_instance = craft_station_scene.instantiate()
		$CanvasLayer.add_child(craft_instance)
		craft_instance.visible = true
	else:
		craft_instance.visible = !craft_instance.visible

	Globals.crafting_open = craft_instance.visible
	
	inventory.visible = craft_instance.visible
		
	# close brewing if crafting opens
	if Globals.crafting_open and brew_instance:
		brew_instance.hide()
		Globals.brewing_open = false
		
		
func toggleBrewStation() -> void:
	# first time creation
	if brew_instance == null:
		brew_instance = brewing_station_scene.instantiate()
		$CanvasLayer.add_child(brew_instance)
		brew_instance.visible = true
	else:
		brew_instance.visible = !brew_instance.visible

	Globals.brewing_open = brew_instance.visible
	inventory.visible = brew_instance.visible

	# close crafting if brewing opens
	if Globals.brewing_open and craft_instance:
		craft_instance.hide()
		Globals.crafting_open = false


func _on_quit_button_pressed() -> void:
	pass # Replace with function body.
	
