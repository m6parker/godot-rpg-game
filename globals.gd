extends Node

signal inventory_updated

var player_name: String = "player_name"
var level: String = "World"
var can_craft: bool = false

var playerStats = {
	"health": 100, 
	"level": 1
	}
	
var playerSkills = {
	"Foraging": 0, 
	"Combat": 0, 
	"Brewing": 0
	}
	
var crafting_slots = []
var crafting_result = null
signal crafting_updated

func _ready():
	player_inventory.resize(20)
	player_inventory.fill(null)
	
	# 2 slots to begin with, unlock more prolly
	crafting_slots.resize(2)
	crafting_slots.fill(null)


var player_inventory = []

func _setup_inventory(size: int) -> void:
	player_inventory.clear()
	for i in range(size):
		player_inventory.append(null)

func add_item(item_resource: ItemData) -> bool:
	for i in range(player_inventory.size()):
		if player_inventory[i] == null:
			#player_inventory[i] = data 
			player_inventory[i] = item_resource
			inventory_updated.emit()
			return true
	return false
	
func increase_skill(skill_type):
	if skill_type:
		playerSkills[skill_type]+=1
		print(playerSkills)
	
# --------- shift clicking ------------
func move_to_crafting(item: Resource, inv_index: int) -> bool:
	for i in range(crafting_slots.size()):
		if crafting_slots[i] == null:
			crafting_slots[i] = item
			player_inventory[inv_index] = null
			return true
	return false

func move_to_inventory(item: Resource, type: String, craft_index: int) -> bool:
	for i in range(player_inventory.size()):
		if player_inventory[i] == null:
			player_inventory[i] = item
			
			if type == "result":
				crafting_result = null
			else:
				crafting_slots[craft_index] = null
			return true
	return false
	
	
