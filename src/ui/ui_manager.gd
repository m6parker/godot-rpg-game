extends CanvasLayer

@onready var notebook: Panel = $notebook/skills_page
@onready var inventory: Panel = $notebook/inventory_page
@onready var skill_tree: Control = $skill_tree
@onready var foraging_count: Label = $notebook/skills_page/SkillsGrid/ForagingPanel/count
@onready var brewing_count: Label = $notebook/skills_page/SkillsGrid/BrewingPanel/count
@onready var farming_count: Label = $notebook/skills_page/SkillsGrid/FarmingPanel/count
@onready var player_name_label: Label = $notebook/inventory_page/player_name
@onready var gold_count_label: Label = $notebook/inventory_page/gold/gold_count
@onready var notification_container: VBoxContainer = $NotificationContainer
@onready var foraging_info: Panel = $notebook/skills_page/foraging_info
@onready var brewing_info: Panel = $notebook/skills_page/brewing_info
@onready var farming_info: Panel = $notebook/skills_page/farming_info
@onready var notification_scene: PackedScene = preload("res://src/ui/skill_notification.tscn")
@onready var craft_station_scene: PackedScene = preload("res://src/ui/menus/crafting_menu.tscn")
@onready var brewing_station_scene: PackedScene = preload("res://src/ui/menus/brewing_menu.tscn")
@onready var pause_menu_scene: PackedScene = preload("res://src/ui/menus/pause_menu.tscn")
var craft_instance: Control = null
var brew_instance: Control = null
var pause_instance: Control = null


func _ready() -> void:
	player_name_label.text = Globals.player_name
	Globals.gold_changed.connect(update_gold_ui)
	Globals.skill_updated.connect(update_skills_notebook)
	update_gold_ui()
	update_skills_notebook()


# check if movement shoulf be blocked  
func is_any_menu_open() -> bool:
	var craft_open = craft_instance and craft_instance.visible
	var brew_open = brew_instance and brew_instance.visible
	var pause_open = pause_instance and pause_instance.visible
	return notebook.visible or inventory.visible or craft_open or brew_open or pause_open


func update_gold_ui(new_amount: int = -1) -> void:
	var current_gold = new_amount if new_amount != -1 else Globals.playerStats["gold"]
	gold_count_label.text = "gold: " + str(current_gold)


func show_notification(text: String) -> void:
	var instance = notification_scene.instantiate()
	instance.get_node("Panel/description").text = text
	notification_container.add_child(instance)


func update_skills_notebook() -> void:
	foraging_count.text = str(Globals.playerSkills["FORAGING"])
	brewing_count.text = str(Globals.playerSkills["BREWING"])
	farming_count.text = str(Globals.playerSkills["FARMING"])


# ---------------- ui toggling ------------------------------

func toggle_pause_menu() -> void:
	if pause_instance == null:
		pause_instance = pause_menu_scene.instantiate()
		add_child(pause_instance)
	Globals.game_paused = !Globals.game_paused
	get_tree().paused = Globals.game_paused
	pause_instance.visible = Globals.game_paused


func toggle_notebook() -> void:
	if not notebook.visible:
		inventory.visible = false
		_close_stations()
		notebook.visible = true
	else:
		notebook.visible = false


func toggle_inventory() -> void:
	if not inventory.visible:
		notebook.visible = false
		inventory.visible = true
	else:
		inventory.visible = false
		_close_stations()
		
func toggle_skill_tree() -> void:
	if not skill_tree.visible:
		skill_tree.visible = true
	else:
		skill_tree.visible = false
	_close_stations()
		
		
func _close_stations() -> void:
	if craft_instance:
		craft_instance.hide()
		Globals.crafting_open = false
	if brew_instance:
		brew_instance.hide()
		Globals.brewing_open = false


func _toggle_station_instance(instance: Control, scene: PackedScene) -> Control:
	if instance == null:
		instance = scene.instantiate()
		add_child(instance)
		instance.visible = true
	else:
		instance.visible = !instance.visible
	return instance
	
func toggle_craft_station() -> void:
	craft_instance = _toggle_station_instance(craft_instance, craft_station_scene)
	Globals.crafting_open = craft_instance.visible
	inventory.visible = craft_instance.visible
	
	if Globals.crafting_open and brew_instance:
		brew_instance.hide()
		Globals.brewing_open = false


func toggle_brew_station() -> void:
	brew_instance = _toggle_station_instance(brew_instance, brewing_station_scene)
	Globals.brewing_open = brew_instance.visible
	
	#inventory.visible = brew_instance.visible
	inventory.visible = false

	if Globals.brewing_open:
		if craft_instance:
			craft_instance.hide()
			Globals.crafting_open = false
		
		# Forces the freshly opened brewing window to synchronize visual data instantly
		if brew_instance.has_method("update_brewing_inventory_ui"):
			brew_instance.update_brewing_inventory_ui()

func _on_back_button_pressed() -> void:
	toggle_inventory()


func _on_next_button_pressed() -> void:
	toggle_notebook()
	

func _on_foraging_skill_button_pressed() -> void:
	foraging_info.visible =true
	farming_info.visible = false
	brewing_info.visible = false

func _on_brewing_skill_button_pressed() -> void:
	brewing_info.visible = true
	foraging_info.visible =false
	farming_info.visible = false


func _on_farming_skill_button_pressed() -> void:
	farming_info.visible = true
	foraging_info.visible =false
	brewing_info.visible = false
