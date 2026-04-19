extends Node

signal inventory_updated

var level = "World"
var playerStats = {"health": 100, "level": 1}

var player_inventory = []

func _ready() -> void:
	_setup_inventory(20) 

func _setup_inventory(size: int) -> void:
	player_inventory.clear()
	for i in range(size):
		player_inventory.append(null)

func add_item(data: Dictionary) -> bool:
	for i in range(player_inventory.size()):
		if player_inventory[i] == null:
			player_inventory[i] = data 
			inventory_updated.emit()
			return true
	return false
