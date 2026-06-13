extends Node

# link signals
signal inventory_updated
@warning_ignore("unused_signal")
signal hotbar_updated
@warning_ignore("unused_signal")
signal crafting_updated
@warning_ignore("unused_signal")
signal brewing_updated
signal gold_changed(new_amount: int)
signal night_state_changed(is_night: bool)

@export var day_duration: float = 60.0 # seconds per day
var time: float = 0.5
var is_night: bool = false 

# setup player
var player_name: String = "player_name"
var level: String = "World"
var target_transition_marker: String = ""
var PLAYER_INVENTORY_SIZE = 9 #ui slots in basket

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
