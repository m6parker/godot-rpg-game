extends Node

signal inventory_updated
signal crafting_updated
signal brewing_updated

# setup player
var player_name: String = "player_name"
var level: String = "World"

# ui state
var can_craft: bool = false
var can_brew: bool = false
var crafting_open: bool = false
var brewing_open: bool = false

# player data
# todo: for saving / loading game
var playerStats = {
	"health": 100, 
	"level": 1
}
	
var playerSkills = {
	"Foraging": 0, 
	"Combat": 0, 
	"Brewing": 0
}

# inv, craft, brew arrays
var player_inventory: Array = []
var crafting_slots: Array = []
var brewing_slots: Array = []

var crafting_result: Resource = null
var brewing_result: Resource = null


func _ready() -> void:
	_setup_inventory(20)
	
	# 2 crafting slots, maybe add more later
	crafting_slots.resize(2)
	crafting_slots.fill(null)
	
	# 3 slots for brewing station
	brewing_slots.resize(3)
	brewing_slots.fill(null)


func _setup_inventory(size: int) -> void:
	player_inventory.resize(size)
	player_inventory.fill(null)


func add_item(item_resource: Resource) -> bool:
	for i in range(player_inventory.size()):
		if player_inventory[i] == null:
			player_inventory[i] = item_resource
			inventory_updated.emit()
			return true
	return false
	
	
func increase_skill(skill_type: String) -> void:
	if playerSkills.has(skill_type):
		playerSkills[skill_type] += 1
		print(playerSkills)


# ------------- shift clicking -----------------------

func move_to_crafting(item: Resource, inv_index: int) -> bool:
	for i in range(crafting_slots.size()):
		if crafting_slots[i] == null:
			crafting_slots[i] = item
			player_inventory[inv_index] = null
			return true
	return false


func move_to_brewing(item: Resource, inv_index: int) -> bool:
	for i in range(brewing_slots.size()):
		if brewing_slots[i] == null:
			brewing_slots[i] = item
			player_inventory[inv_index] = null
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
