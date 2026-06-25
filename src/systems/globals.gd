extends Node

# link signals
signal inventory_updated
@warning_ignore("unused_signal")
signal hotbar_updated
@warning_ignore("unused_signal")
signal crafting_updated
@warning_ignore("unused_signal")
signal brewing_updated
signal skill_updated
signal gold_changed(new_amount: int)
signal night_state_changed(is_night: bool)

@export var day_duration: float = 120.0 # seconds per day
var time: float = 0.5
var is_night: bool = false
var game_paused: bool = true
var world_states: Dictionary = {}

# setup player
var player_name: String = "player_name"
var world: String = "World"
var target_transition_marker: String = ""
var PLAYER_INVENTORY_SIZE = 9 #ui slots in basket
var player_position: Vector2 = Vector2.ZERO
var current_scene_path: String = "" # track where player is

# ui state
var can_craft: bool = false
var can_brew: bool = false
var crafting_open: bool = false
var brewing_open: bool = false

# player data
# todo: for saving / loading game
var playerStats = {
	"health": 100, 
	"level": 1,
	"gold": 10
}
	
var playerSkills = {
	"FORAGING": 0, 
	"COMBAT": 0, 
	"BREWING": 0,
	"FARMING": 0
}

# inv, craft, brew arrays
var player_inventory: Array = []
var crafting_slots: Array = []
var brewing_slots: Array = []
var hotbar_slots: Array = []

var crafting_result: Resource = null
var brewing_result: Resource = null

var equipped_item: Resource = null
var equipped_slot_index: int = -1


func _ready() -> void:
	_load_item_database(ITEMS_JSON_PATH, item_database)
	_load_item_database(TOOTS_JSON_PATH, tool_database)

	_setup_inventory(PLAYER_INVENTORY_SIZE)
	
	# 2 crafting slots, maybe add more later
	crafting_slots.resize(2)
	crafting_slots.fill(null)
	
	# 3 slots for brewing station
	brewing_slots.resize(3)
	brewing_slots.fill(null)
	
	hotbar_slots.resize(4)
	hotbar_slots.fill(null)


func _setup_inventory(size: int) -> void:
	player_inventory.resize(size)
	player_inventory.fill(null)


func add_item(item_resource: Resource) -> bool:
	# loop thru the player inventory 
	for i in range(player_inventory.size()):
		# check for empty slot
		if player_inventory[i] == null:
			print("adding ", item_resource)
			#add the new item intothe slot and update ui
			player_inventory[i] = item_resource
			inventory_updated.emit()
			return true
	print("item not added")
	return false
	
	
func increase_skill(skill_type: String) -> void:
	#check if the skill exists and increment the level
	if playerSkills.has(skill_type.to_upper()):
		playerSkills[skill_type.to_upper()] += 1
		#print(playerSkills)
		skill_updated.emit()


func equip_item(item: Resource, currently_equipped_index:int) -> void:
	if item:
		print("using item ", item.item_name)
		equipped_item = item
		equipped_slot_index = currently_equipped_index
	else:
		print("empty hotbar slot")
		equipped_item = null
		

func get_equipped_item() -> Resource:
	return equipped_item
	
func remove_equipped_item() -> void:
	equipped_item = null
	hotbar_slots[equipped_slot_index] = null
	Globals.inventory_updated.emit()
	

func _process(delta: float) -> void:
	if !game_paused:
		time += delta / day_duration
		if time >= 1.0:
			time = 0.0
		var new_night_state = (time < 0.2 or time > 0.8)
		if new_night_state != is_night:
			is_night = new_night_state
			night_state_changed.emit(is_night)

# ------------------ store ----------------------------

func can_afford(amount: int) -> bool:
	return playerStats.get("gold", 0) >= amount

func deduct_gold(amount: int) -> void:
	playerStats["gold"] = playerStats.get("gold", 0) - amount
	gold_changed.emit(playerStats["gold"])

func has_empty_inventory_slot() -> bool:
	return player_inventory.find(null) != -1

# ------------- shift clicking -----------------------
func move_to_hotbar(item: Resource, inv_index: int) -> bool:
	for i in range(hotbar_slots.size()):
		if hotbar_slots[i] == null:
			hotbar_slots[i] = item
			player_inventory[inv_index] = null
			return true
	return false

func move_to_crafting(item: Resource, inv_index: int) -> bool:
	for i in range(crafting_slots.size()):
		if crafting_slots[i] == null:
			crafting_slots[i] = item
			player_inventory[inv_index] = null
			return true
	return false


func move_to_brewing(item: Resource, inventory_index: int) -> bool:
	# check if item is bottle
	var filename = item.resource_path.get_file().get_basename().to_lower()
	var is_bottle = "bottle" in filename

	for i in range(brewing_slots.size()):
		if i == 2 and not is_bottle:
			continue
			
		if brewing_slots[i] == null:
			brewing_slots[i] = item
			player_inventory[inventory_index] = null
			return true
			
	return false


func move_to_inventory(item: Resource, source_type: String, source_index: int) -> bool:
	# check for empty slot
	var open_slot_index = player_inventory.find(null)
	
	# if inventory is full
	if open_slot_index == -1:
		return false
		
	# move item in inventory
	player_inventory[open_slot_index] = item
	
	match source_type:
		"result":
			crafting_result = null
		"brewing_result":
			brewing_result = null
		"crafting":
			crafting_slots[source_index] = null
		"brewing":
			brewing_slots[source_index] = null
			
	return true


# ------------------ save / load ----------------------------

const SAVE_PATH = "user://savegame.json"
const ITEMS_JSON_PATH = "res://data/items.json"
const TOOTS_JSON_PATH = "res://data/tools.json"
var item_database: Dictionary = {}
var tool_database: Dictionary = {}

func _load_item_database(path: String, database: Dictionary) -> void:
	if not FileAccess.file_exists(path):
		print_debug("json file not found at: ", path)
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) == OK:
		var items_list = json.get_data()
		if items_list is Array:
			for item_data in items_list:
				var item_name = item_data.get("name", "")
				if item_name != "":
					database[item_name] = item_data
	else:
		print("parse error: ", json.get_error_message())

func create_item_by_name(name_id: String) -> ItemData:
	if name_id == "" or not item_database.has(name_id):
		print("no item '" + name_id + "' inside items.json!")
		return null
		
	var data = item_database[name_id]
	var item = ItemData.new()
	item.item_name = data.get("name", "")
	item.price = int(data.get("price", 0))
	item.description = data.get("description", "")
	item.item_type = data.get("type", "")
	
	var texture_path = "res://assets/items/" +  item.item_type.to_lower() + "/" + item.item_name.to_lower() + ".png"
	if ResourceLoader.exists(texture_path):
		item.item_texture = load(texture_path)
	else:
		print("missing texture file for item: ", texture_path)
		
	return item
	
# puts all save info into dictionary to save as json
func save_game() -> void:
	# saving world tiles (planted plants)
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.has_method("save_world_state"):
		current_scene.save_world_state()
	
	# get player position
	var player_node = current_scene.find_child("player", true, false)
	if player_node:
		player_position = player_node.global_position
	
	# get path of scene
	if current_scene:
		current_scene_path = current_scene.scene_file_path
		
	var save_data = {
		"player_name": player_name,
		"time": time,
		"world": world,
		"current_scene_path": current_scene_path,
		"player_position": {"x": player_position.x, "y": player_position.y},
		"player_stats": playerStats,
		"player_skills": playerSkills,
		"player_inventory": _inventory_to_paths(player_inventory),
		"hotbar_slots": _inventory_to_paths(hotbar_slots),
		"crafting_slots": _inventory_to_paths(crafting_slots),
		"brewing_slots": _inventory_to_paths(brewing_slots),
		"world_states": world_states
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data, "\t")
		file.store_string(json_string)
		file.close()
		print("game saved!")
	else:
		print("error saving game: ", FileAccess.get_open_error())


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("no save file")
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var save_data = json.get_data()
			
			# restore basics
			player_name = save_data.get("player_name", "player_name")
			time = save_data.get("time", 0.5)
			world = save_data.get("world", "World")
			world_states = save_data.get("world_states", {})
			
			# restore position coords
			current_scene_path = save_data.get("current_scene_path", "")
			var pos_data = save_data.get("player_position", {"x": 0.0, "y": 0.0})
			player_position = Vector2(pos_data.get("x", 0.0), pos_data.get("y", 0.0))
			
			# restore dictionaries
			var loaded_stats = save_data.get("player_stats", {})
			for key in loaded_stats.keys():
				if playerStats.has(key):
					playerStats[key] = int(loaded_stats[key]) if loaded_stats[key] is float or loaded_stats[key] is int else loaded_stats[key]

			var loaded_skills = save_data.get("player_skills", {})
			for key in loaded_skills.keys():
				var upper_key = key.to_upper()
				if playerSkills.has(upper_key):
					playerSkills[upper_key] = int(loaded_skills[key])
			
			# restore items
			player_inventory = _paths_to_inventory(save_data.get("player_inventory", []), PLAYER_INVENTORY_SIZE)
			hotbar_slots = _paths_to_inventory(save_data.get("hotbar_slots", []), 4)
			crafting_slots = _paths_to_inventory(save_data.get("crafting_slots", []), 2)
			brewing_slots = _paths_to_inventory(save_data.get("brewing_slots", []), 3)
			
			# prevent bugs
			equipped_item = null
			equipped_slot_index = -1
			
			# go to saved scene
			if current_scene_path != "" and ResourceLoader.exists(current_scene_path):
				get_tree().change_scene_to_file(current_scene_path)
			else:
				var fallback_path = "res://worlds/forest/world.tscn"
				get_tree().change_scene_to_file(fallback_path)
			
			_deferred_ui_refresh.call_deferred(true)
		else:
			print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())


func _deferred_ui_refresh(should_reposition_player: bool = false) -> void:
	await get_tree().process_frame
	if should_reposition_player:
		var current_scene = get_tree().current_scene
		if not current_scene:
			await get_tree().process_frame
			current_scene = get_tree().current_scene
			
		if current_scene:
			var player_node = current_scene.find_child("player", true, false)
			if player_node:
				player_node.global_position = player_position
			else:
				print_debug("error cant find player")
		else:
			print_debug("error")

	inventory_updated.emit()
	if has_signal("hotbar_updated"):
		hotbar_updated.emit()
	if has_signal("crafting_updated"):
		crafting_updated.emit()
	if has_signal("brewing_updated"):
		brewing_updated.emit()
	gold_changed.emit(playerStats.get("gold", 0))


# turns [Resource, null, ToolResource] into ["acorn", "", "iron_pickaxe"] 
func _inventory_to_paths(inventory_array: Array) -> Array:
	var name_array: Array = []
	for item in inventory_array: 
		if item and "item_name" in item and item.item_name != "":
			name_array.append(item.item_name)
		else:
			name_array.append("")
	return name_array


# turns ["acorn", "", "iron_pickaxe"] back into resources (items or tools)
func _paths_to_inventory(name_array: Array, fixed_size: int) -> Array:
	var new_inventory: Array = []
	new_inventory.resize(fixed_size)
	new_inventory.fill(null)
	
	for i in range(min(name_array.size(), fixed_size)):
		var item_name = name_array[i]
		if item_name != "":
			new_inventory[i] = create_any_item_by_name(item_name)
			
	return new_inventory

# creates tools and items from jusdt the name
func create_any_item_by_name(name_id: String) -> Resource:
	if name_id == "":
		return null
		
	# check item db
	if item_database.has(name_id):
		var data = item_database[name_id]
		var item = ItemData.new()
		item.item_name = data.get("name", "")
		item.price = int(data.get("price", 0))
		item.description = data.get("description", "")
		item.item_type = data.get("type", "")
		
		var texture_path = "res://assets/items/" + item.item_type.to_lower() + "/" + item.item_name.to_lower() + ".png"
		if ResourceLoader.exists(texture_path):
			item.item_texture = load(texture_path)
		return item
		
	# check tool db
	elif tool_database.has(name_id):
		var data = tool_database[name_id]
		var tool_item = ItemData.new() 
		tool_item.item_name = data.get("name", "")
		tool_item.price = int(data.get("price", 0))
		tool_item.description = data.get("description", "")
		tool_item.item_type = data.get("type", "")
		
		var texture_path = "res://assets/tools/" + tool_item.item_name.to_lower() + ".png"
		if ResourceLoader.exists(texture_path):
			tool_item.item_texture = load(texture_path)
		return tool_item
		
	return null
	
